import 'package:app_ui_kit/app_ui_kit.dart';
import 'package:eventix/core/widgets/app_logo.dart';
import 'package:eventix/features/auth/di/auth_di.dart';
import 'package:eventix/features/auth/domain/enums/post_auth_destination.dart';
import 'package:eventix/features/auth/routes/post_auth_destination_routing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SplashPage extends ConsumerStatefulWidget {
  static const String routePath = '/';

  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _decideNextRoute());
  }

  Future<void> _decideNextRoute() async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;

    final PostAuthDestination destination = await ref
        .read(resolvePostAuthDestinationProvider)
        .call();
    if (!mounted) return;
    context.go(destination.routePath);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            AppLogo(size: 96),
            SizedBox(height: UiSpacing.large),
            UiLoader(),
          ],
        ),
      ),
    );
  }
}
