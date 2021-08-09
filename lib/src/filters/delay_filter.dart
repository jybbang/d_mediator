import 'package:d_mediator/d_mediator.dart';

class DelayFilter with IMediatorFilter {
  final Duration duration;

  DelayFilter(this.duration);

  @override
  Future<bool?> filterAsync<T>(IRequest<T> request) async {
    await Future.delayed(duration);
    return Future.value(true);
  }
}
