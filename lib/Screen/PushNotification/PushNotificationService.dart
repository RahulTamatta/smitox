import 'dart:convert';
import 'dart:io';
import 'package:eshop_multivendor/Helper/routes.dart';
import 'package:eshop_multivendor/Provider/SettingProvider.dart';
import 'package:eshop_multivendor/Provider/UserProvider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../Helper/String.dart';
import '../../Provider/chatProvider.dart';
import '../../Provider/pushNotificationProvider.dart';
import '../../main.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
FirebaseMessaging messaging = FirebaseMessaging.instance;

class PushNotificationService {
  late BuildContext context;

  PushNotificationService({
    required this.context,
  });

  Future initialise() async {
    permission();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('mipmap/notification');
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();
    const DarwinInitializationSettings initializationSettingsMacOS =
        DarwinInitializationSettings();
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
      macOS: initializationSettingsMacOS,
    );

    flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse:
          (NotificationResponse notificationResponse) async {
        if (notificationResponse.payload != null) {
          List<String> pay = notificationResponse.payload!.split(',');
          if (pay[0] == 'products') {
            context.read<PushNotificationProvider>().getProduct(
                  pay[1],
                  0,
                  0,
                  true,
                  context,
                );
          } else if (pay[0] == 'categories') {
            if (dashboardPageState != null &&
                dashboardPageState!.currentState != null) {
              dashboardPageState!.currentState!.changeTabPosition(1);
            }

            /*Future.delayed(Duration.zero, () {
              tabController.animateTo(1);
            });*/
          } else if (pay[0] == 'wallet') {
            Routes.navigateToMyWalletScreen(context);
          } else if (pay[0] == 'order') {
            Routes.navigateToMyOrderScreen((context));
          } else if (pay[0] == 'ticket_message') {
            Routes.navigateToChatScreen(context, pay[1], '');
          } else if (pay[0] == 'ticket_status') {
            Routes.navigateToCustomerSupportScreen(context);
          } else if (pay[0] == 'notification_url') {
            String url = pay[2].toString();
            try {
              if (await canLaunchUrl(Uri.parse(url))) {
                await launchUrl(Uri.parse(url),
                    mode: LaunchMode.externalApplication);
              } else {
                throw 'Could not launch $url';
              }
            } catch (e) {
              throw 'Something went wrong';
            }
          } else {
            Routes.navigateToSplashScreen(context);
          }
        } else {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => MyApp(sharedPreferences: prefs),
            ),
          );
        }
      },
    );

    FirebaseMessaging.onMessage.listen(
      (RemoteMessage message) {
        UserProvider userProvider =
            Provider.of<UserProvider>(context, listen: false);
        var data = message.notification!;

        var title = data.title.toString();
        var body = data.body.toString();
        var image = message.data['image'] ?? '';

        var type = message.data['type'] ?? '';
        var id = '';
        id = message.data['type_id'] ?? '';
        var urlLink = message.data['link'] ?? '';

        if (type == 'ticket_status') {
          Routes.navigateToCustomerSupportScreen(context);
        } else if (type == 'ticket_message') {
          if (CUR_TICK_ID == id) {
            if (context.read<ChatProvider>().chatstreamdata != null) {
              var parsedJson = json.decode(message.data['chat']);
              parsedJson = parsedJson[0];

              Map<String, dynamic> sendata = {
                'id': parsedJson[ID],
                'title': parsedJson[TITLE],
                'message': parsedJson[MESSAGE],
                'user_id': parsedJson[USER_ID],
                'name': parsedJson[NAME],
                'date_created': parsedJson[DATE_CREATED],
                'attachments': parsedJson['attachments']
              };
              var chat = {};

              chat['data'] = sendata;
              if (parsedJson[USER_ID] != userProvider.userId) {
                context.read<ChatProvider>().chatstreamdata!.sink.add(
                      jsonEncode(chat),
                    );
              }
            }
          } else {
            if (image != null && image != 'null' && image != '') {
              generateImageNotication(title, body, image, type, id, urlLink);
            } else {
              generateSimpleNotication(title, body, type, id, urlLink);
            }
          }
        } else if (image != null && image != 'null' && image != '') {
          generateImageNotication(title, body, image, type, id, urlLink);
        } else {
          generateSimpleNotication(title, body, type, id, urlLink);
        }
      },
    );

    messaging.getInitialMessage().then(
      (RemoteMessage? message) async {
        bool back = await Provider.of<SettingProvider>(context, listen: false)
            .getPrefrenceBool(ISFROMBACK);

        if (message != null) {
          if (back) {
            var type = message.data['type'] ?? '';
            var id = '';
            id = message.data['type_id'] ?? '';
            String urlLink = message.data['link'] ?? '';

            if (type == 'products') {
              context.read<PushNotificationProvider>().getProduct(
                    id,
                    0,
                    0,
                    true,
                    context,
                  );
            } else if (type == 'categories') {
              if (dashboardPageState != null &&
                  dashboardPageState!.currentState != null) {
                dashboardPageState!.currentState!.changeTabPosition(1);
              }

              /*Future.delayed(Duration.zero, () {
              tabController.animateTo(1);
            });*/
            } else if (type == 'wallet') {
              Routes.navigateToMyWalletScreen(context);
            } else if (type == 'order') {
              Routes.navigateToMyOrderScreen(context);
            } else if (type == 'ticket_message') {
              Routes.navigateToChatScreen(
                context,
                id,
                '',
              );
            } else if (type == 'ticket_status') {
              Routes.navigateToCustomerSupportScreen(context);
            } else if (type == 'notification_url') {
              String url = urlLink.toString();
              try {
                if (await canLaunchUrl(Uri.parse(url))) {
                  await launchUrl(Uri.parse(url),
                      mode: LaunchMode.externalApplication);
                } else {
                  throw 'Could not launch $url';
                }
              } catch (e) {
                throw 'Something went wrong';
              }
            } else {
              Routes.navigateToSplashScreen(context);
            }
            Provider.of<SettingProvider>(context, listen: false)
                .setPrefrenceBool(ISFROMBACK, false);
          }
        }
      },
    );

    FirebaseMessaging.onMessageOpenedApp.listen(
      (RemoteMessage message) async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        var type = message.data['type'] ?? '';
        var id = '';

        id = message.data['type_id'] ?? '';
        String urlLink = message.data['link'];

        if (type == 'products') {
          context.read<PushNotificationProvider>().getProduct(
                id,
                0,
                0,
                true,
                context,
              );
        } else if (type == 'categories') {
          if (dashboardPageState != null &&
              dashboardPageState!.currentState != null) {
            dashboardPageState!.currentState!.changeTabPosition(1);
          }

          /*Future.delayed(Duration.zero, () {
              tabController.animateTo(1);
            });*/
        } else if (type == 'wallet') {
          Routes.navigateToMyWalletScreen(context);
        } else if (type == 'order') {
          Routes.navigateToMyOrderScreen(context);
        } else if (type == 'ticket_message') {
          Routes.navigateToChatScreen(
            context,
            id,
            '',
          );
        } else if (type == 'ticket_status') {
          Routes.navigateToCustomerSupportScreen(context);
        } else if (type == 'notification_url') {
          String url = urlLink.toString();
          try {
            if (await canLaunchUrl(Uri.parse(url))) {
              await launchUrl(Uri.parse(url),
                  mode: LaunchMode.externalApplication);
            } else {
              throw 'Could not launch $url';
            }
          } catch (e) {
            throw 'Something went wrong';
          }
        } else {
          Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => MyApp(
                sharedPreferences: prefs,
              ),
            ),
          );
        }
        Provider.of<SettingProvider>(context, listen: false)
            .setPrefrenceBool(ISFROMBACK, false);
      },
    );

    setDeviceToken();
  }

  setDeviceToken(
      {bool clearSesssionToken = false, SettingProvider? settingProvider}) {
    if (clearSesssionToken) {
      settingProvider ??= Provider.of<SettingProvider>(context, listen: false);
      settingProvider.setPrefrence(FCMTOKEN, '');
    }
    messaging.getToken().then(
      (token) async {
        context.read<PushNotificationProvider>().registerToken(token, context);
      },
    );
  }

  void permission() async {
    await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    await messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }
}

@pragma('vm:entry-point')
Future<dynamic> myBackgroundMessageHandler(RemoteMessage message) async {
  setPrefrenceBool(ISFROMBACK, true);
  return Future<void>.value();
}

Future<String> _downloadAndSaveImage(String url, String fileName) async {
  var directory = await getApplicationDocumentsDirectory();
  var filePath = '${directory.path}/$fileName';
  var response = await http.get(Uri.parse(url));

  var file = File(filePath);
  await file.writeAsBytes(response.bodyBytes);
  return filePath;
}

Future<void> generateImageNotication(String title, String msg, String image,
    String type, String id, String url) async {
  var largeIconPath = await _downloadAndSaveImage(image, 'largeIcon');
  var bigPicturePath = await _downloadAndSaveImage(image, 'bigPicture');
  var bigPictureStyleInformation = BigPictureStyleInformation(
      FilePathAndroidBitmap(bigPicturePath),
      hideExpandedLargeIcon: true,
      contentTitle: title,
      htmlFormatContentTitle: true,
      summaryText: msg,
      htmlFormatSummaryText: true);
  var androidPlatformChannelSpecifics = AndroidNotificationDetails(
    'big text channel id',
    'big text channel name',
    channelDescription: 'big text channel description',
    largeIcon: FilePathAndroidBitmap(largeIconPath),
    styleInformation: bigPictureStyleInformation,
    playSound: true,
  );
  var platformChannelSpecifics = NotificationDetails(
    android: androidPlatformChannelSpecifics,
  );
  await flutterLocalNotificationsPlugin.show(
    0,
    title,
    msg,
    platformChannelSpecifics,
    payload: '$type,$id,$url',
  );
}

Future<void> generateSimpleNotication(
    String title, String msg, String type, String id, String url) async {
  var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
    'your channel id',
    'your channel name',
    channelDescription: 'your channel description',
    importance: Importance.max,
    priority: Priority.high,
    ticker: 'ticker',
    playSound: true,
  );
  var iosDetail = const DarwinNotificationDetails();

  var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics, iOS: iosDetail);
  await flutterLocalNotificationsPlugin.show(
    0,
    title,
    msg,
    platformChannelSpecifics,
    payload: '$type,$id,$url',
  );
}
