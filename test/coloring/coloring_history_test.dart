
import 'package:flutter_test/flutter_test.dart';
import 'package:tombis_world/features/coloring/engine/coloring_history.dart';

void main() {
  late ColoringHistory history;

  setUp(() {
    history = ColoringHistory();
  });

  group('ColoringHistory', () {
    test('History is initially empty', () {
      expect(history.canUndo, isFalse);
      expect(history.undoCount, 0);
    });

    test('Undo returns false when history is empty', () {
      expect(history.undo(), isFalse);
      expect(history.undoCount, 0);
    });

    test('Recording an action updates history', () {
      history.record(() {});

      expect(history.canUndo, isTrue);
      expect(history.undoCount, 1);
    });

    test('Recording does not execute the undo action', () {
      bool executed = false;

      history.record(() {
        executed = true;
      });

      expect(executed, isFalse);
    });

    test('Undo executes the recorded action', () {
      int value = 10;

      history.record(() {
        value = 0;
      });

      expect(history.undo(), isTrue);
      expect(value, 0);
      expect(history.undoCount, 0);
      expect(history.canUndo, isFalse);
    });

    test('Undo actions execute in reverse order', () {
      final executedActions = <int>[];

      history.record(() => executedActions.add(1));
      history.record(() => executedActions.add(2));
      history.record(() => executedActions.add(3));

      expect(history.undo(), isTrue);
      expect(history.undo(), isTrue);
      expect(history.undo(), isTrue);

      expect(executedActions, [3, 2, 1]);
      expect(history.undoCount, 0);
      expect(history.canUndo, isFalse);
    });

    test('An undo action cannot execute twice', () {
      int executionCount = 0;

      history.record(() {
        executionCount++;
      });

      expect(history.undo(), isTrue);
      expect(history.undo(), isFalse);
      expect(executionCount, 1);
    });

    test('Clear removes history without executing actions', () {
      int executionCount = 0;

      history.record(() {
        executionCount++;
      });

      history.record(() {
        executionCount++;
      });

      history.clear();

      expect(history.undoCount, 0);
      expect(history.canUndo, isFalse);
      expect(history.undo(), isFalse);
      expect(executionCount, 0);
    });

    test('History can be reused after clearing', () {
      history.record(() {});
      history.clear();

      bool executed = false;

      history.record(() {
        executed = true;
      });

      expect(history.undoCount, 1);
      expect(history.canUndo, isTrue);
      expect(history.undo(), isTrue);
      expect(executed, isTrue);
    });

    test('History retains only the latest 100 actions', () {
      final executedActions = <int>[];

      expect(ColoringHistory.maxUndoSteps, 100);

      for (int i = 0; i < 105; i++) {
        history.record(() {
          executedActions.add(i);
        });
      }

      expect(history.undoCount, 100);

      for (int i = 0; i < 100; i++) {
        expect(history.undo(), isTrue);
      }

      expect(
        executedActions,
        List.generate(100, (index) => 104 - index),
      );

      expect(history.undoCount, 0);
      expect(history.canUndo, isFalse);
      expect(history.undo(), isFalse);
    });
  });
}
