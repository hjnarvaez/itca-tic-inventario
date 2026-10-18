import os

from sqlalchemy import select

from app.database import SessionLocal
from app.models.equipo import Equipo
from app.models.usuario import Usuario

EQUIPOS = [
    ("TIC-001", "Laptop Dell Latitude", "Computadora", "Asignado", "Oficina TIC"),
    ("TIC-002", "Laptop HP ProBook", "Computadora", "Disponible", "Laboratorio 1"),
    ("TIC-003", "PC Dell OptiPlex", "Computadora", "Asignado", "Administración"),
    ("TIC-004", "PC Lenovo ThinkCentre", "Computadora", "Disponible", "Laboratorio 2"),
    ("TIC-005", "Laptop Lenovo ThinkPad", "Computadora", "Mantenimiento", "Oficina TIC"),
    ("TIC-006", "Impresora HP LaserJet", "Impresora", "Disponible", "Secretaría"),
    ("TIC-007", "Impresora Epson EcoTank", "Impresora", "Asignado", "Rectorado"),
    ("TIC-008", "Impresora Brother DCP", "Impresora", "Mantenimiento", "Biblioteca"),
    ("TIC-009", "Switch Cisco SG500", "Redes", "Asignado", "Centro de Datos"),
    ("TIC-010", "Switch Cisco Catalyst", "Redes", "Disponible", "Oficina TIC"),
    ("TIC-011", "Router MikroTik CCR2004", "Redes", "Asignado", "Centro de Datos"),
    ("TIC-012", "Access Point Ubiquiti U7 Pro", "Redes", "Asignado", "Pasillo Principal"),
    ("TIC-013", "Access Point Ubiquiti AC Pro", "Redes", "Disponible", "Oficina TIC"),
    ("TIC-014", "Proyector Epson PowerLite", "Audiovisual", "Asignado", "Aula 101"),
    ("TIC-015", "Proyector BenQ", "Audiovisual", "Disponible", "Aula 202"),
    ("TIC-016", "Monitor Dell 24 pulgadas", "Periférico", "Asignado", "Administración"),
    ("TIC-017", "Monitor Samsung 27 pulgadas", "Periférico", "Disponible", "Oficina TIC"),
    ("TIC-018", "Servidor Dell PowerEdge", "Servidor", "Asignado", "Centro de Datos"),
    ("TIC-019", "UPS APC Smart-UPS", "Energía", "Mantenimiento", "Centro de Datos"),
    ("TIC-020", "Escáner Canon", "Periférico", "Baja", "Archivo"),
]


def main():
    email = os.environ.get("SEED_USER_EMAIL")

    if not email:
        raise SystemExit("Falta SEED_USER_EMAIL")

    with SessionLocal() as db:
        usuario = db.scalar(
            select(Usuario).where(Usuario.email == email)
        )

        if usuario is None:
            raise SystemExit(f"Usuario no encontrado: {email}")

        existentes = {
            codigo
            for codigo in db.scalars(
                select(Equipo.codigo).where(
                    Equipo.usuario_id == usuario.id
                )
            )
        }

        nuevos = 0

        for codigo, nombre, categoria, estado, ubicacion in EQUIPOS:
            if codigo in existentes:
                continue

            db.add(
                Equipo(
                    codigo=codigo,
                    nombre=nombre,
                    categoria=categoria,
                    estado=estado,
                    ubicacion=ubicacion,
                    usuario_id=usuario.id,
                )
            )
            nuevos += 1

        db.commit()
        total = len(
            db.scalars(
                select(Equipo.id).where(
                    Equipo.usuario_id == usuario.id
                )
            ).all()
        )

        print(f"Equipos nuevos: {nuevos}")
        print(f"Total de equipos del usuario: {total}")


if __name__ == "__main__":
    main()
