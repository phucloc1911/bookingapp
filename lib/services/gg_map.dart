import 'package:url_launcher/url_launcher.dart';

Future<void> openGoogleMap() async {
  
  final Uri googleMapUrl = Uri.parse("https://www.google.com/maps/search/?api=1&query=Khách+sạn+gần+đây");
  
  if (await canLaunchUrl(googleMapUrl)) {
    await launchUrl(googleMapUrl, mode: LaunchMode.externalApplication);
  } else {
    throw 'Không thể mở Bản đồ';
  }
}