import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/auth_controller.dart';
import '../controllers/equipos_controller.dart';
import '../models/equipo.dart';

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
      body: Obx(() {
        if (controller.cargando.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.error.value.isNotEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 56),
                  const SizedBox(height: 16),
                  Text(controller.error.value, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: controller.cargarEquipos,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          );
        }

        if (controller.equipos.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.inventory_2_outlined, size: 64),
                const SizedBox(height: 12),
                const Text('No hay equipos registrados'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: controller.cargarEquipos,
                  child: const Text('Actualizar'),
                ),
              ],
            ),
          );
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
                    return _EquipoCard(equipo: equipo);
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

class _EquipoCard extends StatelessWidget {
  final Equipo equipo;

  const _EquipoCard({required this.equipo});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.computer)),
        title: Text(
          equipo.nombre,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Código: ${equipo.codigo}'),
            Text('Categoría: ${equipo.categoria}'),
            Text('Ubicación: ${equipo.ubicacion}'),
          ],
        ),
        trailing: Text(
          equipo.estado,
          style: TextStyle(
            color: equipo.estado == 'Disponible'
                ? Colors.green.shade700
                : Colors.orange.shade800,
            fontSize: 12,
          ),
        ),
        isThreeLine: true,
      ),
    );
  }
}
