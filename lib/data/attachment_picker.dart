import 'attachment_picker_native.dart'
    if (dart.library.js_interop) 'attachment_picker_web.dart'
    as implementation;
import 'models.dart';

Future<AttachmentMeta?> pickAttachment() =>
    implementation.pickPlatformAttachment();
