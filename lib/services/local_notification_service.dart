import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';

class LocalNotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> showNotification(RemoteMessage message) async {
    // Extract the image URL from the data payload
    String? imageUrl = message.data['image'];

    // Convert image URL to Uint8List
    Uint8List? largeIcon;
    if (imageUrl != null && imageUrl.isNotEmpty) {
      largeIcon = await _downloadImage(imageUrl);
    }

    // Create notification details
    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'chat_channel',
      'Chats',
      channelDescription: 'Channel for chat notifications',
      importance: Importance.max,
      priority: Priority.high,
      styleInformation: const BigTextStyleInformation(''),
      largeIcon: largeIcon != null ? ByteArrayAndroidBitmap(largeIcon) : null,
    );

    NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);

    // Show the notification
    await flutterLocalNotificationsPlugin.show(
      0, // Notification ID
      message.notification?.title,
      message.notification?.body,
      notificationDetails,
    );
  }

  // Helper method to download image and convert it to Uint8List
  Future<Uint8List> _downloadImage(String url) async {
    final response = await http.get(Uri.parse(url));
    return response.bodyBytes;
  }

//   Future<Uint8List> _resizeAndCircleImage(Uint8List bytes) async {
//   // Decode the image from bytes
//   final image = img.decodeImage(bytes)!;

//   // Resize the image to a smaller size
//   final resizedImage = img.copyResize(image, width: 100, height: 100);

//   // Create a circular crop of the image with radius and antialias parameters
//   final circledImage = img.copyCrop(
//     resizedImage,
//     x: 0,
//     y: 0,
//     width: 100,
//     height: 100,
//     radius: 50, // Optional: adjust for circular effect
//     antialias: true,
//   );

//   // Encode the image back to bytes (Uint8List)
//   return Uint8List.fromList(img.encodePng(circledImage));
// }
}
