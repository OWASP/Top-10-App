import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:top_10_app/core/widgets.dart';

List<
  ({
    String label,
    bool selected,
    VoidCallback onSelected,
    Color accent,
    bool emphasized,
  })
>
_chips({required void Function(String label) onSelected, int count = 3}) {
  return <
    ({
      String label,
      bool selected,
      VoidCallback onSelected,
      Color accent,
      bool emphasized,
    })
  >[
    for (int i = 0; i < count; i++)
      (
        label: 'LIST ${i + 1}',
        selected: i == 0,
        accent: Colors.teal,
        emphasized: i == 2,
        onSelected: () => onSelected('LIST ${i + 1}'),
      ),
  ];
}

Widget _app(Widget child, {double textScale = 1}) {
  return MaterialApp(
    home: Scaffold(
      body: MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
        child: Padding(padding: const EdgeInsets.all(16), child: child),
      ),
    ),
  );
}

List<Size> _chipSizes(WidgetTester tester) {
  final Finder chips = find.byType(FilterChip);
  return <Size>[
    for (int i = 0; i < chips.evaluate().length; i++)
      tester.getSize(chips.at(i)),
  ];
}

void main() {
  testWidgets('chips share equal widths, three per row', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _app(EvenFilterChips(chips: _chips(onSelected: (_) {})), textScale: 1),
    );

    final List<Size> sizes = _chipSizes(tester);
    expect(sizes, hasLength(3));
    expect(sizes[1].width, sizes[0].width);
    expect(sizes[2].width, sizes[0].width);

    final Offset first = tester.getTopLeft(find.byType(FilterChip).at(0));
    final Offset second = tester.getTopLeft(find.byType(FilterChip).at(1));
    final Offset third = tester.getTopLeft(find.byType(FilterChip).at(2));
    expect(second.dy, first.dy);
    expect(third.dy, first.dy);
    expect(second.dx, greaterThan(first.dx));
    expect(third.dx, greaterThan(second.dx));
  });

  testWidgets('fourth chip wraps to a new row', (WidgetTester tester) async {
    await tester.pumpWidget(
      _app(
        EvenFilterChips(chips: _chips(onSelected: (_) {}, count: 4)),
        textScale: 1,
      ),
    );

    final List<Size> sizes = _chipSizes(tester);
    expect(sizes, hasLength(4));
    expect(sizes[3].width, sizes[0].width);
    expect(
      tester.getTopLeft(find.byType(FilterChip).at(3)).dy,
      greaterThan(tester.getTopLeft(find.byType(FilterChip).at(0)).dy),
    );
  });

  testWidgets('enlarged text uses two columns of equal width', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _app(EvenFilterChips(chips: _chips(onSelected: (_) {})), textScale: 1.3),
    );

    final List<Size> sizes = _chipSizes(tester);
    expect(sizes[1].width, sizes[0].width);
    expect(
      tester.getTopLeft(find.byType(FilterChip).at(1)).dy,
      tester.getTopLeft(find.byType(FilterChip).at(0)).dy,
    );
    expect(
      tester.getTopLeft(find.byType(FilterChip).at(2)).dy,
      greaterThan(tester.getTopLeft(find.byType(FilterChip).at(0)).dy),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('very large text uses one full-width column per chip', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _app(EvenFilterChips(chips: _chips(onSelected: (_) {})), textScale: 2),
    );

    final List<Size> sizes = _chipSizes(tester);
    expect(sizes, hasLength(3));
    expect(sizes[1].width, sizes[0].width);
    expect(sizes[2].width, sizes[0].width);
    expect(
      tester.getTopLeft(find.byType(FilterChip).at(1)).dy,
      greaterThan(tester.getTopLeft(find.byType(FilterChip).at(0)).dy),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('tapping a chip reports its label', (WidgetTester tester) async {
    String? tapped;
    await tester.pumpWidget(
      _app(
        EvenFilterChips(
          chips: _chips(onSelected: (String label) => tapped = label),
        ),
      ),
    );

    await tester.tap(find.text('LIST 2'));
    await tester.pump();

    expect(tapped, 'LIST 2');
  });

  testWidgets('no chips renders nothing', (WidgetTester tester) async {
    await tester.pumpWidget(_app(EvenFilterChips(chips: const [])));

    expect(find.byType(FilterChip), findsNothing);
  });
}
