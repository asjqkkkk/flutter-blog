


import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';

import 'tencent_cos.dart';

void main(){






  test('测试put数据', () async{
    
    TencentCos cos = TencentCos.get();
    await cos.putObject('/blog_config/');
  });
}