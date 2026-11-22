
import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:path_drawing/path_drawing.dart';
import 'package:xml/xml.dart';

import '../models/svg_color_region.dart';
import '../models/svg_coloring_document.dart';

class SvgColoringParser {
  const SvgColoringParser();

  Future<SvgColoringDocument> parseAsset(
      String assetPath,
      ) async {
    final svgSource = await rootBundle.loadString(assetPath);

    return parse(svgSource);
  }

  SvgColoringDocument parse(String svgSource) {
    final xmlDocument = XmlDocument.parse(svgSource);
    final svg = xmlDocument.rootElement;

    final viewBox = svg.getAttribute('viewBox');

    if (viewBox == null) {
      throw const FormatException(
        'SVG viewBox bulunamadı.',
      );
    }

    final values = viewBox
        .trim()
        .split(RegExp(r'[\s,]+'))
        .map(double.parse)
        .toList();

    if (values.length != 4 ||
        values[2] <= 0 ||
        values[3] <= 0) {
      throw const FormatException(
        'Geçersiz SVG viewBox.',
      );
    }

    if (values[0] != 0 || values[1] != 0) {
      throw const FormatException(
        'Bu SVG viewBox başlangıcı desteklenmiyor.',
      );
    }

    final size = Size(values[2], values[3]);

    final regions = <SvgColorRegion>[];
    final outline = Path();
    final strokePaths = <Path>[];
    final strokeWidths = <double>[];
    final usedIds = <String>{};

    var outlineCount = 0;

    final pathElements = svg.descendants
        .whereType<XmlElement>()
        .where((element) => element.name.local == 'path');

    for (final element in pathElements) {
      final id = element.getAttribute('id');
      final pathData = element.getAttribute('d');

      if (id == null ||
          id.isEmpty ||
          pathData == null ||
          pathData.isEmpty) {
        throw const FormatException(
          'SVG path ID veya koordinat bilgisi eksik.',
        );
      }

      if (!usedIds.add(id)) {
        throw FormatException(
          'Tekrarlanan path ID: $id',
        );
      }

      final style = element.getAttribute('style') ?? '';

      final fill = _readFill(element, style);

      final path = parseSvgPathData(pathData);

      if (_isWhite(fill)) {
        regions.add(
          SvgColorRegion(
            id: id,
            path: path,
          ),
        );
      } else if (_isBlack(fill)) {
        outline.addPath(path, Offset.zero);
        outlineCount++;
      } else if (fill == 'none') {
        final stroke = _readStyleValue(element, style, 'stroke');
        final strokeWidthText =
        _readStyleValue(element, style, 'stroke-width');

        if (!_isBlack(stroke)) {
          throw FormatException(
            'Desteklenmeyen çizgi rengi: $id ($stroke)',
          );
        }

        final strokeWidth =
            double.tryParse(strokeWidthText) ?? 1.0;

        strokePaths.add(path);
        strokeWidths.add(strokeWidth);
        outlineCount++;
      } else {
        throw FormatException(
          'Desteklenmeyen path rengi: $id ($fill)',
        );
      }
    }

    if (regions.isEmpty || outlineCount == 0) {
      throw const FormatException(
        'Boyanabilir alan veya siyah kontur bulunamadı.',
      );
    }

    return SvgColoringDocument(
      size: size,
      regions: regions,
      outline: outline,
      strokePaths: strokePaths,
      strokeWidths: strokeWidths,
    );
  }

  String _readFill(
      XmlElement element,
      String style,
      ) {
    final directFill = element.getAttribute('fill');

    if (directFill != null) {
      return directFill.trim().toLowerCase();
    }

    final match = RegExp(
      r'(?:^|;)\s*fill\s*:\s*([^;]+)',
    ).firstMatch(style);

    return match?.group(1)?.trim().toLowerCase() ?? '';
  }

  bool _isWhite(String fill) {
    return fill == '#ffffff' ||
        fill == '#fff' ||
        fill == 'white';
  }

  bool _isBlack(String fill) {
    return fill == '#000000' ||
        fill == '#000' ||
        fill == 'black';
  }

  String _readStyleValue(
      XmlElement element,
      String style,
      String property,
      ) {
    final directValue = element.getAttribute(property);

    if (directValue != null) {
      return directValue.trim().toLowerCase();
    }

    final match = RegExp(
      '(?:^|;)\\s*${RegExp.escape(property)}\\s*:\\s*([^;]+)',
    ).firstMatch(style);

    return match?.group(1)?.trim().toLowerCase() ?? '';
  }
}
