import 'package:flutter/material.dart';

/// Placeholder temporal del home. En la Fase B se reemplaza por el listado
/// principal de eventos.
class HomePage extends StatelessWidget {
  static const String routePath = '/home';

  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Eventix')),
      body: const Center(child: Text('Home — próximamente: eventos')),
    );
  }
}
