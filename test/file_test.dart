import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {


  void printFiles(){

    final current = Directory.current;
    final assetPath = Directory(current.path + "/assets/markdowns");
    final dirs = assetPath.listSync();

    print(Directory.current);
    for (FileSystemEntity dir in dirs) {
      final file = File(dir.path);
      print(file.lastModifiedSync());
    }
  }


  test('测试文件输出', () {
    printFiles();
  });



}
