import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tombis_world/features/coloring/engine/coloring_session.dart';
import 'package:tombis_world/features/coloring/engine/coloring_operation_timeline.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const assetPath = 'assets/test_coloring.svg';

  const white = Color(0xFFFFFFFF);
  const red = Color(0xFFFF0000);
  const blue = Color(0xFF0000FF);

  const firstPoint = Offset(50, 50);
  const secondPoint = Offset(150, 50);

  const testSvg = '''
<svg xmlns="http://www.w3.org/2000/svg"
     viewBox="0 0 200 100">
  <path id="region_1"
        fill="#FFFFFF"
        d="M 0 0 H 100 V 100 H 0 Z"/>
  <path id="region_2"
        fill="#FFFFFF"
        d="M 100 0 H 200 V 100 H 100 Z"/>
  <path id="outline"
        fill="#000000"
        d="M 99 0 H 101 V 100 H 99 Z"/>
</svg>
''';

  late ColoringSession session;

  setUp(() {
    session = ColoringSession();

    TestDefaultBinaryMessengerBinding
        .instance.defaultBinaryMessenger
        .setMockMessageHandler(
      'flutter/assets',
          (ByteData? message) async {
        if (message == null) return null;

        final key = utf8.decode(
          message.buffer.asUint8List(
            message.offsetInBytes,
            message.lengthInBytes,
          ),
        );

        if (key == assetPath) {
          return ByteData.sublistView(
            Uint8List.fromList(utf8.encode(testSvg)),
          );
        }

        return null;
      },
    );
  });

  tearDown(() {
    session.dispose();
    rootBundle.evict(assetPath);

    TestDefaultBinaryMessengerBinding
        .instance.defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', null);
  });

  Future<void> loadSession() async {
    await session.load(assetPath);

    expect(session.error, isNull);
    expect(session.document, isNotNull);
  }

  Color regionColor(int index) {
    return session.document!.regions[index].color;
  }

  void drawBrush() {
    expect(
      session.startStroke(
        point: firstPoint,
        color: blue,
        width: 10.0,
      ),
      isTrue,
    );

    expect(
      session.updateStroke(const Offset(80, 80)),
      isTrue,
    );

    expect(session.finishStroke(), isTrue);
  }

  void drawEraser() {
    expect(
      session.startEraser(
        point: firstPoint,
        width: 10.0,
      ),
      isTrue,
    );

    expect(
      session.updateEraser(const Offset(70, 70)),
      isTrue,
    );

    expect(session.finishEraser(), isTrue);
  }

  group('ColoringSession', () {
    test('Session is initially empty', () {
      expect(session.document, isNull);
      expect(session.isLoading, isFalse);
      expect(session.error, isNull);
      expect(session.canUndo, isFalse);
      expect(session.operations, isEmpty);
      expect(session.activeStroke, isNull);
      expect(session.activeEraser, isNull);
    });

    test('Operations are safe before loading', () {
      expect(session.fill(firstPoint, red), isFalse);
      expect(session.undo(), isFalse);

      expect(
        session.startStroke(
          point: firstPoint,
          color: blue,
          width: 10.0,
        ),
        isFalse,
      );

      expect(
        session.startEraser(
          point: firstPoint,
          width: 10.0,
        ),
        isFalse,
      );

      expect(session.finishStroke(), isFalse);
      expect(session.finishEraser(), isFalse);

      session.clear();

      expect(session.operations, isEmpty);
    });

    test('Loads a valid SVG document', () async {
      await loadSession();

      expect(session.isLoading, isFalse);
      expect(session.document!.regions.length, 2);
      expect(session.document!.size, const Size(200, 100));
      expect(regionColor(0), white);
      expect(regionColor(1), white);
      expect(session.canUndo, isFalse);
    });

    test('Handles missing SVG assets safely', () async {
      await session.load('assets/missing.svg');

      expect(session.isLoading, isFalse);
      expect(session.error, isNotNull);
      expect(session.document, isNull);
      expect(session.canUndo, isFalse);
      expect(session.operations, isEmpty);
    });

    test('Can recover after a loading error', () async {
      await session.load('assets/missing.svg');

      expect(session.error, isNotNull);

      await loadSession();

      expect(session.error, isNull);
      expect(session.document, isNotNull);
    });

    test('Fill updates only the selected region', () async {
      await loadSession();

      expect(session.fill(firstPoint, red), isTrue);

      expect(regionColor(0), red);
      expect(regionColor(1), white);
      expect(session.canUndo, isTrue);
      expect(session.operations.length, 1);

      final operation = session.operations.single;

      expect(operation.type, ColoringOperationType.fill);
      expect(operation.regionId, 'region_1');
      expect(operation.color, red);
    });

    test('Fill outside regions does not create history', () async {
      await loadSession();

      expect(
        session.fill(const Offset(300, 300), red),
        isFalse,
      );

      expect(session.operations, isEmpty);
      expect(session.canUndo, isFalse);
    });

    test('Consecutive duplicate fills are ignored', () async {
      await loadSession();

      expect(session.fill(firstPoint, red), isTrue);
      expect(session.fill(firstPoint, red), isFalse);

      expect(session.operations.length, 1);
    });

    test('Undo restores the previous fill color', () async {
      await loadSession();

      session.fill(firstPoint, red);
      session.fill(firstPoint, blue);

      expect(session.undo(), isTrue);
      expect(regionColor(0), red);

      expect(session.undo(), isTrue);
      expect(regionColor(0), white);

      expect(session.operations, isEmpty);
      expect(session.canUndo, isFalse);
    });

    test('Completed brush stroke creates an operation', () async {
      await loadSession();

      drawBrush();

      expect(session.activeStroke, isNull);
      expect(session.operations.length, 1);
      expect(session.canUndo, isTrue);

      final operation = session.operations.single;

      expect(operation.type, ColoringOperationType.brush);
      expect(operation.regionId, 'region_1');
      expect(operation.brushStroke, isNotNull);
      expect(operation.brushStroke!.color, blue);
      expect(operation.brushStroke!.order, operation.order);
    });

    test('Cancelled brush stroke creates no history', () async {
      await loadSession();

      session.startStroke(
        point: firstPoint,
        color: blue,
        width: 10.0,
      );

      session.updateStroke(const Offset(80, 80));
      session.cancelStroke();

      expect(session.activeStroke, isNull);
      expect(session.operations, isEmpty);
      expect(session.canUndo, isFalse);
    });

    test('Completed eraser stroke creates an operation', () async {
      await loadSession();

      drawEraser();

      expect(session.activeEraser, isNull);
      expect(session.operations.length, 1);
      expect(session.canUndo, isTrue);

      final operation = session.operations.single;

      expect(operation.type, ColoringOperationType.eraser);
      expect(operation.eraserStroke, isNotNull);
      expect(operation.eraserStroke!.region.id, 'region_1');
    });

    test('Cancelled eraser stroke creates no history', () async {
      await loadSession();

      session.startEraser(
        point: firstPoint,
        width: 10.0,
      );

      session.updateEraser(const Offset(70, 70));
      session.cancelEraser();

      expect(session.activeEraser, isNull);
      expect(session.operations, isEmpty);
      expect(session.canUndo, isFalse);
    });

    test('Mixed operations preserve their order', () async {
      await loadSession();

      session.fill(firstPoint, red);
      drawBrush();
      drawEraser();
      session.fill(secondPoint, blue);

      expect(
        session.operations.map((operation) => operation.type),
        orderedEquals([
          ColoringOperationType.fill,
          ColoringOperationType.brush,
          ColoringOperationType.eraser,
          ColoringOperationType.fill,
        ]),
      );

      expect(
        session.operations.map((operation) => operation.order),
        orderedEquals([1, 2, 3, 4]),
      );
    });

    test('Undo reverses mixed operations correctly', () async {
      await loadSession();

      session.fill(firstPoint, red);
      drawBrush();
      drawEraser();
      session.fill(secondPoint, blue);

      expect(session.undo(), isTrue);
      expect(regionColor(1), white);
      expect(session.operations.length, 3);

      expect(session.undo(), isTrue);
      expect(session.operations.length, 2);
      expect(
        session.operations.last.type,
        ColoringOperationType.brush,
      );

      expect(session.undo(), isTrue);
      expect(session.operations.length, 1);
      expect(
        session.operations.last.type,
        ColoringOperationType.fill,
      );

      expect(regionColor(0), red);

      expect(session.undo(), isTrue);
      expect(regionColor(0), white);
      expect(session.operations, isEmpty);
      expect(session.canUndo, isFalse);
      expect(session.undo(), isFalse);
    });

    test('Same color fill is allowed after a brush stroke', () async {
      await loadSession();

      session.fill(firstPoint, red);
      drawBrush();

      expect(session.fill(firstPoint, red), isTrue);
      expect(session.operations.length, 3);
      expect(
        session.operations.last.type,
        ColoringOperationType.fill,
      );

      expect(session.undo(), isTrue);
      expect(session.operations.length, 2);
      expect(regionColor(0), red);
      expect(
        session.operations.last.type,
        ColoringOperationType.brush,
      );
    });

    test('Same color fill is allowed after an eraser stroke', () async {
      await loadSession();

      session.fill(firstPoint, red);
      drawEraser();

      expect(session.fill(firstPoint, red), isTrue);
      expect(session.operations.length, 3);

      expect(session.undo(), isTrue);
      expect(regionColor(0), red);
      expect(
        session.operations.last.type,
        ColoringOperationType.eraser,
      );
    });

    test('Clear resets all coloring operations', () async {
      await loadSession();

      session.fill(firstPoint, red);
      session.fill(secondPoint, blue);

      drawBrush();
      drawEraser();

      session.clear();

      expect(regionColor(0), white);
      expect(regionColor(1), white);
      expect(session.operations, isEmpty);
      expect(session.canUndo, isFalse);
      expect(session.activeStroke, isNull);
      expect(session.activeEraser, isNull);
      expect(session.undo(), isFalse);
    });

    test('Clear cancels an active brush stroke', () async {
      await loadSession();

      session.startStroke(
        point: firstPoint,
        color: blue,
        width: 10.0,
      );

      expect(session.activeStroke, isNotNull);

      session.clear();

      expect(session.activeStroke, isNull);
      expect(session.finishStroke(), isFalse);
      expect(session.operations, isEmpty);
    });

    test('Clear cancels an active eraser stroke', () async {
      await loadSession();

      session.startEraser(
        point: firstPoint,
        width: 10.0,
      );

      expect(session.activeEraser, isNotNull);

      session.clear();

      expect(session.activeEraser, isNull);
      expect(session.finishEraser(), isFalse);
      expect(session.operations, isEmpty);
    });

    test('Coloring can continue after clearing', () async {
      await loadSession();

      session.fill(firstPoint, red);
      session.clear();

      expect(session.fill(secondPoint, blue), isTrue);
      expect(regionColor(1), blue);
      expect(session.operations.single.order, 1);
      expect(session.canUndo, isTrue);
    });

    test('Reloading resets the previous coloring session', () async {
      await loadSession();

      session.fill(firstPoint, red);
      drawBrush();
      drawEraser();

      await loadSession();

      expect(regionColor(0), white);
      expect(regionColor(1), white);
      expect(session.operations, isEmpty);
      expect(session.canUndo, isFalse);
      expect(session.activeStroke, isNull);
      expect(session.activeEraser, isNull);
    });
  });
}
