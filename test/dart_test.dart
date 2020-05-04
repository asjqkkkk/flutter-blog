import 'package:flutter_test/flutter_test.dart';

class A {
  String a = 'aaaa';

  void callA() {
    print('callA()');
  }
}

mixin C on A {
  String c = 'cccc';

  void callC() {
    print('callC()');
  }
}

class B extends A with C {
  void callB() {
    print('callB()');
    callA();
  }
}

void main() {
  test('测试', () {
    B b = B();
    b.callA();
  });
}
