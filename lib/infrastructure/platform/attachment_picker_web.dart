import 'dart:async';
import 'dart:js_interop';

import 'package:web/web.dart' as web;

import '../../domain/entities/hr_models.dart';

Future<AttachmentMeta?> pickPlatformAttachment() async {
  final input = web.document.createElement('input') as web.HTMLInputElement
    ..type = 'file'
    ..accept = '.pdf,.jpg,.jpeg,.png';
  final changed = Completer<void>();
  input.addEventListener('change', ((web.Event _) => changed.complete()).toJS);
  input.click();
  await changed.future;
  final file = input.files?.item(0);
  if (file == null || file.size > 5 * 1024 * 1024) return null;
  return AttachmentMeta(name: file.name, mime: file.type, bytes: file.size);
}
