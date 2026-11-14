// Generates launcher icons, the Play Store icon and feature graphic, and
// crops raw emulator screenshots for the store.
//
//   flutter test tool/generate_store_assets_test.dart
//
// Raw screenshots (1080x2400 from the emulator) go in store/screenshots/raw/;
// 1200x2400 copies with side margins (Play's 2:1 limit) are written next to
// them.
import 'dart:io';
import 'dart:ui' as ui;
import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import 'brand.dart';

Future<void> _savePng(ui.Image image, String path) async {
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  await File(path).create(recursive: true);
  await File(path).writeAsBytes(bytes!.buffer.asUint8List());
}

Future<ui.Image> _draw(int w, int h, void Function(Canvas, Size) paint) {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  paint(canvas, Size(w.toDouble(), h.toDouble()));
  return recorder.endRecording().toImage(w, h);
}

void _background(Canvas c, Size s, {double radius = 0}) {
  final rect = Offset.zero & s;
  final paint = Paint()
    ..shader = ui.Gradient.linear(rect.topLeft, rect.bottomRight, [
      brandTeal,
      brandTealDark,
    ]);
  if (radius == 0) {
    c.drawRect(rect, paint);
  } else {
    c.drawRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius)), paint);
  }
}

const _densities = {
  'mdpi': 1.0,
  'hdpi': 1.5,
  'xhdpi': 2.0,
  'xxhdpi': 3.0,
  'xxxhdpi': 4.0,
};

void main() {
  const res = 'android/app/src/main/res';

  test('launcher icons', () async {
    await TestWidgetsFlutterBinding.ensureInitialized().runAsync(() async {
      for (final MapEntry(key: name, value: scale) in _densities.entries) {
        // Legacy icon (Android 7.x): 48dp rounded square.
        final legacy = (48 * scale).round();
        await _savePng(
          await _draw(legacy, legacy, (c, s) {
            _background(c, s, radius: s.width * 0.22);
            paintShieldPaw(c, Offset.zero & s);
          }),
          '$res/mipmap-$name/ic_launcher.png',
        );
        // Adaptive foreground (Android 8+): 108dp canvas, art inside the
        // 66dp safe zone.
        final fg = (108 * scale).round();
        await _savePng(
          await _draw(fg, fg, (c, s) {
            final inset = s.width * (21 / 108);
            paintShieldPaw(c, (Offset.zero & s).deflate(inset));
          }),
          '$res/mipmap-$name/ic_launcher_foreground.png',
        );
      }
    });
  });

  test('web app icons (home screen, manifest, favicon)', () async {
    await TestWidgetsFlutterBinding.ensureInitialized().runAsync(() async {
      // Full-bleed squares: iOS and Android round the corners themselves.
      for (final (size, path, inset) in [
        (192, 'web/icons/Icon-192.png', 0.08),
        (512, 'web/icons/Icon-512.png', 0.08),
        (192, 'web/icons/Icon-maskable-192.png', 0.18),
        (512, 'web/icons/Icon-maskable-512.png', 0.18),
        (180, 'web/icons/apple-touch-icon.png', 0.08),
        (32, 'web/favicon.png', 0.04),
      ]) {
        await _savePng(
          await _draw(size, size, (c, s) {
            _background(c, s);
            paintShieldPaw(c, (Offset.zero & s).deflate(size * inset));
          }),
          path,
        );
      }
    });
  });

  test('Play Store icon and feature graphic', () async {
    await TestWidgetsFlutterBinding.ensureInitialized().runAsync(() async {
      await _savePng(
        await _draw(512, 512, (c, s) {
          _background(c, s);
          paintShieldPaw(c, (Offset.zero & s).deflate(40));
        }),
        'store/icon-512.png',
      );

      final font = await File('tool/font_source/NotoSansTC-Regular.ttf')
          .readAsBytes();
      final loader = FontLoader('BrandFont')
        ..addFont(Future.value(ByteData.sublistView(Uint8List.fromList(font))));
      await loader.load();

      ui.Paragraph text(String s, double size, Color color) {
        final b =
            ui.ParagraphBuilder(
                ui.ParagraphStyle(fontFamily: 'BrandFont', fontSize: size),
              )
              ..pushStyle(ui.TextStyle(color: color, fontFamily: 'BrandFont'))
              ..addText(s);
        return b.build()..layout(const ui.ParagraphConstraints(width: 640));
      }

      await _savePng(
        await _draw(1024, 500, (c, s) {
          _background(c, s);
          paintShieldPaw(c, const Rect.fromLTWH(70, 70, 360, 360));
          c.drawParagraph(
            text('Pawdian', 88, const Color(0xFFFFFFFF)),
            const Offset(450, 120),
          );
          c.drawParagraph(
            text('毛孩守護', 64, const Color(0xFFFBF6EF)),
            const Offset(454, 235),
          );
          c.drawParagraph(
            text('疫苗・驅蟲・用藥提醒  Pet care reminders', 26, const Color(0xFFCFE9E0)),
            const Offset(456, 330),
          );
        }),
        'store/feature-graphic-1024x500.png',
      );
    });
  });

  test('crop screenshots to 2:1', () async {
    final raw = Directory('store/screenshots/raw');
    if (!raw.existsSync()) return;
    await TestWidgetsFlutterBinding.ensureInitialized().runAsync(() async {
      for (final f in raw.listSync().whereType<File>().where(
        (f) => f.path.endsWith('.png'),
      )) {
        final codec = await ui.instantiateImageCodec(await f.readAsBytes());
        final src = (await codec.getNextFrame()).image;
        // Play allows at most 2:1. Instead of cutting off the app bar or the
        // navigation bar, widen the canvas with brand-colored side margins.
        final h = src.height;
        final w = src.width < (h / 2).ceil() ? (h / 2).ceil() : src.width;
        final padded = await _draw(w, h, (c, s) {
          c.drawRect(Offset.zero & s, Paint()..color = const Color(0xFFFBF6EF));
          c.drawImage(
            src,
            Offset(((w - src.width) / 2).floorToDouble(), 0),
            Paint(),
          );
        });
        await _savePng(padded, p.join('store/screenshots', p.basename(f.path)));
      }
    });
  });
}
