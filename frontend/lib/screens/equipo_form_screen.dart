import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/equipos_controller.dart';
import '../models/equipo.dart';

class EquipoFormScreen extends StatefulWidget {
  final Equipo? equipo;

  const EquipoFormScreen({super.key, this.equipo});

  @override
  State<EquipoFormScreen> createState() => _EquipoFormScreenState();
}

class _EquipoFormScreenState extends State<EquipoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codigo = TextEditingController();
  final _nombre = TextEditingController();
  final _categoria = TextEditingController();
  final _ubicacion = TextEditingController();
  final controller = Get.find<EquiposController>();

  String _estado = 'Disponible';

  @override
  void initState() {
    super.initState();
    final equipo = widget.equipo;
    if (equipo != null) {
      _codigo.text = equipo.codigo;
      _nombre.text = equipo.nombre;
      _categoria.text = equipo.categoria;
      _ubicacion.text = equipo.ubicacion;
      _estado = equipo.estado;
    }
  }

  @override
  void dispose() {
    _codigo.dispose();
    _nombre.dispose();
    _categoria.dispose();
    _ubicacion.dispose();
    super.dispose();
  }

  Widget campo(String etiqueta, TextEditingController texto, int maximo) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: texto,
        maxLength: maximo,
        decoration: InputDecoration(
          labelText: etiqueta,
          border: const OutlineInputBorder(),
        ),
        validator: (valor) {
          if (valor == null || valor.trim().isEmpty) {
            return 'Campo obligatorio';
          }
          return null;
        },
      ),
    );
  }

  Future<void> guardar() async {
    if (!_formKey.currentState!.validate()) return;

    final datos = {
      'codigo': _codigo.text.trim(),
      'nombre': _nombre.text.trim(),
      'categoria': _categoria.text.trim(),
      'estado': _estado,
      'ubicacion': _ubicacion.text.trim(),
    };

    final error = await controller.guardar(datos, id: widget.equipo?.id);

    if (!mounted) return;

    if (error == null) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Equipo guardado correctamente')),
      );
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.equipo == null ? 'Nuevo equipo' : 'Editar equipo'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            campo('Código', _codigo, 30),
            campo('Nombre', _nombre, 120),
            campo('Categoría', _categoria, 60),
            campo('Ubicación', _ubicacion, 120),
            DropdownButtonFormField<String>(
              initialValue: _estado,
              decoration: const InputDecoration(
                labelText: 'Estado',
                border: OutlineInputBorder(),
              ),
              items: ['Disponible', 'Asignado', 'Mantenimiento', 'Baja'].map((
                estado,
              ) {
                return DropdownMenuItem(value: estado, child: Text(estado));
              }).toList(),
              onChanged: (valor) {
                if (valor != null) {
                  setState(() => _estado = valor);
                }
              },
            ),
            const SizedBox(height: 24),
            Obx(
              () => FilledButton.icon(
                onPressed: controller.guardando.value ? null : guardar,
                icon: const Icon(Icons.save),
                label: Text(
                  controller.guardando.value
                      ? 'Guardando...'
                      : 'Guardar equipo',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
