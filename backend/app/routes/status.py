from fastapi import APIRouter

router = APIRouter()


@router.get("/api/v1/status")
async def status():
    return {"status": "ok", "service": "studyflow-ai"}
