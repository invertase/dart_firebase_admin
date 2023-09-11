extension ObjectUtils<T> on T? {
  T orThrow(Never Function() thrower) => this ?? thrower();

  R? let<R>(R Function(T) block) {
    final that = this;
    return that == null ? null : block(that);
  }
}
