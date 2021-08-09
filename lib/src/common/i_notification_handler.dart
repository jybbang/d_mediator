mixin INotificationHandler<T> {
  Future handleAsync(T request);
}
