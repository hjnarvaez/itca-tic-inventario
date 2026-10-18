from sqlalchemy import select
from sqlalchemy.orm import Session

from app.models.equipo import Equipo


def listar(db: Session, usuario_id: int):
    return db.scalars(
        select(Equipo)
        .where(Equipo.usuario_id == usuario_id)
        .order_by(Equipo.id)
    ).all()


def obtener(db: Session, usuario_id: int, equipo_id: int):
    return db.scalar(
        select(Equipo).where(
            Equipo.id == equipo_id,
            Equipo.usuario_id == usuario_id,
        )
    )


def obtener_por_codigo(db: Session, usuario_id: int, codigo: str):
    return db.scalar(
        select(Equipo).where(
            Equipo.usuario_id == usuario_id,
            Equipo.codigo == codigo,
        )
    )


def crear(db: Session, usuario_id: int, datos: dict):
    equipo = Equipo(**datos, usuario_id=usuario_id)
    db.add(equipo)
    db.commit()
    db.refresh(equipo)
    return equipo


def actualizar(db: Session, equipo: Equipo, datos: dict):
    for campo, valor in datos.items():
        setattr(equipo, campo, valor)
    db.commit()
    db.refresh(equipo)
    return equipo


def eliminar(db: Session, equipo: Equipo):
    db.delete(equipo)
    db.commit()
