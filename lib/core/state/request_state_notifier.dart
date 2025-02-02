import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

part 'request_state_notifier.freezed.dart';

class RequestStateNotifier<T> extends StateNotifier<RequestState<T>> {
  RequestStateNotifier() : super(const RequestState.idle());

  Future<RequestState<T>> makeRequest(Future<T> Function() function) async {
    try {
      state = RequestState<T>.loading();
      final response = await function();
      final RequestState<T> newState = RequestState<T>.success(response);
      if (mounted) {
        state = newState;
      }
      return newState;
    } catch (e, st) {
      final RequestState<T> newState = RequestState<T>.error(e, st);
      if (mounted) {
        state = newState;
      }
      return newState;
    }
  }
}

@freezed
class RequestState<T> with _$RequestState<T> {
  const factory RequestState.idle() = Idle<T>;

  const factory RequestState.loading() = Loading<T>;

  const factory RequestState.success(T value) = Success<T>;

  const factory RequestState.error(Object error, StackTrace stackTrace) = Error<T>;
}
