import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:tombis_world/features/coloring/engine/coloring_operation_timeline.dart';
import 'package:tombis_world/features/coloring/models/brush_stroke.dart';
import 'package:tombis_world/features/coloring/models/eraser_stroke.dart';
import 'package:tombis_world/features/coloring/models/svg_color_region.dart';

void main() {
  const red = Color(0xFFFF0000);
  const blue = Color(0xFF0000FF);

  late ColoringOperationTimeline timeline;
  late SvgColorRegion region;
  late BrushStroke brushStroke;
  late EraserStroke eraserStroke;

  setUp(() {
    timeline = ColoringOperationTimeline();

    region = SvgColorRegion(
      id: 'region_1',
      path: Path()
        ..addRect(
          const Rect.fromLTWH(0, 0, 100, 100),
        ),
    );

    brushStroke = BrushStroke(
      path: Path()
        ..moveTo(10, 10)
        ..lineTo(50, 50),
      region: region,
      color: blue,
      width: 5.0,
    );

    eraserStroke = EraserStroke(
      path: Path()
        ..moveTo(20, 20)
        ..lineTo(40, 40),
      width: 10.0,
      region: region,
    );
  });

  int addFill() {
    return timeline.add(
      type: ColoringOperationType.fill,
      regionId: 'region_1',
      color: red,
    );
  }

  group('ColoringOperationTimeline', () {
    test('Timeline is initially empty', () {
      expect(timeline.operations, isEmpty);
    });

    test('Adds a fill operation with correct data', () {
      final order = addFill();

      expect(order, 1);
      expect(timeline.operations.length, 1);

      final operation = timeline.operations.single;

      expect(operation.order, 1);
      expect(operation.type, ColoringOperationType.fill);
      expect(operation.regionId, 'region_1');
      expect(operation.color, red);
    });

    test('Adds a brush operation with correct data', () {
      final order = timeline.add(
        type: ColoringOperationType.brush,
        brushStroke: brushStroke,
      );

      final operation = timeline.operations.single;

      expect(order, 1);
      expect(operation.type, ColoringOperationType.brush);
      expect(operation.brushStroke, same(brushStroke));
      expect(operation.brushStroke!.color, blue);
      expect(operation.brushStroke!.width, 5.0);
      expect(operation.brushStroke!.region, same(region));
    });

    test('Adds an eraser operation with correct data', () {
      final order = timeline.add(
        type: ColoringOperationType.eraser,
        eraserStroke: eraserStroke,
      );

      final operation = timeline.operations.single;

      expect(order, 1);
      expect(operation.type, ColoringOperationType.eraser);
      expect(operation.eraserStroke, same(eraserStroke));
      expect(operation.eraserStroke!.width, 10.0);
      expect(operation.eraserStroke!.region, same(region));
    });

    test('Operation order increases sequentially', () {
      expect(addFill(), 1);
      expect(addFill(), 2);
      expect(addFill(), 3);

      expect(
        timeline.operations.map((operation) => operation.order),
        orderedEquals([1, 2, 3]),
      );
    });

    test('Mixed operation types preserve their order', () {
      addFill();

      timeline.add(
        type: ColoringOperationType.brush,
        brushStroke: brushStroke,
      );

      timeline.add(
        type: ColoringOperationType.eraser,
        eraserStroke: eraserStroke,
      );

      addFill();

      expect(
        timeline.operations.map((operation) => operation.type),
        orderedEquals([
          ColoringOperationType.fill,
          ColoringOperationType.brush,
          ColoringOperationType.eraser,
          ColoringOperationType.fill,
        ]),
      );

      expect(
        timeline.operations.map((operation) => operation.order),
        orderedEquals([1, 2, 3, 4]),
      );
    });

    test('Removes only the requested operation', () {
      final first = addFill();
      final second = addFill();
      final third = addFill();

      expect(timeline.remove(second), isTrue);

      expect(
        timeline.operations.map((operation) => operation.order),
        orderedEquals([first, third]),
      );
    });

    test('Removing an unknown operation returns false', () {
      addFill();

      expect(timeline.remove(999), isFalse);
      expect(timeline.operations.length, 1);
    });

    test('An operation cannot be removed twice', () {
      final order = addFill();

      expect(timeline.remove(order), isTrue);
      expect(timeline.remove(order), isFalse);
      expect(timeline.operations, isEmpty);
    });

    test('Removed operation orders are not reused', () {
      addFill();
      final second = addFill();

      timeline.remove(second);

      final third = addFill();

      expect(third, 3);

      expect(
        timeline.operations.map((operation) => operation.order),
        orderedEquals([1, 3]),
      );
    });

    test('Clear removes operations and resets order', () {
      addFill();
      addFill();
      addFill();

      timeline.clear();

      expect(timeline.operations, isEmpty);

      final newOrder = addFill();

      expect(newOrder, 1);
      expect(timeline.operations.length, 1);
    });

    test('Operations list cannot be modified externally', () {
      addFill();

      final operations = timeline.operations;

      expect(
            () => operations.clear(),
        throwsUnsupportedError,
      );

      expect(timeline.operations.length, 1);
    });
  });
}
