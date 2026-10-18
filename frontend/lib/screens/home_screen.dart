import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/auth_controller.dart';
import '../controllers/equipos_controller.dart';
import '../models/equipo.dart';
import 'equipo_form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final EquiposController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(EquiposController());
  }

  @override
  void dispose() {
    Get.delete<EquiposController>();
    super.dispose();
  }

  Future<void> abrirFormulario([Equipo? equipo]) async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => EquipoFormScreen(equipo: equipo)));
  }

  Future<void> confirmarEliminacion(Equipo equipo) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar equipo'),
        content: Text('¿Deseas eliminar ${equipo.nombre}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar != true || !mounted) return;

    final error = await controller.eliminarEquipo(equipo.id);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error ?? 'Equipo eliminado correctamente')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventario TIC'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar',
            onPressed: controller.cargarEquipos,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: auth.logout,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Agregar equipo',
        onPressed: () => abrirFormulario(),
        child: const Icon(Icons.add),
      ),
      body: Obx(() {
        if (controller.cargando.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.error.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(controller.error.value),
                ElevatedButton(
                  onPressed: controller.cargarEquipos,
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          );
        }

        if (controller.equipos.isEmpty) {
          return const Center(child: Text('No hay equipos registrados'));
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Total: ${controller.equipos.length} equipos',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: controller.cargarEquipos,
                child: ListView.builder(
                  itemCount: controller.equipos.length,
                  itemBuilder: (context, index) {
                    final equipo = controller.equipos[index];

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.computer),
                        title: Text(equipo.nombre),
                        subtitle: Text(
                          '${equipo.codigo}\n'
                          '${equipo.categoria} · ${equipo.ubicacion}\n'
                          'Estado: ${equipo.estado}',
                        ),
                        isThreeLine: true,
                        onTap: () => abrirFormulario(equipo),
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                          ),
                          tooltip: 'Eliminar equipo',
                          onPressed: () => confirmarEliminacion(equipo),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
