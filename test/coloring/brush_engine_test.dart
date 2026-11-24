import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:tombis_world/features/coloring/engine/brush_engine.dart';
import 'package:tombis_world/features/coloring/models/svg_color_region.dart';
import 'package:tombis_world/features/coloring/models/svg_coloring_document.dart';

void main() {
  const red = Color(0xFFFF0000);
  const blue = Color(0xFF0000FF);

  late BrushEngine engine;
  late SvgColorRegion firstRegion;
  late SvgColorRegion secondRegion;

  setUp(() {
    firstRegion = SvgColorRegion(
      id: 'region_1',
      path: Path()
        ..addRect(const Rect.fromLTWH(0, 0, 100, 100)),
    );

    secondRegion = SvgColorRegion(
      id: 'region_2',
      path: Path()
        ..addRect(const Rect.fromLTWH(100, 0, 100, 100)),
    );

    final document = SvgColoringDocument(
      size: const Size(200, 100),
      regions: [firstRegion, secondRegion],
      outline: Path(),
    );

    engine = BrushEngine(document: document);
  });

  bool startBrush() {
    return engine.startStroke(
      point: const Offset(50, 50),
      color: red,
      width: 10.0,
    );
  }

  group('BrushEngine', () {
    test('Engine is initially empty', () {
      expect(engine.strokes, isEmpty);
      expect(engine.activeStroke, isNull);
      expect(engine.isDrawing, isFalse);
    });

    test('Starts a stroke inside a valid region', () {
      expect(startBrush(), isTrue);
      expect(engine.isDrawing, isTrue);
      expect(engine.activeStroke, isNotNull);
      expect(engine.activeStroke!.region, same(firstRegion));
      expect(engine.activeStroke!.color, red);
      expect(engine.activeStroke!.width, 10.0);
      expect(engine.strokes, isEmpty);
    });

    test('Cannot start outside paintable regions', () {
      final result = engine.startStroke(
        point: const Offset(250, 250),
        color: red,
        width: 10.0,
      );

      expect(result, isFalse);
      expect(engine.isDrawing, isFalse);
      expect(engine.activeStroke, isNull);
    });

    test('Rejects zero and negative brush widths', () {
      for (final width in [0.0, -5.0]) {
        expect(
          engine.startStroke(
            point: const Offset(50, 50),
            color: red,
            width: width,
          ),
          isFalse,
        );
      }

      expect(engine.isDrawing, isFalse);
    });

    test('Cannot start another stroke while drawing', () {
      expect(startBrush(), isTrue);

      final originalStroke = engine.activeStroke;

      expect(
        engine.startStroke(
          point: const Offset(150, 50),
          color: blue,
          width: 20.0,
        ),
        isFalse,
      );

      expect(engine.activeStroke, same(originalStroke));
    });

    test('Cannot update without an active stroke', () {
      expect(
        engine.updateStroke(const Offset(60, 60)),
        isFalse,
      );
    });

    test('Ignores points below minimum distance', () {
      startBrush();

      expect(
        engine.updateStroke(const Offset(51, 50)),
        isFalse,
      );

      expect(
        engine.updateStroke(const Offset(52, 50)),
        isFalse,
      );

      expect(
        engine.updateStroke(const Offset(53, 50)),
        isTrue,
      );
    });

    test('Updates stroke path with valid points', () {
      startBrush();

      expect(
        engine.updateStroke(const Offset(80, 80)),
        isTrue,
      );

      final bounds = engine.activeStroke!.path.getBounds();

      expect(bounds.left, 50.0);
      expect(bounds.top, 50.0);
      expect(bounds.right, 80.0);
      expect(bounds.bottom, 80.0);
    });

    test('Stroke retains its original region', () {
      startBrush();

      expect(
        engine.updateStroke(const Offset(150, 50)),
        isTrue,
      );

      expect(
        engine.activeStroke!.region,
        same(firstRegion),
      );
    });

    test('Finishing a stroke saves it', () {
      startBrush();

      engine.updateStroke(const Offset(80, 80));

      final stroke = engine.finishStroke();

      expect(stroke, isNotNull);
      expect(engine.strokes.length, 1);
      expect(engine.strokes.single, same(stroke));
      expect(engine.activeStroke, isNull);
      expect(engine.isDrawing, isFalse);
    });

    test('Finishing without an active stroke returns null', () {
      expect(engine.finishStroke(), isNull);
      expect(engine.strokes, isEmpty);
    });

    test('Cancelling a stroke does not save it', () {
      startBrush();

      engine.updateStroke(const Offset(80, 80));
      engine.cancelStroke();

      expect(engine.activeStroke, isNull);
      expect(engine.isDrawing, isFalse);
      expect(engine.strokes, isEmpty);
      expect(engine.finishStroke(), isNull);
    });

    test('Multiple strokes preserve their order', () {
      startBrush();

      final firstStroke = engine.finishStroke();

      engine.startStroke(
        point: const Offset(150, 50),
        color: blue,
        width: 20.0,
      );

      final secondStroke = engine.finishStroke();

      expect(engine.strokes.length, 2);
      expect(engine.strokes[0], same(firstStroke));
      expect(engine.strokes[1], same(secondStroke));
      expect(engine.strokes[1].region, same(secondRegion));
      expect(engine.strokes[1].color, blue);
    });

    test('Removes only the requested stroke', () {
      startBrush();
      final firstStroke = engine.finishStroke()!;

      startBrush();
      final secondStroke = engine.finishStroke()!;

      expect(engine.removeStroke(firstStroke), isTrue);
      expect(engine.strokes.length, 1);
      expect(engine.strokes.single, same(secondStroke));
      expect(engine.removeStroke(firstStroke), isFalse);
    });

    test('Clear removes saved and active strokes', () {
      startBrush();
      engine.finishStroke();

      startBrush();

      engine.clear();

      expect(engine.strokes, isEmpty);
      expect(engine.activeStroke, isNull);
      expect(engine.isDrawing, isFalse);

      expect(startBrush(), isTrue);
    });

    test('Strokes list cannot be modified externally', () {
      startBrush();
      engine.finishStroke();

      expect(
            () => engine.strokes.clear(),
        throwsUnsupportedError,
      );

      expect(engine.strokes.length, 1);
    });
  });
}
