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

import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';

import 'package:snag/common/vars/prefs.dart';
import 'package:snag/common/vars/prefs_keys.dart';
import 'package:snag/nav/pages.dart';
import 'package:snag/views/discussions/discussion.dart';
import 'package:snag/views/giveaways/entered/entered_list.dart';
import 'package:snag/views/giveaways/giveaway/giveaway.dart';
import 'package:snag/views/giveaways/game.dart';
import 'package:snag/views/misc/group.dart';
import 'package:snag/views/misc/login.dart';
import 'package:snag/views/misc/user.dart';
import 'package:snag/views/notifications/notification_destination.dart';
import 'package:snag/views/notifications/notifications.dart';
import 'package:snag/views/notifications/notifications_destination.dart';

class SG extends StatefulWidget {
  const SG({super.key});

  static SGState? of(BuildContext context) =>
      context.findAncestorStateOfType<SGState>();

  @override
  State<SG> createState() => SGState();
}

class SGState extends State<SG> {
  void changeTheme(bool dynamicColor) {
    setState(() {
      prefs.setBool(PrefsKeys.dynamicColor.key, dynamicColor);
    });
  }

  Future<String> _checkNotification(BuildContext context) async {
    FlutterLocalNotificationsPlugin status = FlutterLocalNotificationsPlugin();
    status.initialize(const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    ));
    final NotificationAppLaunchDetails? notificationAppLaunchDetails =
        await status.getNotificationAppLaunchDetails();

    if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
      int id = notificationAppLaunchDetails?.notificationResponse?.id ?? 0;
      return notificationDestination(id);
    } else {
      return GiveawayPages.all.route;
    }
  }

  ThemeData _customTheme(
      {bool dark = false, required ColorScheme? colorScheme}) {
    return ThemeData(
      visualDensity: const VisualDensity(vertical: -4, horizontal: -4),
      colorScheme: colorScheme ??
          ColorScheme.fromSeed(
              brightness: dark ? Brightness.dark : Brightness.light,
              seedColor: const Color.fromARGB(255, 0, 40, 125)),
      useMaterial3: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool dynamicColor = prefs.getBool(PrefsKeys.dynamicColor.key)!;
    return DynamicColorBuilder(builder: (lightColorScheme, darkColorScheme) {
      return FutureBuilder(
          future: _checkNotification(context),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              List<RouteBase> routes = [];
              for (Pages item in PagesList.giveawaypages.pages) {
                routes.add(_customGoRoute(
                    item.route, GiveawayPages.widgetsMap[item.route]!));
              }
              for (Pages item in PagesList.discussionpages.pages) {
                routes.add(_customGoRoute(
                    item.route, DiscussionPages.widgetsMap[item.route]!));
              }
              routes.add(_customGoRoute(NotificationsRoute.created.route,
                  Notifications(NotificationsDestination.created)));
              routes.add(_customGoRoute(NotificationsRoute.won.route,
                  Notifications(NotificationsDestination.won)));
              routes.add(_customGoRoute(NotificationsRoute.messages.route,
                  Notifications(NotificationsDestination.messages)));
              routes.add(_customGoRoute(Entered.entered.route, EnteredList()));
              routes.add(_customGoRoute(LoginRoute.login.route, Login()));
              routes.add(_giveawayGoRoute('/:id'));
              routes.add(_giveawayGoRoute('/:id/:name'));
              routes.add(_discussionGoRoute('/:id'));
              routes.add(_discussionGoRoute('/:id/:name'));
              routes.add(_userGoRoute('/:id'));
              routes.add(_userGoRoute('/:id/:name'));
              routes.add(_groupGoRoute('/:id'));
              routes.add(_groupGoRoute('/:id/:name'));
              routes.add(_gameGoRoute('/:id'));
              routes.add(_gameGoRoute('/:id/:name'));

              final router =
                  GoRouter(initialLocation: snapshot.data, routes: routes);
              return MaterialApp.router(
                  title: 'SteamGifts',
                  theme: _customTheme(
                      colorScheme: dynamicColor ? lightColorScheme : null),
                  darkTheme: _customTheme(
                      colorScheme: dynamicColor ? darkColorScheme : null,
                      dark: true),
                  themeMode: ThemeMode.system,
                  themeAnimationDuration: Durations.short2,
                  themeAnimationCurve: Curves.linear,
                  routerConfig: router);
            } else {
              return Container();
            }
          });
    });
  }

  GoRoute _customGoRoute(String route, Widget page) {
    return GoRoute(
      path: route,
      pageBuilder: (context, state) =>
          NoTransitionPage(key: UniqueKey(), child: page),
    );
  }

  GoRoute _giveawayGoRoute(String route) {
    return GoRoute(
        path: '${GiveawayRoute.giveaway.route}$route',
        pageBuilder: (context, state) => NoTransitionPage(
            key: UniqueKey(),
            child: Giveaway(
                href:
                    "${GiveawayRoute.giveaway.route}/${state.pathParameters['id']!}/${state.pathParameters['name'] ?? ''}")));
  }

  GoRoute _discussionGoRoute(String route) {
    return GoRoute(
        path: '${DiscussionRoute.discussion.route}$route',
        pageBuilder: (context, state) => NoTransitionPage(
            key: UniqueKey(),
            child: Discussion(
                href:
                    "${DiscussionRoute.discussion.route}/${state.pathParameters['id']!}/${state.pathParameters['name'] ?? ''}")));
  }

  GoRoute _userGoRoute(String route) {
    return GoRoute(
        path: '${UserRoute.user.route}$route',
        pageBuilder: (context, state) => NoTransitionPage(
            key: UniqueKey(), child: User(name: state.pathParameters['id']!)));
  }

  GoRoute _groupGoRoute(String route) {
    return GoRoute(
        path: '${GroupRoute.group.route}$route',
        pageBuilder: (context, state) => NoTransitionPage(
            key: UniqueKey(),
            child: Group(
              href:
                  '${GroupRoute.group.route}/${state.pathParameters['id']}/${state.pathParameters['name'] ?? ''}',
            )));
  }

  GoRoute _gameGoRoute(String route) {
    return GoRoute(
        path: '${GameRoute.game.route}$route',
        pageBuilder: (context, state) => NoTransitionPage(
            key: UniqueKey(),
            child: Game(
              href:
                  '${GameRoute.game.route}/${state.pathParameters['id']}/${state.pathParameters['name'] ?? ''}',
            )));
  }
}
