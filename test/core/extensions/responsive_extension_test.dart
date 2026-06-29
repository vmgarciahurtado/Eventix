import 'package:flutter/material.dart';
import 'package:eventix/core/extensions/responsive_extension.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _buildSubject({
  required Size size,
  required Widget Function(BuildContext) builder,
}) {
  return MaterialApp(
    home: MediaQuery(
      data: MediaQueryData(size: size),
      child: Builder(builder: builder),
    ),
  );
}

void main() {
  group('ResponsiveContextX breakpoints', () {
    testWidgets(
      'given a screen width of 400 '
      'when isMobile is read '
      'then returns true and isTablet/isDesktop return false',
      (WidgetTester tester) async {
        bool? isMobile, isTablet, isDesktop;

        await tester.pumpWidget(
          _buildSubject(
            size: const Size(400, 800),
            builder: (BuildContext context) {
              isMobile = context.isMobile;
              isTablet = context.isTablet;
              isDesktop = context.isDesktop;
              return const SizedBox.shrink();
            },
          ),
        );

        expect(isMobile, isTrue);
        expect(isTablet, isFalse);
        expect(isDesktop, isFalse);
      },
    );

    testWidgets(
      'given a screen width of 700 '
      'when isTablet is read '
      'then returns true and isMobile/isDesktop return false',
      (WidgetTester tester) async {
        bool? isMobile, isTablet, isDesktop;

        await tester.pumpWidget(
          _buildSubject(
            size: const Size(700, 900),
            builder: (BuildContext context) {
              isMobile = context.isMobile;
              isTablet = context.isTablet;
              isDesktop = context.isDesktop;
              return const SizedBox.shrink();
            },
          ),
        );

        expect(isMobile, isFalse);
        expect(isTablet, isTrue);
        expect(isDesktop, isFalse);
      },
    );

    testWidgets(
      'given a screen width of 1300 '
      'when isDesktop is read '
      'then returns true and isMobile/isTablet return false',
      (WidgetTester tester) async {
        bool? isMobile, isTablet, isDesktop;

        await tester.pumpWidget(
          _buildSubject(
            size: const Size(1300, 900),
            builder: (BuildContext context) {
              isMobile = context.isMobile;
              isTablet = context.isTablet;
              isDesktop = context.isDesktop;
              return const SizedBox.shrink();
            },
          ),
        );

        expect(isMobile, isFalse);
        expect(isTablet, isFalse);
        expect(isDesktop, isTrue);
      },
    );

    testWidgets(
      'given a screen width of 599 (boundary below mobile) '
      'when isMobile is read '
      'then returns true',
      (WidgetTester tester) async {
        bool? isMobile;

        await tester.pumpWidget(
          _buildSubject(
            size: const Size(599, 800),
            builder: (BuildContext context) {
              isMobile = context.isMobile;
              return const SizedBox.shrink();
            },
          ),
        );

        expect(isMobile, isTrue);
      },
    );

    testWidgets(
      'given a screen width of 600 (mobile breakpoint) '
      'when isTablet is read '
      'then returns true',
      (WidgetTester tester) async {
        bool? isTablet;

        await tester.pumpWidget(
          _buildSubject(
            size: const Size(600, 800),
            builder: (BuildContext context) {
              isTablet = context.isTablet;
              return const SizedBox.shrink();
            },
          ),
        );

        expect(isTablet, isTrue);
      },
    );

    testWidgets(
      'given a screen width of 1240 (desktop breakpoint) '
      'when isDesktop is read '
      'then returns true',
      (WidgetTester tester) async {
        bool? isDesktop;

        await tester.pumpWidget(
          _buildSubject(
            size: const Size(1240, 900),
            builder: (BuildContext context) {
              isDesktop = context.isDesktop;
              return const SizedBox.shrink();
            },
          ),
        );

        expect(isDesktop, isTrue);
      },
    );
  });

  group('ResponsiveContextX.responsiveValue', () {
    testWidgets(
      'given all three values provided and width 400 '
      'when responsiveValue is called '
      'then returns the mobile value',
      (WidgetTester tester) async {
        int? value;

        await tester.pumpWidget(
          _buildSubject(
            size: const Size(400, 800),
            builder: (BuildContext context) {
              value = context.responsiveValue<int>(
                desktop: 3,
                tablet: 2,
                mobile: 1,
              );
              return const SizedBox.shrink();
            },
          ),
        );

        expect(value, 1);
      },
    );

    testWidgets(
      'given only desktop provided and width 400 '
      'when responsiveValue is called '
      'then falls back to the desktop value',
      (WidgetTester tester) async {
        int? value;

        await tester.pumpWidget(
          _buildSubject(
            size: const Size(400, 800),
            builder: (BuildContext context) {
              value = context.responsiveValue<int>(desktop: 3);
              return const SizedBox.shrink();
            },
          ),
        );

        expect(value, 3);
      },
    );
  });

  group('ResponsiveContextX screen dimensions', () {
    testWidgets(
      'given a MediaQuery with size 800x600 '
      'when screenWidth and screenHeight are read '
      'then return the correct dimensions',
      (WidgetTester tester) async {
        double? width, height;

        await tester.pumpWidget(
          _buildSubject(
            size: const Size(800, 600),
            builder: (BuildContext context) {
              width = context.screenWidth;
              height = context.screenHeight;
              return const SizedBox.shrink();
            },
          ),
        );

        expect(width, 800);
        expect(height, 600);
      },
    );
  });
}
