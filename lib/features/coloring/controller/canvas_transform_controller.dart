
import 'package:flutter/material.dart';

class CanvasTransformController {
  final TransformationController _transformationController =
  TransformationController();

  TransformationController get transformationController =>
      _transformationController;

  Offset toCanvasPoint(Offset viewportPoint) {
    return _transformationController.toScene(viewportPoint);
  }

  Offset toViewportPoint(Offset canvasPoint) {
    return MatrixUtils.transformPoint(
      _transformationController.value,
      canvasPoint,
    );
  }

  void reset() {
    _transformationController.value = Matrix4.identity();
  }

  double get scale {
    return _transformationController.value.getMaxScaleOnAxis();
  }

  void dispose() {
    _transformationController.dispose();
  }
}
