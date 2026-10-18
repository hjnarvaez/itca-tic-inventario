from uuid import uuid4


def autenticar(client):
    email = f"test-{uuid4().hex[:12]}@ejemplo.com"
    password = "ClaveSegura123"

    registro = client.post(
        "/usuarios/",
        json={"email": email, "password": password},
    )
    assert registro.status_code == 201, registro.text

    login = client.post(
        "/usuarios/token",
        data={"username": email, "password": password},
    )
    assert login.status_code == 200, login.text

    return {
        "Authorization": f"Bearer {login.json()['access_token']}"
    }


def datos_equipo(codigo="TIC-TEST-001", nombre="Laptop de prueba"):
    return {
        "codigo": codigo,
        "nombre": nombre,
        "categoria": "Computadora",
        "estado": "Disponible",
        "ubicacion": "Laboratorio TIC",
    }


def test_equipos_requieren_autenticacion(client):
    assert client.get("/equipos/").status_code == 401
    assert client.post(
        "/equipos/", json=datos_equipo()
    ).status_code == 401


def test_crud_completo_equipos(client):
    headers = autenticar(client)

    creado = client.post(
        "/equipos/",
        json=datos_equipo(),
        headers=headers,
    )
    assert creado.status_code == 201, creado.text

    equipo_id = creado.json()["id"]
    assert creado.json()["codigo"] == "TIC-TEST-001"

    listado = client.get("/equipos/", headers=headers)
    assert listado.status_code == 200
    assert len(listado.json()) == 1

    obtenido = client.get(
        f"/equipos/{equipo_id}", headers=headers
    )
    assert obtenido.status_code == 200

    actualizado = client.put(
        f"/equipos/{equipo_id}",
        json=datos_equipo(
            codigo="TIC-TEST-001",
            nombre="Laptop actualizada",
        ),
        headers=headers,
    )
    assert actualizado.status_code == 200
    assert actualizado.json()["nombre"] == "Laptop actualizada"

    eliminado = client.delete(
        f"/equipos/{equipo_id}", headers=headers
    )
    assert eliminado.status_code == 204

    inexistente = client.get(
        f"/equipos/{equipo_id}", headers=headers
    )
    assert inexistente.status_code == 404


def test_codigo_duplicado_devuelve_409(client):
    headers = autenticar(client)

    primero = client.post(
        "/equipos/",
        json=datos_equipo(),
        headers=headers,
    )
    assert primero.status_code == 201

    duplicado = client.post(
        "/equipos/",
        json=datos_equipo(nombre="Otro equipo"),
        headers=headers,
    )
    assert duplicado.status_code == 409


def test_aislamiento_entre_usuarios(client):
    usuario_a = autenticar(client)
    usuario_b = autenticar(client)

    creado = client.post(
        "/equipos/",
        json=datos_equipo(),
        headers=usuario_a,
    )
    assert creado.status_code == 201
    equipo_id = creado.json()["id"]

    listado_b = client.get(
        "/equipos/", headers=usuario_b
    )
    assert listado_b.status_code == 200
    assert listado_b.json() == []

    assert client.get(
        f"/equipos/{equipo_id}",
        headers=usuario_b,
    ).status_code == 404

    assert client.put(
        f"/equipos/{equipo_id}",
        json=datos_equipo(nombre="Cambio no autorizado"),
        headers=usuario_b,
    ).status_code == 404

    assert client.delete(
        f"/equipos/{equipo_id}",
        headers=usuario_b,
    ).status_code == 404

    propietario = client.get(
        f"/equipos/{equipo_id}",
        headers=usuario_a,
    )
    assert propietario.status_code == 200
    assert propietario.json()["nombre"] == "Laptop de prueba"


def test_validaciones_equipos(client):
    headers = autenticar(client)

    datos = datos_equipo()
    datos["estado"] = "Estado desconocido"

    assert client.post(
        "/equipos/", json=datos, headers=headers
    ).status_code == 422

    datos = datos_equipo()
    datos["nombre"] = ""

    assert client.post(
        "/equipos/", json=datos, headers=headers
    ).status_code == 422
