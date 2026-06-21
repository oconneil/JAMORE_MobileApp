import '../../domain/entities/hr_models.dart';

abstract interface class AttachmentPicker {
  Future<AttachmentMeta?> pick();
}
