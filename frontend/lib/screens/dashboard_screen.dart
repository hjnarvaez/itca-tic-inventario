import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/equipos_controller.dart';
import '../models/resumen_inventario.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<EquiposController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard TIC'),
        actions: [
          IconButton(
            tooltip: 'Actualizar estadísticas',
            icon: const Icon(Icons.refresh),
            onPressed: controller.cargarEquipos,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.cargando.value && controller.equipos.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.error.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(controller.error.value),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: controller.cargarEquipos,
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          );
        }

        final resumen = ResumenInventario.desdeEquipos(controller.equipos);

        return RefreshIndicator(
          onRefresh: controller.cargarEquipos,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [DashboardContenido(resumen: resumen)],
          ),
        );
      }),
    );
  }
}

class DashboardContenido extends StatelessWidget {
  const DashboardContenido({super.key, required this.resumen});

  final ResumenInventario resumen;

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Resumen del inventario',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),

          Card(
            color: colores.primaryContainer,
            child: ListTile(
              leading: const Icon(Icons.inventory_2_outlined),
              title: const Text('Total de activos'),
              subtitle: Text('${resumen.total} equipos registrados'),
              trailing: Text(
                '${resumen.total}',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
          ),

          const SizedBox(height: 16),

          LayoutBuilder(
            builder: (context, constraints) {
              const espacio = 8.0;
              final anchoTarjeta = (constraints.maxWidth - espacio) / 2;

              return Wrap(
                spacing: espacio,
                runSpacing: espacio,
                children: [
                  SizedBox(
                    width: anchoTarjeta,
                    child: _TarjetaEstado(
                      titulo: 'Disponibles',
                      cantidad: resumen.disponibles,
                      icono: Icons.check_circle_outline,
                      color: Colors.green,
                    ),
                  ),
                  SizedBox(
                    width: anchoTarjeta,
                    child: _TarjetaEstado(
                      titulo: 'Asignados',
                      cantidad: resumen.asignados,
                      icono: Icons.person_outline,
                      color: Colors.blue,
                    ),
                  ),
                  SizedBox(
                    width: anchoTarjeta,
                    child: _TarjetaEstado(
                      titulo: 'Mantenimiento',
                      cantidad: resumen.mantenimiento,
                      icono: Icons.build_outlined,
                      color: Colors.orange,
                    ),
                  ),
                  SizedBox(
                    width: anchoTarjeta,
                    child: _TarjetaEstado(
                      titulo: 'Dados de baja',
                      cantidad: resumen.bajas,
                      icono: Icons.block_outlined,
                      color: Colors.red,
                    ),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 24),

          _SeccionDistribucion(
            titulo: 'Equipos por categoría',
            datos: resumen.porCategoria,
            total: resumen.total,
          ),

          const SizedBox(height: 16),

          _SeccionDistribucion(
            titulo: 'Equipos por ubicación',
            datos: resumen.porUbicacion,
            total: resumen.total,
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _TarjetaEstado extends StatelessWidget {
  const _TarjetaEstado({
    required this.titulo,
    required this.cantidad,
    required this.icono,
    required this.color,
  });

  final String titulo;
  final int cantidad;
  final IconData icono;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icono, color: color),
            const SizedBox(height: 4),
            Text('$cantidad', style: Theme.of(context).textTheme.headlineSmall),
            Text(
              titulo,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _SeccionDistribucion extends StatelessWidget {
  const _SeccionDistribucion({
    required this.titulo,
    required this.datos,
    required this.total,
  });

  final String titulo;
  final Map<String, int> datos;
  final int total;

  @override
  Widget build(BuildContext context) {
    final registros = datos.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(titulo, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),

            if (registros.isEmpty) const Text('Sin datos disponibles'),

            for (final registro in registros) ...[
              Builder(
                builder: (context) {
                  final porcentaje = total == 0 ? 0.0 : registro.value / total;

                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              registro.key,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '${registro.value} · '
                            '${(porcentaje * 100).toStringAsFixed(0)}%',
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      LinearProgressIndicator(
                        value: porcentaje,
                        minHeight: 10,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      const SizedBox(height: 14),
                    ],
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
