mixin IRequestHandler<T, R> {
  Future<R> handleAsync(T request);
}
