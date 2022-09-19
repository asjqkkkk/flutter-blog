import 'package:url_launcher/url_launcher.dart';

/// false or throws a [PlatformException] depending on the failure.
Future<bool> toLaunch(String? url){
  final uri = Uri.tryParse(url ?? '');
  if(uri == null) print('Error: url:$url is not a correct link');
  return launchUrl(uri!);
}