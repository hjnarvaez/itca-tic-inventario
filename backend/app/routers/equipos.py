from fastapi import APIRouter, Depends, Response
from sqlalchemy.orm import Session

from app.database import get_db
from app.dependencies import get_current_user
from app.models.usuario import Usuario
from app.schemas.equipo import EquipoCreate, EquipoUpdate, EquipoResponse
from app.services import equipos as service

router = APIRouter(prefix="/equipos", tags=["equipos"])


@router.get("/", response_model=list[EquipoResponse])
def listar(
    db: Session = Depends(get_db),
    usuario: Usuario = Depends(get_current_user),
):
    return service.listar(db, usuario.id)


@router.post("/", response_model=EquipoResponse, status_code=201)
def crear(
    datos: EquipoCreate,
    db: Session = Depends(get_db),
    usuario: Usuario = Depends(get_current_user),
):
    return service.crear(db, usuario.id, datos.model_dump())


@router.get("/{equipo_id}", response_model=EquipoResponse)
def obtener(
    equipo_id: int,
    db: Session = Depends(get_db),
    usuario: Usuario = Depends(get_current_user),
):
    return service.obtener(db, usuario.id, equipo_id)


@router.put("/{equipo_id}", response_model=EquipoResponse)
def actualizar(
    equipo_id: int,
    datos: EquipoUpdate,
    db: Session = Depends(get_db),
    usuario: Usuario = Depends(get_current_user),
):
    return service.actualizar(
        db, usuario.id, equipo_id, datos.model_dump()
    )


@router.delete("/{equipo_id}", status_code=204)
def eliminar(
    equipo_id: int,
    db: Session = Depends(get_db),
    usuario: Usuario = Depends(get_current_user),
):
    service.eliminar(db, usuario.id, equipo_id)
    return Response(status_code=204)
