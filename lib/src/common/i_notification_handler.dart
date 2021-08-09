mixin INotificationHandler<T> {
  Future handle(T request);
}
