import logging

import httpx
from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel, Field
from sqlalchemy.orm import Session

from app.database import get_db
from app.dependencies import get_current_user
from app.models.usuario import Usuario
from app.repositories import equipos as equipos_repository
from app.services.asistente_ia import responder_pregunta

router = APIRouter(prefix="/ia", tags=["inteligencia artificial"])
logger = logging.getLogger(__name__)


class PreguntaIA(BaseModel):
    pregunta: str = Field(min_length=3, max_length=300)


class RespuestaIA(BaseModel):
    respuesta: str


@router.post("/preguntar", response_model=RespuestaIA)
async def preguntar(
    datos: PreguntaIA,
    db: Session = Depends(get_db),
    usuario: Usuario = Depends(get_current_user),
):
    equipos = equipos_repository.listar(db, usuario.id)

    inventario = [
        {
            "codigo": equipo.codigo,
            "nombre": equipo.nombre,
            "categoria": equipo.categoria,
            "estado": equipo.estado,
            "ubicacion": equipo.ubicacion,
        }
        for equipo in equipos
    ]

    if not inventario:
        return RespuestaIA(
            respuesta="No tienes equipos registrados."
        )

    try:
        respuesta = await responder_pregunta(
            datos.pregunta,
            inventario,
        )
    except httpx.HTTPStatusError as exc:
        logger.warning(
            "Gemini respondió con HTTP %s",
            exc.response.status_code,
        )
        raise HTTPException(
            status_code=503,
            detail="El servicio de IA no está disponible.",
        ) from None
    except (httpx.RequestError, ValueError, RuntimeError):
        raise HTTPException(
            status_code=503,
            detail="No se pudo obtener una respuesta de IA.",
        ) from None

    return RespuestaIA(respuesta=respuesta)
