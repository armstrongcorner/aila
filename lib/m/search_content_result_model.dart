import 'package:freezed_annotation/freezed_annotation.dart';

part 'search_content_result_model.freezed.dart';
part 'search_content_result_model.g.dart';

@freezed
class SearchContentResultModel with _$SearchContentResultModel {
  const factory SearchContentResultModel({
    @JsonKey(name: 'value') SearchContentModel? value,
    @JsonKey(name: 'failureReason') String? failureReason,
    @JsonKey(name: 'isSuccess') bool? isSuccess,
  }) = _SearchContentResultModel;

  factory SearchContentResultModel.fromJson(Map<String, dynamic> json) =>
      _$SearchContentResultModelFromJson(json);
}

@freezed
class SearchContentModel with _$SearchContentModel {
  const factory SearchContentModel({
    @JsonKey(name: 'id') String? id,
    @JsonKey(name: 'object') String? object,
    @JsonKey(name: 'created') String? created,
    @JsonKey(name: 'model') String? model,
    @JsonKey(name: 'usage') SearchResultUsage? usage,
    @JsonKey(name: 'choices') List<SearchResultChoice>? choices,
    @JsonKey(name: 'gptRequestTimeUTC') int? gptRequestTimeUTC,
    @JsonKey(name: 'gptResponseTimeUTC') int? gptResponseTimeUTC,
    @JsonKey(name: 'gptElapsedTimeInSec') double? gptElapsedTimeInSec,
  }) = _SearchContentModel;

  factory SearchContentModel.fromJson(Map<String, dynamic> json) =>
      _$SearchContentModelFromJson(json);
}

@freezed
class SearchResultUsage with _$SearchResultUsage {
  const factory SearchResultUsage({
    @JsonKey(name: 'prompt_tokens') String? promptTokens,
    @JsonKey(name: 'completion_tokens') String? completionTokens,
    @JsonKey(name: 'totaltokens') String? totalTokens,
  }) = _SearchResultUsage;

  factory SearchResultUsage.fromJson(Map<String, dynamic> json) =>
      _$SearchResultUsageFromJson(json);
}

@freezed
class SearchResultChoice with _$SearchResultChoice {
  const factory SearchResultChoice({
    @JsonKey(name: 'message') SearchResultMessage? message,
    @JsonKey(name: 'finish_reason') String? finishReason,
    @JsonKey(name: 'index') int? index,
  }) = _SearchResultChoice;

  factory SearchResultChoice.fromJson(Map<String, dynamic> json) =>
      _$SearchResultChoiceFromJson(json);
}

@freezed
class SearchResultMessage with _$SearchResultMessage {
  const factory SearchResultMessage({
    @JsonKey(name: 'role') String? role,
    @JsonKey(name: 'content') String? content,
  }) = _SearchResultMessage;

  factory SearchResultMessage.fromJson(Map<String, dynamic> json) =>
      _$SearchResultMessageFromJson(json);
}
