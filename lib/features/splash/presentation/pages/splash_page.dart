import 'package:flutter/material.dart';
import 'package:eventix/features/example/presentation/pages/examples_page.dart';
import 'package:go_router/go_router.dart';

class SplashPage extends StatefulWidget {
  static const String routePath = '/';

  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  @override
  void initState() {
    super.initState();
    Future<void>.delayed(
      const Duration(seconds: 2),
      () {
        if (mounted) context.go(ExamplesPage.routePath);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
