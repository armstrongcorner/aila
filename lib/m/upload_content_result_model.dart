import 'package:freezed_annotation/freezed_annotation.dart';

part 'upload_content_result_model.freezed.dart';
part 'upload_content_result_model.g.dart';

@freezed
class UploadContentResultModel with _$UploadContentResultModel {
  const factory UploadContentResultModel({
    @JsonKey(name: 'value') String? value,
    @JsonKey(name: 'failureReason') String? failureReason,
    @JsonKey(name: 'isSuccess') bool? isSuccess,
  }) = _UploadContentResultModel;

  factory UploadContentResultModel.fromJson(Map<String, dynamic> json) =>
      _$UploadContentResultModelFromJson(json);
}
