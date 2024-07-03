import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzl;
import 'package:timezone/timezone.dart' as tz;

class LocalNotificationServices {
  static final _localNotification = FlutterLocalNotificationsPlugin();

  static bool notificationsEnabled = false;

  static Future<void> requestPermission() async {
    if (Platform.isIOS || Platform.isMacOS) {
      // Agar IOS bo'lsa unda
      // shu kod orqali notification'ga ruxsat so'raymiz
      notificationsEnabled = await _localNotification
              .resolvePlatformSpecificImplementation<
                  IOSFlutterLocalNotificationsPlugin>()
              ?.requestPermissions(
                alert: true,
                badge: true,
                sound: true,
              ) ??
          false;

      // Agar MacOS bo'lsa unda
      // bu kod orqali notification'ga ruxsat so'raymiz
      await _localNotification
          .resolvePlatformSpecificImplementation<
              MacOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    } else if (Platform.isAndroid) {
      // Agar Android qurilma bo'lsa unda
      // bu kod orqali android notification sozlamasini olamiz
      final androidImplementation =
          _localNotification.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      // va bu yerda darhol xabarnomasiga ruxsat so'raymiz
      final bool? grantedNotificationPermission =
          await androidImplementation?.requestNotificationsPermission();

      // bu yerda esa rejali xabarnomaga ruxsat so'raymiz
      final bool? grantedScheduledNotificationPermission =
          await androidImplementation?.requestExactAlarmsPermission();
      // bu yerda o'zgaruvchiga belgilab qo'yapmiz foydalanuvchi ruxsat berdimi yoki yo'q
      notificationsEnabled = grantedNotificationPermission ?? false;
      notificationsEnabled = grantedScheduledNotificationPermission ?? false;
    }
  }

  static Future<void> start() async {
    // hozirgi joylashuv (timezone) bilan vaqtni oladi
    final currentTimeZone = await FlutterTimezone.getLocalTimezone();
    tzl.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation(currentTimeZone));

    // android va IOS uchun sozlamalarni to'g'irlaymiz
    const androidInit = AndroidInitializationSettings("notification_icon");
    final iosInit = DarwinInitializationSettings(
      notificationCategories: [
        DarwinNotificationCategory(
          'demoCategory',
          actions: <DarwinNotificationAction>[
            DarwinNotificationAction.plain('id_1', 'Action 1'),
            DarwinNotificationAction.plain(
              'id_2',
              'Action 2',
              options: <DarwinNotificationActionOption>{
                DarwinNotificationActionOption.destructive,
              },
            ),
            DarwinNotificationAction.plain(
              'id_3',
              'Action 3',
              options: <DarwinNotificationActionOption>{
                DarwinNotificationActionOption.foreground,
              },
            ),
          ],
          options: <DarwinNotificationCategoryOption>{
            DarwinNotificationCategoryOption.hiddenPreviewShowTitle,
          },
        )
      ],
    );

    // umumiy sozlamalarga e'lon qilaman
    final notificationInit = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    // va FlutterLocalNotification klasiga sozlamalarni yuboraman
    // u esa kerakli qurilma sozlamalarini to'g'irlaydi
    await _localNotification.initialize(notificationInit);
  }

  static void showNotification() async {
    // android va ios uchun qanday
    // turdagi xabarlarni ko'rsatish kerakligni aytamiz
    const androidDetails = AndroidNotificationDetails(
      "goodChannelId",
      "goodChannelName",
      importance: Importance.max,
      priority: Priority.min,
      playSound: true,
      sound: RawResourceAndroidNotificationSound("notification"),
      actions: [
        AndroidNotificationAction('id_1', 'Action 1'),
        AndroidNotificationAction('id_2', 'Action 2'),
        AndroidNotificationAction('id_3', 'Action 3'),
      ],
    );

    const iosDetails = DarwinNotificationDetails(
      // sound: "notification.aiff",
      categoryIdentifier: "demoCategory",
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // show funksiyasi orqali darhol xabarnoma ko'rsatamiz
    await _localNotification.show(
      0,
      "Birinchi NOTIFICATION",
      "Salom sizga \$1,000,000 pul tushdi. SMS kodni ayting!",
      notificationDetails,
    );
  }

  static void showScheduledNotification(
      int seconds, String title, int priority) async {
    // android va ios uchun qanday
    // turdagi xabarlarni ko'rsatish kerakligni aytamiz
    const androidDetails = AndroidNotificationDetails(
      "goodChannelId",
      "goodChannelName",
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
      sound: RawResourceAndroidNotificationSound("notification"),
      ticker: "Ticker",
    );

    const iosDetails = DarwinNotificationDetails(
        // sound: "notification.aiff",
        );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // show funksiyasi orqali darhol xabarnoma ko'rsatamiz
    await _localNotification.zonedSchedule(
      seconds,
      "new notifiaction with $priority priority",
      "$title is not completed yet",
      tz.TZDateTime.now(tz.local).add(const Duration(seconds: 3)),
      notificationDetails,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: "Salom",
    );
  }

  static void showPeriodicNotification() async {
    // android va ios uchun qanday
    // turdagi xabarlarni ko'rsatish kerakligni aytamiz
    const androidDetails = AndroidNotificationDetails(
      "goodChannelId",
      "goodChannelName",
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
      sound: RawResourceAndroidNotificationSound("notification"),
      ticker: "Ticker",
    );

    const iosDetails = DarwinNotificationDetails(
        // sound: "notification.aiff",
        );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // show funksiyasi orqali darhol xabarnoma ko'rsatamiz
    await _localNotification.periodicallyShowWithDuration(
      360000,
      "New notification from Todo App with priority",
      'Sizga yangi habar keldi',
      const Duration(days: 1),
      notificationDetails,
      payload: "Salom",
    );
  }
}
