import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:tombis_world/features/coloring/engine/coloring_engine.dart';
import 'package:tombis_world/features/coloring/models/svg_color_region.dart';
import 'package:tombis_world/features/coloring/models/svg_coloring_document.dart';

void main() {
  const white = Color(0xFFFFFFFF);
  const red = Color(0xFFFF0000);
  const blue = Color(0xFF0000FF);

  late ColoringEngine engine;
  late SvgColorRegion firstRegion;
  late SvgColorRegion secondRegion;

  setUp(() {
    firstRegion = SvgColorRegion(
      id: 'region_1',
      path: Path()
        ..addRect(
          const Rect.fromLTWH(0, 0, 100, 100),
        ),
    );

    secondRegion = SvgColorRegion(
      id: 'region_2',
      path: Path()
        ..addRect(
          const Rect.fromLTWH(100, 0, 100, 100),
        ),
    );

    final document = SvgColoringDocument(
      size: const Size(200, 100),
      regions: [
        firstRegion,
        secondRegion,
      ],
      outline: Path(),
    );

    engine = ColoringEngine(document: document);
  });

  group('ColoringEngine', () {
    test('Regions are initially white', () {
      expect(firstRegion.color, white);
      expect(secondRegion.color, white);
      expect(engine.canUndo, isFalse);
      expect(engine.undoCount, 0);
    });

    test('Fills the selected region', () {
      final result = engine.fillRegion(
        point: const Offset(50, 50),
        color: red,
      );

      expect(result, isTrue);
      expect(firstRegion.color, red);
      expect(engine.undoCount, 1);
    });

    test('Filling one region does not affect another', () {
      engine.fillRegion(
        point: const Offset(50, 50),
        color: red,
      );

      expect(firstRegion.color, red);
      expect(secondRegion.color, white);
    });

    test('Finds the correct region at a point', () {
      expect(
        engine.getRegionAt(const Offset(50, 50)),
        same(firstRegion),
      );

      expect(
        engine.getRegionAt(const Offset(150, 50)),
        same(secondRegion),
      );
    });

    test('Does not fill outside the regions', () {
      final result = engine.fillRegion(
        point: const Offset(250, 250),
        color: red,
      );

      expect(result, isFalse);
      expect(firstRegion.color, white);
      expect(secondRegion.color, white);
      expect(engine.undoCount, 0);
    });

    test('Applying the same color does not add history', () {
      engine.fillRegion(
        point: const Offset(50, 50),
        color: red,
      );

      final result = engine.fillRegion(
        point: const Offset(50, 50),
        color: red,
      );

      expect(result, isFalse);
      expect(engine.undoCount, 1);
    });

    test('Undo restores the previous color', () {
      engine.fillRegion(
        point: const Offset(50, 50),
        color: red,
      );

      expect(engine.canUndo, isTrue);
      expect(engine.undo(), isTrue);
      expect(firstRegion.color, white);
      expect(engine.canUndo, isFalse);
    });

    test('Multiple undo operations restore colors in order', () {
      engine.fillRegion(
        point: const Offset(50, 50),
        color: red,
      );

      engine.fillRegion(
        point: const Offset(50, 50),
        color: blue,
      );

      expect(firstRegion.color, blue);
      expect(engine.undoCount, 2);

      expect(engine.undo(), isTrue);
      expect(firstRegion.color, red);

      expect(engine.undo(), isTrue);
      expect(firstRegion.color, white);

      expect(engine.undoCount, 0);
    });

    test('Undo returns false when history is empty', () {
      expect(engine.undo(), isFalse);
      expect(engine.canUndo, isFalse);
    });

    test('Reset restores all regions to white', () {
      engine.fillRegion(
        point: const Offset(50, 50),
        color: red,
      );

      engine.fillRegion(
        point: const Offset(150, 50),
        color: blue,
      );

      engine.resetColors();

      expect(firstRegion.color, white);
      expect(secondRegion.color, white);
    });

    test('Can fill a region without recording history', () {
      final result = engine.fillRegion(
        point: const Offset(50, 50),
        color: red,
        recordHistory: false,
      );

      expect(result, isTrue);
      expect(firstRegion.color, red);
      expect(engine.undoCount, 0);
      expect(engine.canUndo, isFalse);
    });
  });
}
