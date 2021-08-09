mixin IRequestHandler<T, R> {
  Future<R> handle(T request);
}
