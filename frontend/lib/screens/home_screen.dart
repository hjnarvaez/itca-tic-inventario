import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'dashboard_screen.dart';

import '../controllers/auth_controller.dart';
import '../controllers/equipos_controller.dart';
import '../models/equipo.dart';
import 'equipo_form_screen.dart';
import 'ia_screen.dart';

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
            tooltip: 'Dashboard de inventario',
            icon: const Icon(Icons.dashboard_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const DashboardScreen()),
              );
            },
          ),
          IconButton(
            tooltip: 'Asistente IA',
            icon: const Icon(Icons.auto_awesome),
            onPressed: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => const IaScreen()));
            },
          ),
          Obx(
            () => IconButton(
              tooltip: 'Mostrar favoritos',
              icon: Icon(
                controller.soloFavoritos.value
                    ? Icons.favorite
                    : Icons.favorite_border,
              ),
              onPressed: controller.alternarFiltro,
            ),
          ),
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
      body: InventarioContenido(
        controller: controller,
        onAbrirEquipo: abrirFormulario,
        onEliminarEquipo: confirmarEliminacion,
      ),
    );
  }
}

class InventarioContenido extends StatefulWidget {
  const InventarioContenido({
    super.key,
    required this.controller,
    this.onAbrirEquipo,
    this.onEliminarEquipo,
  });

  final EquiposController controller;
  final ValueChanged<Equipo>? onAbrirEquipo;
  final ValueChanged<Equipo>? onEliminarEquipo;

  @override
  State<InventarioContenido> createState() => _InventarioContenidoState();
}

class _InventarioContenidoState extends State<InventarioContenido> {
  late final TextEditingController _busquedaController;

  @override
  void initState() {
    super.initState();
    _busquedaController = TextEditingController(
      text: widget.controller.busqueda.value,
    );
  }

  @override
  void dispose() {
    _busquedaController.dispose();
    super.dispose();
  }

  void _limpiarFiltros() {
    _busquedaController.clear();
    widget.controller.limpiarFiltros();
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;

    return Obx(() {
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

      final visibles = controller.equiposVisibles;
      final categorias = controller.categoriasDisponibles;
      final categoriaSeleccionada = controller.categoriaSeleccionada.value;
      final opcionesCategoria = <String>[
        'Todas',
        if (categoriaSeleccionada != 'Todas' &&
            !categorias.contains(categoriaSeleccionada))
          categoriaSeleccionada,
        ...categorias,
      ];

      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  key: const Key('busqueda-equipos'),
                  controller: _busquedaController,
                  onChanged: controller.actualizarBusqueda,
                  decoration: const InputDecoration(
                    labelText: 'Buscar equipos',
                    hintText: 'Código, nombre o ubicación',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                LayoutBuilder(
                  builder: (context, constraints) {
                    const espacio = 12.0;
                    final ancho = constraints.maxWidth >= 600
                        ? (constraints.maxWidth - espacio) / 2
                        : constraints.maxWidth;

                    return Wrap(
                      spacing: espacio,
                      runSpacing: espacio,
                      children: [
                        SizedBox(
                          width: ancho,
                          child: DropdownButtonFormField<String>(
                            key: ValueKey(
                              'estado-${controller.estadoSeleccionado.value}',
                            ),
                            initialValue: controller.estadoSeleccionado.value,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: 'Estado',
                              border: OutlineInputBorder(),
                            ),
                            items: EquiposController.estadosDisponibles
                                .map(
                                  (estado) => DropdownMenuItem(
                                    value: estado,
                                    child: Text(estado),
                                  ),
                                )
                                .toList(),
                            onChanged: (estado) {
                              if (estado != null) {
                                controller.seleccionarEstado(estado);
                              }
                            },
                          ),
                        ),
                        SizedBox(
                          width: ancho,
                          child: DropdownButtonFormField<String>(
                            key: ValueKey(
                              'categoria-$categoriaSeleccionada-'
                              '${opcionesCategoria.join('|')}',
                            ),
                            initialValue: categoriaSeleccionada,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: 'Categoría',
                              border: OutlineInputBorder(),
                            ),
                            items: opcionesCategoria
                                .map(
                                  (categoria) => DropdownMenuItem(
                                    value: categoria,
                                    child: Text(
                                      categoria,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (categoria) {
                              if (categoria != null) {
                                controller.seleccionarCategoria(categoria);
                              }
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      'Equipos encontrados: ${visibles.length}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    TextButton.icon(
                      key: const Key('limpiar-filtros'),
                      onPressed: controller.hayFiltrosActivos
                          ? _limpiarFiltros
                          : null,
                      icon: const Icon(Icons.filter_alt_off_outlined),
                      label: const Text('Limpiar filtros'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: visibles.isEmpty
                ? Center(child: Text(_mensajeSinResultados(controller)))
                : RefreshIndicator(
                    onRefresh: controller.cargarEquipos,
                    child: ListView.builder(
                      itemCount: visibles.length,
                      itemBuilder: (context, index) {
                        final equipo = visibles[index];

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
                            onTap: widget.onAbrirEquipo == null
                                ? null
                                : () => widget.onAbrirEquipo!(equipo),
                            trailing: SizedBox(
                              width: 104,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                    tooltip: 'Favorito',
                                    icon: Icon(
                                      controller.esFavorito(equipo.codigo)
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color:
                                          controller.esFavorito(equipo.codigo)
                                          ? Colors.red
                                          : null,
                                    ),
                                    onPressed: () {
                                      controller.cambiarFavorito(equipo.codigo);
                                    },
                                  ),
                                  IconButton(
                                    tooltip: 'Eliminar equipo',
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      color: Colors.red,
                                    ),
                                    onPressed: widget.onEliminarEquipo == null
                                        ? null
                                        : () =>
                                              widget.onEliminarEquipo!(equipo),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      );
    });
  }

  String _mensajeSinResultados(EquiposController controller) {
    if (controller.equipos.isEmpty) {
      return 'No hay equipos registrados';
    }

    final tieneFavoritos = controller.equipos.any(
      (equipo) => controller.esFavorito(equipo.codigo),
    );
    if (controller.soloFavoritos.value && !tieneFavoritos) {
      return 'No tienes equipos favoritos';
    }

    return 'No se encontraron equipos con los filtros seleccionados';
  }
}
