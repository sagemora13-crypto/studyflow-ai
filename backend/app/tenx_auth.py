"""Verified 10x sign-in identity for backend routes.

Usage:

    from fastapi import APIRouter, Depends
    from app.tenx_auth import current_user

    router = APIRouter()

    @router.get("/api/v1/me")
    async def me(user: dict = Depends(current_user)):
        return {"user_id": user["sub"], "email": user.get("email")}

The 10x gateway already rejects unauthenticated calls to routes declared
`auth: required`; this dependency re-verifies the token against the
project's JWKS so the route gets trustworthy claims.
"""
import os
import time

import httpx
import jwt
from fastapi import Header, HTTPException

_JWKS_CACHE: dict = {"keys": [], "fetched_at": 0.0}
_JWKS_TTL_SECONDS = 300.0

# 10x sign-in issues EdDSA (Ed25519) tokens; other projects may use EC or
# RSA. Never hard-code a single algorithm — derive it from the JWK.
_ALLOWED_ALGORITHMS = {
    "EdDSA", "ES256", "ES384", "ES512",
    "RS256", "RS384", "RS512", "PS256", "PS384", "PS512",
}


def _jwks_url() -> str:
    explicit = os.getenv("TENX_AUTH_JWKS_URL", "").strip()
    if explicit:
        return explicit
    host = os.getenv("TENX_API_HOST", "").strip()
    return f"https://{host}/.well-known/jwks.json" if host else ""


def _expected_issuer() -> str:
    # 10x sign-in stamps `iss = <project api url>/auth`. `TENX_AUTH_BASE_URL`
    # already holds that exact value; otherwise derive it from the project
    # API URL. Returns "" when neither is configured (issuer check skipped).
    base = os.getenv("TENX_AUTH_BASE_URL", "").strip()
    if base:
        return base.rstrip("/")
    api_url = os.getenv("TENX_PROJECT_API_URL", "").strip().rstrip("/")
    return f"{api_url}/auth" if api_url else ""


def _load_jwks_keys(force: bool = False) -> list:
    url = _jwks_url()
    if not url:
        raise HTTPException(status_code=503, detail="Auth is not configured for this backend.")
    now = time.time()
    if force or not _JWKS_CACHE["keys"] or now - _JWKS_CACHE["fetched_at"] > _JWKS_TTL_SECONDS:
        response = httpx.get(url, timeout=5.0)
        response.raise_for_status()
        _JWKS_CACHE["keys"] = response.json().get("keys") or []
        _JWKS_CACHE["fetched_at"] = now
    return _JWKS_CACHE["keys"]


def _algorithm_for_jwk(header: dict, jwk: dict) -> str:
    for value in (header.get("alg"), jwk.get("alg")):
        alg = str(value or "").strip()
        if alg in _ALLOWED_ALGORITHMS:
            return alg
    kty = str(jwk.get("kty") or "").strip().upper()
    if kty == "OKP":
        return "EdDSA"
    if kty == "EC":
        return {"P-256": "ES256", "P-384": "ES384", "P-521": "ES512"}.get(
            str(jwk.get("crv") or ""), "ES256"
        )
    return "RS256"


def _verify(token: str) -> dict:
    keys = _load_jwks_keys()
    if not keys:
        raise HTTPException(status_code=503, detail="Auth is not configured for this backend.")
    header = jwt.get_unverified_header(token)
    kid = str(header.get("kid") or "")
    jwk = next((key for key in keys if str(key.get("kid") or "") == kid), None)
    if jwk is None and kid:
        # The signing key rotated since we last cached JWKS. The 10x gateway
        # refetches on every call, so it already accepted this token — force a
        # single cache-busting refetch here instead of failing for up to the
        # cache TTL after a rotation.
        keys = _load_jwks_keys(force=True)
        jwk = next((key for key in keys if str(key.get("kid") or "") == kid), None)
    if jwk is None:
        # A genuine kid mismatch must fail: the force-refetch above already
        # picked up any rotated key, so falling back to a sole cached key
        # here would silently accept tokens signed by an untrusted key and
        # defeat kid rotation.
        raise HTTPException(status_code=401, detail="Unknown signing key.")
    algorithm = _algorithm_for_jwk(header, jwk)
    audience = os.getenv("TENX_AUTH_AUDIENCE", "").strip()
    issuer = _expected_issuer()
    pyjwk = jwt.PyJWK.from_dict(jwk, algorithm=algorithm)
    # 10x sign-in stamps `aud` (the project public ref) and `iss`
    # (`<project api url>/auth`) on every token; enforce both whenever the
    # scaffold is given them via env so a shared/mis-set JWKS URL can't be
    # replayed across apps. A small leeway absorbs client clock skew.
    return jwt.decode(
        token,
        key=pyjwk.key,
        algorithms=[algorithm],
        audience=audience or None,
        issuer=issuer or None,
        leeway=60,
        options={
            "verify_aud": bool(audience),
            "verify_iss": bool(issuer),
        },
    )


def current_user(authorization: str | None = Header(default=None)) -> dict:
    """FastAPI dependency returning the verified JWT claims for the
    signed-in app user. `sub` is the stable user id."""
    token = (authorization or "").removeprefix("Bearer ").strip()
    if not token:
        raise HTTPException(status_code=401, detail="Sign-in required.")
    try:
        claims = _verify(token)
    except HTTPException:
        raise
    except Exception as error:  # noqa: BLE001 - normalize verify failures to 401
        raise HTTPException(status_code=401, detail="Invalid or expired session.") from error
    if not isinstance(claims, dict) or not claims.get("sub"):
        raise HTTPException(status_code=401, detail="Invalid or expired session.")
    return claims