import 'dart:async';

import 'package:app_ui_kit/app_ui_kit.dart';
import 'package:eventix/features/auth/presentation/providers/auth_providers.dart';
import 'package:eventix/features/home/presentation/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class _Slide {
  const _Slide({required this.icon, required this.title, required this.body});

  final IconData icon;
  final String title;
  final String body;
}

const List<_Slide> _slides = <_Slide>[
  _Slide(
    icon: Icons.explore_outlined,
    title: 'Descubre eventos',
    body: 'Explora conciertos, ferias y experiencias cerca de ti.',
  ),
  _Slide(
    icon: Icons.filter_alt_outlined,
    title: 'Filtra a tu medida',
    body: 'Encuentra eventos por categoría, fecha o ciudad.',
  ),
  _Slide(
    icon: Icons.confirmation_num_outlined,
    title: 'Reserva tus cupos',
    body: 'Aparta tus entradas y revisa tus reservas cuando quieras.',
  ),
];

class OnboardingPage extends ConsumerStatefulWidget {
  static const String routePath = '/onboarding';

  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final PageController _controller = PageController();
  int _index = 0;
  bool _finishing = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _isLast => _index == _slides.length - 1;

  void _next() {
    if (_isLast) {
      unawaited(_finish());
      return;
    }
    unawaited(
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      ),
    );
  }

  Future<void> _finish() async {
    if (_finishing) return;
    setState(() => _finishing = true);
    await ref.read(completeOnboardingProvider).call();
    if (!mounted) return;
    context.go(HomePage.routePath);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _finishing ? null : _finish,
                child: const Text('Saltar'),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _slides.length,
                onPageChanged: (int i) => setState(() => _index = i),
                itemBuilder: (BuildContext context, int i) {
                  final _Slide slide = _slides[i];
                  return Padding(
                    padding: const EdgeInsets.all(UiSpacing.xl),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          slide.icon,
                          size: 120,
                          color: context.colorScheme.primary,
                        ),
                        const SizedBox(height: UiSpacing.xl),
                        Text(
                          slide.title,
                          textAlign: TextAlign.center,
                          style: context.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: UiSpacing.sm),
                        Text(
                          slide.body,
                          textAlign: TextAlign.center,
                          style: context.textTheme.bodyLarge?.copyWith(
                            color: context.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List<Widget>.generate(
                _slides.length,
                (int i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: UiSpacing.xs),
                  width: i == _index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: i == _index
                        ? context.colorScheme.primary
                        : context.colorScheme.outlineVariant,
                    borderRadius: UiRadius.borderFull,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(UiSpacing.lg),
              child: UiButton(
                label: _isLast ? 'Comenzar' : 'Siguiente',
                expanded: true,
                loading: _finishing,
                onPressed: _next,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
