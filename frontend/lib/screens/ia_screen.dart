import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/ia_controller.dart';

class IaScreen extends StatefulWidget {
  const IaScreen({super.key});

  @override
  State<IaScreen> createState() => _IaScreenState();
}

class _IaScreenState extends State<IaScreen> {
  final TextEditingController preguntaController = TextEditingController();
  late final IaController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(IaController());
  }

  @override
  void dispose() {
    preguntaController.dispose();
    Get.delete<IaController>();
    super.dispose();
  }

  Future<void> enviarPregunta() async {
    FocusScope.of(context).unfocus();
    await controller.preguntar(preguntaController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Asistente IA')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.auto_awesome, size: 48, color: Colors.deepPurple),
            const SizedBox(height: 12),
            const Text(
              'Consulta tu inventario tecnológico',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Ejemplo: ¿Cuántos equipos están en mantenimiento?',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: preguntaController,
              maxLength: 300,
              maxLines: 3,
              minLines: 1,
              decoration: const InputDecoration(
                labelText: 'Escribe tu pregunta',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            Obx(
              () => FilledButton.icon(
                onPressed: controller.cargando.value ? null : enviarPregunta,
                icon: const Icon(Icons.send),
                label: Text(
                  controller.cargando.value
                      ? 'Consultando...'
                      : 'Preguntar a Gemini',
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Obx(() {
                if (controller.cargando.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.error.value.isNotEmpty) {
                  return Center(
                    child: Text(
                      controller.error.value,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                if (controller.respuesta.value.isEmpty) {
                  return const Center(
                    child: Text(
                      'La respuesta aparecerá aquí.',
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                return SingleChildScrollView(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: SelectableText(
                        controller.respuesta.value,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
