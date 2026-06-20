import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppVersionText extends StatelessWidget {
  const AppVersionText({super.key, this.style});

  final TextStyle? style;
  static final Future<String> _version = _loadVersion();

  static Future<String> _loadVersion() async {
    final pubspec = await rootBundle.loadString('pubspec.yaml');
    return RegExp(
          r'^version:\s*([^\s]+)',
          multiLine: true,
        ).firstMatch(pubspec)?.group(1) ??
        '0.1.0+1';
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<String>(
    future: _version,
    initialData: '0.1.0+1',
    builder: (context, snapshot) => Text(snapshot.data!, style: style),
  );
}
