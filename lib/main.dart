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

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

import 'package:snag/common/functions/fetch_body.dart';
import 'package:snag/common/functions/notification_permission.dart';
import 'package:snag/common/vars/obx.dart';
import 'package:snag/common/vars/prefs.dart';
import 'package:snag/objectbox/objectbox.dart';
import 'package:snag/provider_models/discussion_filter_provider.dart';
import 'package:snag/provider_models/entered_filter_provider.dart';
import 'package:snag/provider_models/gifts_provider.dart';
import 'package:snag/provider_models/giveaway_bookmarks_provider.dart';
import 'package:snag/provider_models/giveaway_filter_provider.dart';
import 'package:snag/provider_models/messages_provider.dart';
import 'package:snag/provider_models/points_provider.dart';
import 'package:snag/provider_models/won_provider.dart';
import 'package:snag/sg.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  objectbox = await ObjectBox.create();
  // make navigation bar transparent
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent,
    ),
  );
  // make flutter draw behind navigation bar
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  prefs = await SharedPreferences.getInstance();
  if (prefs.getString(PrefsKeys.sessid.key) == null) prefs.clear();
  if (prefs.getInt(PrefsKeys.gifts.key) == null) {
    prefs.setInt(PrefsKeys.gifts.key, 0);
  }
  if (prefs.getInt(PrefsKeys.won.key) == null) {
    prefs.setInt(PrefsKeys.won.key, 0);
  }
  if (prefs.getInt(PrefsKeys.messages.key) == null) {
    prefs.setInt(PrefsKeys.messages.key, 0);
  }
  if (prefs.getInt(PrefsKeys.pointLimit.key) == null) {
    prefs.setInt(PrefsKeys.pointLimit.key, 350);
  }
  if (prefs.getBool(PrefsKeys.pointsNotification.key) == null) {
    prefs.setBool(PrefsKeys.pointsNotification.key, true);
  }
  if (prefs.getString(PrefsKeys.frequency.key) != null) {
    if (prefs.getInt(PrefsKeys.backgroundFrequency.key) == null) {
      prefs.setInt(PrefsKeys.backgroundFrequency.key,
          int.parse(prefs.getString(PrefsKeys.frequency.key)!));
    }
  } else {
    prefs.setString(PrefsKeys.frequency.key, '15');
    prefs.setInt(PrefsKeys.backgroundFrequency.key, 15);
  }
  if (prefs.getBool(PrefsKeys.dynamicColor.key) == null) {
    prefs.setBool(PrefsKeys.dynamicColor.key, true);
  }
  if (prefs.getBool(PrefsKeys.keysAvailable.key) == null) {
    prefs.setBool(PrefsKeys.keysAvailable.key, false);
  }
  if (prefs.getInt(PrefsKeys.fontSize.key) == null) {
    prefs.setInt(PrefsKeys.fontSize.key, 0);
  }

  if (prefs.getString(PrefsKeys.sessid.key) != null) {
    bool notificationsDenied = await Permission.notification.isDenied;
    prefs.setBool(PrefsKeys.notificationsDenied.key, notificationsDenied);
    if (notificationsDenied) {
      Workmanager().cancelAll();
    } else {
      notificationPermission();
    }
  }
  if (prefs.getString(PrefsKeys.sessid.key) != null) {
    await fetchBody(
        url: 'https://www.steamgifts.com/about/brand-assets', firstCheck: true);
  }
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (_) => GiveawayFilterProvider()),
    ChangeNotifierProvider(create: (_) => EnteredFilterProvider()),
    ChangeNotifierProvider(create: (_) => DiscussionFilterProvider()),
    ChangeNotifierProvider(create: (_) => PointsProvider()),
    ChangeNotifierProvider(create: (_) => GiftsProvider()),
    ChangeNotifierProvider(create: (_) => WonProvider()),
    ChangeNotifierProvider(create: (_) => MessagesProvider()),
    ChangeNotifierProvider(create: (_) => GiveawayBookmarksProvider()),
  ], child: const SG()));
}
