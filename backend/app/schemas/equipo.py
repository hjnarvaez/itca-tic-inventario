from typing import Literal

from pydantic import BaseModel, ConfigDict, Field

EstadoEquipo = Literal[
    "Disponible",
    "Asignado",
    "Mantenimiento",
    "Baja",
]


class EquipoCreate(BaseModel):
    codigo: str = Field(min_length=1, max_length=30)
    nombre: str = Field(min_length=1, max_length=120)
    categoria: str = Field(min_length=1, max_length=60)
    estado: EstadoEquipo = "Disponible"
    ubicacion: str = Field(min_length=1, max_length=120)


class EquipoUpdate(EquipoCreate):
    pass


class EquipoResponse(EquipoCreate):
    id: int
    model_config = ConfigDict(from_attributes=True)
