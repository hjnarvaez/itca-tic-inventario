from fastapi import HTTPException
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session

from app.repositories import equipos as repo


def listar(db: Session, usuario_id: int):
    return repo.listar(db, usuario_id)


def obtener(db: Session, usuario_id: int, equipo_id: int):
    equipo = repo.obtener(db, usuario_id, equipo_id)
    if equipo is None:
        raise HTTPException(404, "Equipo no encontrado")
    return equipo


def crear(db: Session, usuario_id: int, datos: dict):
    if repo.obtener_por_codigo(db, usuario_id, datos["codigo"]):
        raise HTTPException(409, "El código ya existe")

    try:
        return repo.crear(db, usuario_id, datos)
    except IntegrityError:
        db.rollback()
        raise HTTPException(409, "El código ya existe")


def actualizar(db: Session, usuario_id: int, equipo_id: int, datos: dict):
    equipo = obtener(db, usuario_id, equipo_id)

    existente = repo.obtener_por_codigo(db, usuario_id, datos["codigo"])
    if existente is not None and existente.id != equipo.id:
        raise HTTPException(409, "El código ya existe")

    try:
        return repo.actualizar(db, equipo, datos)
    except IntegrityError:
        db.rollback()
        raise HTTPException(409, "El código ya existe")


def eliminar(db: Session, usuario_id: int, equipo_id: int):
    equipo = obtener(db, usuario_id, equipo_id)
    repo.eliminar(db, equipo)
