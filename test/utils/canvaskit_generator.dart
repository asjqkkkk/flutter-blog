// import 'dart:io';
//
// import 'package:flutter_test/flutter_test.dart';
// import 'package:http/http.dart';
// import 'package:new_web/config/api_strategy.dart';
// import 'package:path/path.dart' as p;
//
// import 'file_util.dart';
//
// class CanvasKitGenerator extends Generator{
//
//   @override
//   Future generatorJsonFile() async{
//     final current = Directory.current;
//     final canvasKitPath = Directory(p.join(current.path, 'web', 'canvas_kit'));
//     if(!canvasKitPath.existsSync()){
//       canvasKitPath.createSync(recursive: true);
//     }
//     const baseBinUrl = 'https://unpkg.com/canvaskit-wasm@0.35.0/bin/';
//     const js = 'canvaskit.js';
//     const wasm = 'canvaskit.wasm';
//     await downloadFile('$baseBinUrl$js', p.join(canvasKitPath.path, js));
//     await downloadFile('$baseBinUrl$wasm', p.join(canvasKitPath.path, wasm));
//   }
//
//   Future downloadFile(String url, String filePath) async{
//     try{
//       final Response jsData = await ApiStrategy.getApiService()!
//           .get(url)
//           .single;
//       final file = File(filePath);
//       if(!file.existsSync()){
//         file.createSync();
//       }
//       file.writeAsBytes(jsData.bodyBytes);
//       print('🎈 file [$filePath] download succeed 🎈');
//     } catch(e){
//       print('⚠ file [$filePath] download failed from [$url] ⚠');
//     }
//   }
//
// }
//
// void main() {
//   test('测试下载wasm文件', () async {
//     await CanvasKitGenerator().generatorJsonFile();
//   });
// }
