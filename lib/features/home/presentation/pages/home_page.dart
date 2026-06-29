import 'package:eventix/features/auth/presentation/providers/auth_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Placeholder temporal del home. En la Fase B se reemplaza por el listado
/// principal de eventos.
class HomePage extends ConsumerWidget {
  static const String routePath = '/home';

  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Eventix'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: () => ref.read(signOutProvider).call(),
          ),
        ],
      ),
      body: const Center(child: Text('Home — próximamente: eventos')),
    );
  }
}
