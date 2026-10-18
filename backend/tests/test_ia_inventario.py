from unittest.mock import AsyncMock

import pytest

from app.routers import ia
from tests.test_equipos_inventario import (
    autenticar,
    datos_equipo,
)


def test_ia_requiere_jwt(client):
    respuesta = client.post(
        "/ia/preguntar",
        json={"pregunta": "¿Cuántos equipos tengo?"},
    )
    assert respuesta.status_code == 401


@pytest.mark.parametrize("pregunta", ["", "ab", "x" * 301])
def test_ia_valida_longitud_pregunta(client, pregunta):
    headers = autenticar(client)

    respuesta = client.post(
        "/ia/preguntar",
        json={"pregunta": pregunta},
        headers=headers,
    )

    assert respuesta.status_code == 422


def test_ia_sin_equipos_no_llama_gemini(client, monkeypatch):
    headers = autenticar(client)

    mock = AsyncMock()
    monkeypatch.setattr(ia, "responder_pregunta", mock)

    respuesta = client.post(
        "/ia/preguntar",
        json={"pregunta": "¿Cuántos equipos tengo?"},
        headers=headers,
    )

    assert respuesta.status_code == 200
    assert respuesta.json()["respuesta"] == (
        "No tienes equipos registrados."
    )
    mock.assert_not_awaited()


def test_ia_responde_con_inventario_propio(client, monkeypatch):
    usuario_a = autenticar(client)
    usuario_b = autenticar(client)

    creado = client.post(
        "/equipos/",
        json=datos_equipo(
            codigo="TIC-IA-001",
            nombre="Laptop Gemini",
        ),
        headers=usuario_a,
    )
    assert creado.status_code == 201

    otro = client.post(
        "/equipos/",
        json=datos_equipo(
            codigo="TIC-AJENO-002",
            nombre="Equipo privado",
        ),
        headers=usuario_b,
    )
    assert otro.status_code == 201

    mock = AsyncMock(
        return_value="Tienes un equipo registrado."
    )
    monkeypatch.setattr(ia, "responder_pregunta", mock)

    respuesta = client.post(
        "/ia/preguntar",
        json={"pregunta": "Resume mi inventario"},
        headers=usuario_a,
    )

    assert respuesta.status_code == 200
    assert respuesta.json() == {
        "respuesta": "Tienes un equipo registrado."
    }

    mock.assert_awaited_once()
    pregunta, inventario = mock.await_args.args

    assert pregunta == "Resume mi inventario"
    assert len(inventario) == 1
    assert inventario[0]["codigo"] == "TIC-IA-001"
    assert inventario[0]["nombre"] == "Laptop Gemini"
    assert "usuario_id" not in inventario[0]


@pytest.mark.parametrize(
    "error",
    [
        RuntimeError("Gemini no configurado"),
        ValueError("Respuesta vacía"),
    ],
)
def test_ia_maneja_errores_del_servicio(
    client, monkeypatch, error
):
    headers = autenticar(client)

    creado = client.post(
        "/equipos/",
        json=datos_equipo(),
        headers=headers,
    )
    assert creado.status_code == 201

    mock = AsyncMock(side_effect=error)
    monkeypatch.setattr(ia, "responder_pregunta", mock)

    respuesta = client.post(
        "/ia/preguntar",
        json={"pregunta": "Resume mis equipos"},
        headers=headers,
    )

    assert respuesta.status_code == 503
    assert "No se pudo obtener" in respuesta.json()["detail"]
