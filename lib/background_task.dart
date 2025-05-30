// Copyright (C) 2025 Mihaly Csaba
//
// This file is part of Snag.
//
// Snag is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// Snag is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with Snag.  If not, see <https://www.gnu.org/licenses/>.

import 'dart:convert';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

import 'package:snag/common/functions/fetch_body.dart';
import 'package:snag/common/vars/prefs.dart';
import 'package:snag/views/notifications/notifications_model.dart';

void backgroundTask() async {
  if (await Permission.notification.request().isGranted) {
    Workmanager().cancelAll();
    Workmanager().initialize(_callbackDispatcher);
    Workmanager().registerPeriodicTask("bg", "simplePeriodicTask",
        frequency: Duration(minutes: prefs.getInt(PrefsKeys.backgroundFrequency.key)!),
        constraints: Constraints(
          networkType: NetworkType.connected,
          requiresBatteryNotLow: true,
          requiresStorageNotLow: true,
        ));
    prefs.setBool(PrefsKeys.notificationsDenied.key, false);
  }
}

@pragma('vm:entry-point')
void _callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    prefs = await SharedPreferences.getInstance();
    final int currentHour = DateTime.now().hour;
    if (currentHour >= prefs.getInt(PrefsKeys.intervalStart.key)! &&
        currentHour <= prefs.getInt(PrefsKeys.intervalEnd.key)!) {
      String data = await fetchBody(
          url:
              'https://www.steamgifts.com/account/settings/profile?format=json&include_notifications=1');
      Map<String, dynamic> json = jsonDecode(data);
      int points = json['user']['points'];
      bool pointsNotification = prefs.getBool(PrefsKeys.pointsNotification.key)!;
      int pointLimit = prefs.getInt(PrefsKeys.pointLimit.key)!;

      if (points < pointLimit && pointsNotification) {
        prefs.setBool(PrefsKeys.pointsNotification.key, false);
      }
      if (points >= pointLimit && !pointsNotification) {
        _showNotificationWithDefaultSound(
            0, 'Points', 'points', 'Points', points.toString());
        prefs.setBool(PrefsKeys.pointsNotification.key, true);
      }

      NotificationModel notifications = NotificationModel(
          json['user']['notifications']['giveaways_created'].toString(),
          json['user']['notifications']['giveaways_won'].toString(),
          json['user']['notifications']['messages'].toString(),
          json['user']['notifications']['unviewed_keys'] > 0);

      int gifts = int.parse(notifications.gifts);
      if (gifts == 0) {
        prefs.setInt(PrefsKeys.gifts.key, gifts);
      } else {
        if (gifts > prefs.getInt(PrefsKeys.gifts.key)!) {
          prefs.setInt(PrefsKeys.gifts.key, gifts);
          await Future.wait(
                  [fetchBody(url: 'https://www.steamgifts.com/giveaways/created')])
              .then((items) {
            _processValues(100, items[0], gifts, 'Created gift ended', true);
          });
        }
      }

      int won = int.parse(notifications.won);
      if (won == 0) {
        prefs.setInt(PrefsKeys.won.key, won);
      } else {
        if (won > prefs.getInt(PrefsKeys.won.key)!) {
          prefs.setInt(PrefsKeys.won.key, won);
          await Future.wait([fetchBody(url: 'https://www.steamgifts.com/giveaways/won')])
              .then((items) {
            _processValues(200, items[0], won, 'Won gift', true);
          });
        }
      }

      // if (keysAvailable) {
      //   prefs.setBool(PrefsKeys.keysAvailable.key, keysAvailable);
      //   await Future.wait([
      //     fetchBody(
      //         url: 'https://www.steamgifts.com/giveaways/won', context: null)
      //   ]).then((items) {});
      // }

      int messages = int.parse(notifications.messages);
      if (messages == 0) {
        prefs.setInt(PrefsKeys.messages.key, messages);
      } else {
        if (messages > prefs.getInt(PrefsKeys.messages.key)!) {
          prefs.setInt(PrefsKeys.messages.key, messages);
          await Future.wait([fetchBody(url: 'https://www.steamgifts.com/messages')])
              .then((items) {
            _processValues(300, items[0], messages, 'Messages', false);
          });
        }
      }
    }
    return await Future.value(true);
  });
}

void _processValues(int id, String data, int number, String key, bool gift) {
  List<_NotificationDetailsModel> notificationsList = [];
  for (int i = number - 1; i >= 0; i--) {
    if (gift) {
      _giftNotificationsList(notificationsList, data, i, key);
    } else {
      _messageNotificationsList(notificationsList, data, i);
    }
  }
  _showNotifications(notificationsList, id, key);
}

void _giftNotificationsList(List<_NotificationDetailsModel> notificationsList,
    String data, int i, String notification) {
  notificationsList.add(_NotificationDetailsModel(
      notification,
      parse(data)
          .getElementsByClassName('table__column--width-fill')[i + 1]
          .children[0]
          .text));
}

void _messageNotificationsList(
    List<_NotificationDetailsModel> notificationsList, String data, int i) {
  dom.Element message = parse(data).getElementsByClassName('comment__summary')[i];
  notificationsList.add(_NotificationDetailsModel(
      message.getElementsByClassName('comment__username')[0].text.trim(),
      message.getElementsByClassName('comment__description')[0].text.trim()));
}

void _showNotifications(
    List<_NotificationDetailsModel> notificationsList, int id, String key) {
  for (var element in notificationsList) {
    _showNotificationWithDefaultSound(id, key, key, element.name, element.value,
        group: true, groupKey: key);
    id++;
  }
  if (notificationsList.length > 1) {
    _showNotificationWithDefaultSound(id ~/ 100, key, key, key, key,
        group: true, summary: true, groupKey: key);
  }
}

Future _showNotificationWithDefaultSound(
    int id, String channelName, String channelId, String name, String value,
    {bool group = false, bool summary = false, String? groupKey}) async {
  FlutterLocalNotificationsPlugin status = FlutterLocalNotificationsPlugin();

  AndroidInitializationSettings android =
      const AndroidInitializationSettings('@drawable/ic_stat_notification');

  InitializationSettings settings = InitializationSettings(android: android);

  status.initialize(settings);

  if (summary) {
    AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
        channelId, channelName,
        groupKey: groupKey, setAsGroupSummary: true);
    NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);
    status.show(id, name, value, notificationDetails);
  } else {
    NotificationDetails platformChannelSpecifics =
        _notificationDetails(channelId, channelName, group, groupKey);
    await status.show(id, name, value, platformChannelSpecifics,
        payload: 'Default_Sound');
  }
}

NotificationDetails _notificationDetails(String channelId, String channelName, bool group,
    [String? groupKey]) {
  AndroidNotificationDetails androidPlatformChannelSpecifics;
  if (group) {
    androidPlatformChannelSpecifics =
        AndroidNotificationDetails(channelId, channelName, groupKey: groupKey);
  } else {
    androidPlatformChannelSpecifics = AndroidNotificationDetails(
      channelId,
      channelName,
    );
  }

  NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);
  return platformChannelSpecifics;
}

class _NotificationDetailsModel {
  String name;
  String value;
  _NotificationDetailsModel(this.name, this.value);
}
