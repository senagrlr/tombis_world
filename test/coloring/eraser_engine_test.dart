import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:tombis_world/features/coloring/engine/eraser_engine.dart';
import 'package:tombis_world/features/coloring/models/svg_color_region.dart';
import 'package:tombis_world/features/coloring/models/svg_coloring_document.dart';

void main() {
  late EraserEngine engine;
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

    engine = EraserEngine(document: document);
  });

  bool startEraser() {
    return engine.startStroke(
      point: const Offset(50, 50),
      width: 10.0,
    );
  }

  group('EraserEngine', () {
    test('Engine is initially empty', () {
      expect(engine.strokes, isEmpty);
      expect(engine.activeStroke, isNull);
      expect(engine.isErasing, isFalse);
    });

    test('Starts an eraser stroke inside a valid region', () {
      expect(startEraser(), isTrue);
      expect(engine.isErasing, isTrue);
      expect(engine.activeStroke, isNotNull);
      expect(engine.activeStroke!.region, same(firstRegion));
      expect(engine.activeStroke!.width, 10.0);
      expect(engine.strokes, isEmpty);
    });

    test('Cannot start outside paintable regions', () {
      final result = engine.startStroke(
        point: const Offset(250, 250),
        width: 10.0,
      );

      expect(result, isFalse);
      expect(engine.isErasing, isFalse);
      expect(engine.activeStroke, isNull);
    });

    test('Rejects zero and negative eraser widths', () {
      for (final width in [0.0, -5.0]) {
        expect(
          engine.startStroke(
            point: const Offset(50, 50),
            width: width,
          ),
          isFalse,
        );
      }

      expect(engine.isErasing, isFalse);
      expect(engine.activeStroke, isNull);
    });

    test('Cannot start another stroke while erasing', () {
      expect(startEraser(), isTrue);

      final originalStroke = engine.activeStroke;

      expect(
        engine.startStroke(
          point: const Offset(150, 50),
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
      startEraser();

      expect(EraserEngine.minPointDistance, 3.0);

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

    test('Updates eraser path with valid points', () {
      startEraser();

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

    test('Eraser stroke retains its original region', () {
      startEraser();

      expect(
        engine.updateStroke(const Offset(150, 50)),
        isTrue,
      );

      expect(
        engine.activeStroke!.region,
        same(firstRegion),
      );
    });

    test('Finishing an eraser stroke saves it', () {
      startEraser();

      engine.updateStroke(const Offset(80, 80));

      final stroke = engine.finishStroke();

      expect(stroke, isNotNull);
      expect(engine.strokes.length, 1);
      expect(engine.strokes.single, same(stroke));
      expect(engine.activeStroke, isNull);
      expect(engine.isErasing, isFalse);
    });

    test('Finishing without an active stroke returns null', () {
      expect(engine.finishStroke(), isNull);
      expect(engine.strokes, isEmpty);
    });

    test('Cancelling an eraser stroke does not save it', () {
      startEraser();

      engine.updateStroke(const Offset(80, 80));
      engine.cancelStroke();

      expect(engine.activeStroke, isNull);
      expect(engine.isErasing, isFalse);
      expect(engine.strokes, isEmpty);
      expect(engine.finishStroke(), isNull);
    });

    test('Multiple eraser strokes preserve their order', () {
      startEraser();

      final firstStroke = engine.finishStroke();

      engine.startStroke(
        point: const Offset(150, 50),
        width: 20.0,
      );

      final secondStroke = engine.finishStroke();

      expect(engine.strokes.length, 2);
      expect(engine.strokes[0], same(firstStroke));
      expect(engine.strokes[1], same(secondStroke));
      expect(engine.strokes[1].region, same(secondRegion));
      expect(engine.strokes[1].width, 20.0);
    });

    test('Removes only the requested eraser stroke', () {
      startEraser();
      final firstStroke = engine.finishStroke()!;

      startEraser();
      final secondStroke = engine.finishStroke()!;

      expect(engine.removeStroke(firstStroke), isTrue);
      expect(engine.strokes.length, 1);
      expect(engine.strokes.single, same(secondStroke));
      expect(engine.removeStroke(firstStroke), isFalse);
    });

    test('Clear removes saved and active eraser strokes', () {
      startEraser();
      engine.finishStroke();

      startEraser();

      engine.clear();

      expect(engine.strokes, isEmpty);
      expect(engine.activeStroke, isNull);
      expect(engine.isErasing, isFalse);

      expect(startEraser(), isTrue);
    });

    test('Eraser strokes list cannot be modified externally', () {
      startEraser();
      engine.finishStroke();

      expect(
            () => engine.strokes.clear(),
        throwsUnsupportedError,
      );

      expect(engine.strokes.length, 1);
    });
  });
}
