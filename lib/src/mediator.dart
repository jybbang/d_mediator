import 'package:async/async.dart';
import 'package:d_mediator/d_mediator.dart';

class Mediator {
  static final Mediator _mediator = Mediator._();

  final Map<Type, IRequestHandler> _handlers = <Type, IRequestHandler>{};
  final Map<Type, INotificationHandler> _notificationHandlers =
      <Type, INotificationHandler>{};
  IMediatorFilter? _filter;

  factory Mediator() {
    return _mediator;
  }

  Mediator._();

  Mediator addFilter(IMediatorFilter filter) {
    _filter = _filter?.addNextFilter(filter) ?? filter;
    return this;
  }

  Mediator addHandler<T extends IRequest<R>, R>(
      T request, IRequestHandler<T, R> handler) {
    _handlers[request.runtimeType] = handler;
    return this;
  }

  Mediator addNotificationHandler<T extends INotification>(
      T request, INotificationHandler<T> handler) {
    _notificationHandlers[request.runtimeType] = handler;
    return this;
  }

  CancelableOperation<R?> sendAsync<T extends IRequest<R>, R>(T request) {
    if (!_handlers.containsKey(request.runtimeType))
      throw HandlerNotFoundException();

    final handler = _handlers[request.runtimeType]! as IRequestHandler<T, R>;

    if (_filter == null) {
      return CancelableOperation<R?>.fromFuture(handler.handleAsync(request),
          onCancel: () => throw OperationCancelledException());
    } else {
      return _filter!.filterNextAsync(request).then(
          (canNext) => canNext == true
              ? handler.handleAsync(request)
              : Future.value(null),
          propagateCancel: true);
    }
  }

  CancelableOperation publishAsync<T extends INotification>(T request) {
    if (!_notificationHandlers.containsKey(request.runtimeType))
      throw HandlerNotFoundException();

    final handler =
        _notificationHandlers[request.runtimeType]! as INotificationHandler<T>;

    return CancelableOperation.fromFuture(handler.handleAsync(request),
        onCancel: () => throw OperationCancelledException());
  }
}
