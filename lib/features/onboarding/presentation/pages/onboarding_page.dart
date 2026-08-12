import 'dart:async';

import 'package:app_ui_kit/app_ui_kit.dart';
import 'package:eventix/core/extensions/localized_text_extension.dart';
import 'package:eventix/core/extensions/snackbar_extension.dart';
import 'package:eventix/core/l10n/app_localizations.dart';
import 'package:eventix/core/theme/app_icons.dart';
import 'package:eventix/features/app_config/domain/entities/onboarding_config.dart';
import 'package:eventix/features/app_config/presentation/providers/app_config_provider.dart';
import 'package:eventix/features/events/presentation/pages/events_page.dart';
import 'package:eventix/features/onboarding/presentation/providers/finish_onboarding_provider.dart';
import 'package:eventix/features/onboarding/presentation/widgets/onboarding_dots.dart';
import 'package:eventix/features/onboarding/presentation/widgets/onboarding_slide.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  static const String routePath = '/onboarding';

  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  static const Duration _pageAnimation = Duration(milliseconds: 300);

  final PageController _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next({required bool isLast}) {
    if (isLast) {
      unawaited(ref.read(finishOnboardingProvider.notifier).finish());
      return;
    }
    unawaited(
      _controller.nextPage(duration: _pageAnimation, curve: Curves.easeOut),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    // Cuántas láminas hay y qué dicen lo decide el JSON de configuración.
    final List<OnboardingSlideConfig> slides = ref
        .watch(appConfigProvider)
        .onboarding
        .slides;
    final bool isLast = _index == slides.length - 1;
    final bool finishing = ref.watch(finishOnboardingProvider).isLoading;

    ref.listen(finishOnboardingProvider, (
      AsyncValue<void>? previous,
      AsyncValue<void> next,
    ) {
      if (next.isLoading) return;
      // Se entra igual si el guardado falló: el onboarding se puede repetir y
      // no tiene sentido dejar al usuario atrapado aquí.
      if (next.hasError) context.showSnack(l10n.onboarding_save_error);
      context.go(EventsPage.routePath);
    });

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: finishing
                    ? null
                    : ref.read(finishOnboardingProvider.notifier).finish,
                child: Text(l10n.onboarding_skip),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (int i) => setState(() => _index = i),
                children: <Widget>[
                  for (final OnboardingSlideConfig slide in slides)
                    OnboardingSlide(
                      icon: AppIcons.of(slide.icon),
                      title: slide.title.of(context),
                      body: slide.body.of(context),
                    ),
                ],
              ),
            ),
            OnboardingDots(count: slides.length, index: _index),
            Padding(
              padding: const EdgeInsets.all(UiSpacing.large),
              child: UiButton(
                label: isLast ? l10n.onboarding_start : l10n.onboarding_next,
                expanded: true,
                loading: finishing,
                onPressed: () => _next(isLast: isLast),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
