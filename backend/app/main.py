import os

from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse


from app.tenx_preview_agent import router as tenx_preview_agent_router
from app.tenx_jobs import router as tenx_jobs_router
from app.tenx_observability import install as tenx_observability_install


app = FastAPI(title="10x Backend")


@app.middleware("http")
async def require_tenx_router(request: Request, call_next):
    expected = os.getenv("TENX_ROUTER_SHARED_SECRET", "")
    path = request.url.path or "/"
    preview_prefix = os.getenv("TENX_PREVIEW_AGENT_PATH_PREFIX", "/__tenx/preview-agent")
    if expected and not (path == "/healthz" or path.startswith(preview_prefix)):
        received = request.headers.get("x-tenx-router-token", "")
        if received != expected:
            return JSONResponse({"detail": "Not found"}, status_code=404)
    return await call_next(request)


@app.get("/healthz")
async def healthz():
    return {"status": "ok"}




if os.getenv("TENX_PREVIEW_AGENT_TOKEN"):
    app.include_router(tenx_preview_agent_router)
app.include_router(tenx_jobs_router)
tenx_observability_install(app)
