import '../../application/ports/attachment_picker.dart';
import '../../domain/entities/hr_models.dart';
import 'attachment_picker_native.dart'
    if (dart.library.js_interop) 'attachment_picker_web.dart'
    as implementation;

class PlatformAttachmentPicker implements AttachmentPicker {
  const PlatformAttachmentPicker();

  @override
  Future<AttachmentMeta?> pick() => implementation.pickPlatformAttachment();
}
