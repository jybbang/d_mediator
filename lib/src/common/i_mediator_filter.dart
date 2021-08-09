import 'package:async/async.dart';
import 'package:d_mediator/d_mediator.dart';
import 'package:flutter/foundation.dart';

mixin IMediatorFilter {
  IMediatorFilter? _nextFilter;

  @protected
  Future<bool?> filterAsync<T>(IRequest<T> request);

  CancelableOperation<bool?> filterNextAsync<T>(IRequest<T> request) {
    var cancellable = CancelableOperation.fromFuture(filterAsync(request),
        onCancel: () => throw OperationCancelledException());

    return _nextFilter == null
        ? cancellable
        : cancellable.then(
            (canNext) => canNext == true
                ? _nextFilter!.filterNextAsync(request).valueOrCancellation()
                : Future.value(false),
            propagateCancel: true);
  }

  IMediatorFilter addNextFilter(IMediatorFilter filter) {
    _nextFilter = filter;
    return this;
  }
}
