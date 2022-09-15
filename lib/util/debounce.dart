/// 函数防抖
///
/// [func]: 要执行的方法
/// [delay]: 要迟延的时长
DateTime? lastTime;

void debounce(Function func, {Duration duration = Duration.zero}) {
  final cur = DateTime.now();
  if (lastTime == null) {
    func.call();
    lastTime = cur;
    return;
  }
  final diff = cur.difference(lastTime!);
  if (diff > duration) {
    func.call();
    lastTime = cur;
  }
}
