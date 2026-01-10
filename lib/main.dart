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

import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

import 'package:snag/background_task.dart';
import 'package:snag/common/functions/get_user.dart';
import 'package:snag/common/vars/obx.dart';
import 'package:snag/common/vars/prefs.dart';
import 'package:snag/nav/pages.dart';
import 'package:snag/objectbox/objectbox.dart';
import 'package:snag/provider_models/discussion_filter_provider.dart';
import 'package:snag/provider_models/entered_filter_provider.dart';
import 'package:snag/provider_models/gifts_provider.dart';
import 'package:snag/provider_models/giveaway_bookmarks_provider.dart';
import 'package:snag/provider_models/giveaway_filter_provider.dart';
import 'package:snag/provider_models/messages_provider.dart';
import 'package:snag/provider_models/points_provider.dart';
import 'package:snag/provider_models/theme_provider.dart';
import 'package:snag/provider_models/won_provider.dart';
import 'package:snag/views/discussions/discussion.dart';
import 'package:snag/views/giveaways/entered/entered_list.dart';
import 'package:snag/views/giveaways/game.dart';
import 'package:snag/views/giveaways/giveaway/giveaway.dart';
import 'package:snag/views/misc/group.dart';
import 'package:snag/views/misc/login.dart';
import 'package:snag/views/misc/user.dart';
import 'package:snag/views/notifications/notification_destination.dart';
import 'package:snag/views/notifications/notifications.dart';
import 'package:snag/views/notifications/notifications_destination.dart';

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
  String destination = await _notificationDestination();

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
  if (prefs.getInt(PrefsKeys.intervalStart.key) == null) {
    prefs.setInt(PrefsKeys.intervalStart.key, 0);
    prefs.setInt(PrefsKeys.intervalEnd.key, 23);
  }

  if (prefs.getString(PrefsKeys.sessid.key) != null) {
    bool notificationsDenied = await Permission.notification.isDenied;
    prefs.setBool(PrefsKeys.notificationsDenied.key, notificationsDenied);
    if (notificationsDenied) {
      Workmanager().cancelAll();
    } else {
      backgroundTask();
    }
  }
  if (prefs.getString(PrefsKeys.sessid.key) != null) {
    await getUser();
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
    ChangeNotifierProvider(create: (_) => ThemeProvider()),
  ], child: Snag(destination: destination)));
}

Future<String> _notificationDestination() async {
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

class Snag extends StatefulWidget {
  const Snag({required this.destination, super.key});

  final String destination;

  @override
  State<Snag> createState() => SnagState();
}

class SnagState extends State<Snag> {
  final List<RouteBase> _routes = [];
  late GoRouter _router;

  @override
  void initState() {
    for (Pages item in PagesList.giveawaypages.pages) {
      _routes.add(_customGoRoute(item.route, GiveawayPages.widgetsMap[item.route]!));
    }
    for (Pages item in PagesList.discussionpages.pages) {
      _routes.add(_customGoRoute(item.route, DiscussionPages.widgetsMap[item.route]!));
    }
    _routes.add(_customGoRoute(NotificationsRoute.created.route,
        const Notifications(NotificationsDestination.created)));
    _routes.add(_customGoRoute(
        NotificationsRoute.won.route, const Notifications(NotificationsDestination.won)));
    _routes.add(_customGoRoute(NotificationsRoute.messages.route,
        const Notifications(NotificationsDestination.messages)));
    _routes.add(_customGoRoute(Entered.entered.route, const EnteredList()));
    _routes.add(_customGoRoute(LoginRoute.login.route, const Login()));
    _routes.add(_giveawayGoRoute('/:id'));
    _routes.add(_giveawayGoRoute('/:id/:name'));
    _routes.add(_discussionGoRoute('/:id'));
    _routes.add(_discussionGoRoute('/:id/:name'));
    _routes.add(_userGoRoute('/:id'));
    _routes.add(_userGoRoute('/:id/:name'));
    _routes.add(_groupGoRoute('/:id'));
    _routes.add(_groupGoRoute('/:id/:name'));
    _routes.add(_gameGoRoute('/:id'));
    _routes.add(_gameGoRoute('/:id/:name'));

    _router = GoRouter(initialLocation: widget.destination, routes: _routes);
    super.initState();
  }

  (ColorScheme light, ColorScheme dark) _generateDynamicColourSchemes(
      ColorScheme lightDynamic, ColorScheme darkDynamic) {
    var lightBase = ColorScheme.fromSeed(seedColor: lightDynamic.primary);
    var darkBase =
        ColorScheme.fromSeed(seedColor: darkDynamic.primary, brightness: Brightness.dark);

    var lightAdditionalColours = _extractAdditionalColours(lightBase);
    var darkAdditionalColours = _extractAdditionalColours(darkBase);

    var lightScheme = _insertAdditionalColours(lightBase, lightAdditionalColours);
    var darkScheme = _insertAdditionalColours(darkBase, darkAdditionalColours);

    return (lightScheme.harmonized(), darkScheme.harmonized());
  }

  List<Color> _extractAdditionalColours(ColorScheme scheme) => [
        scheme.surface,
        scheme.surfaceDim,
        scheme.surfaceBright,
        scheme.surfaceContainerLowest,
        scheme.surfaceContainerLow,
        scheme.surfaceContainer,
        scheme.surfaceContainerHigh,
        scheme.surfaceContainerHighest,
      ];

  ColorScheme _insertAdditionalColours(
          ColorScheme scheme, List<Color> additionalColours) =>
      scheme.copyWith(
        surface: additionalColours[0],
        surfaceDim: additionalColours[1],
        surfaceBright: additionalColours[2],
        surfaceContainerLowest: additionalColours[3],
        surfaceContainerLow: additionalColours[4],
        surfaceContainer: additionalColours[5],
        surfaceContainerHigh: additionalColours[6],
        surfaceContainerHighest: additionalColours[7],
      );

  ThemeData _customTheme({bool dark = false, required ColorScheme? colorScheme}) {
    ColorScheme scheme = colorScheme ??
        ColorScheme.fromSeed(
            brightness: dark ? Brightness.dark : Brightness.light,
            seedColor: const Color.fromARGB(255, 0, 83, 125));
    double fontSizeDelta = prefs.getInt(PrefsKeys.fontSize.key)!.toDouble();
    return ThemeData(
      textTheme: Theme.of(context).textTheme.apply(
            fontSizeDelta: fontSizeDelta,
            displayColor: scheme.onSurface,
            bodyColor: scheme.onSurface,
            decorationColor: scheme.onSurface,
          ),
      primaryTextTheme: Theme.of(context).primaryTextTheme.apply(
            fontSizeDelta: fontSizeDelta,
            displayColor: scheme.onPrimary,
            bodyColor: scheme.onPrimary,
            decorationColor: scheme.onPrimary,
          ),
      listTileTheme: Theme.of(context).listTileTheme.copyWith(
          contentPadding: EdgeInsets.zero,
          minLeadingWidth: 0,
          minVerticalPadding: 1 - fontSizeDelta,
          horizontalTitleGap: 10,
          minTileHeight: 0,
          titleTextStyle:
              TextStyle(fontSize: 16 + fontSizeDelta, color: scheme.onSurface),
          subtitleTextStyle:
              TextStyle(fontSize: 12 + fontSizeDelta, color: scheme.onSurface)),
      visualDensity: const VisualDensity(vertical: -4, horizontal: -4),
      colorScheme: scheme,
      useMaterial3: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(builder: (lightDynamic, darkDynamic) {
      ColorScheme lightScheme, darkScheme;
      if (lightDynamic != null && darkDynamic != null) {
        (lightScheme, darkScheme) =
            _generateDynamicColourSchemes(lightDynamic, darkDynamic);
      } else {
        lightScheme =
            ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 0, 83, 125));
        darkScheme = ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 0, 83, 125),
            brightness: Brightness.dark);
      }
      return Consumer<ThemeProvider>(
          builder: (context, theme, child) => MaterialApp.router(
              title: 'Snag',
              theme: _customTheme(colorScheme: theme.dynamicColor ? lightScheme : null),
              darkTheme: _customTheme(
                  colorScheme: theme.dynamicColor ? darkScheme : null, dark: true),
              themeMode: ThemeMode.system,
              themeAnimationDuration: Durations.short2,
              themeAnimationCurve: Curves.linear,
              routerConfig: _router));
    });
  }

  GoRoute _customGoRoute(String route, Widget page) {
    return GoRoute(
      path: route,
      pageBuilder: (context, state) => NoTransitionPage(key: UniqueKey(), child: page),
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
