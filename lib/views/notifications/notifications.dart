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

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:snag/common/functions/button_background_color.dart';
import 'package:snag/common/functions/initialize_notifications.dart';
import 'package:snag/common/functions/pop_nav.dart';
import 'package:snag/nav/pages.dart';
import 'package:snag/views/notifications/notifications_destination.dart';

class Notifications extends StatefulWidget {
  final NotificationsDestination destination;
  const Notifications(this.destination, {super.key});

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  late NotificationsDestination _destination;
  final FlutterLocalNotificationsPlugin _status = FlutterLocalNotificationsPlugin();
  late WidgetStateProperty<Color?> _bgColor;

  @override
  void initState() {
    _destination = widget.destination;
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _bgColor = buttonBackgroundColor(context);
  }

  @override
  Widget build(BuildContext context) {
    initializeNotifications(_status, context);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) =>
          popNav(context: context, didPop: didPop, route: GiveawayPages.all.route),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => popRoute(context: context, route: GiveawayPages.all.route),
          ),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text('Notifications'),
        ),
        body: Center(
            child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  style: ButtonStyle(
                    backgroundColor: _destination == NotificationsDestination.messages
                        ? _bgColor
                        : null,
                  ),
                  child: const Text('Messages'),
                  onPressed: () {
                    setState(() {
                      _destination = NotificationsDestination.messages;
                    });
                  },
                ),
                TextButton(
                  style: ButtonStyle(
                    backgroundColor:
                        _destination == NotificationsDestination.won ? _bgColor : null,
                  ),
                  child: const Text('Won'),
                  onPressed: () {
                    setState(() {
                      _destination = NotificationsDestination.won;
                    });
                  },
                ),
                TextButton(
                    style: ButtonStyle(
                      backgroundColor: _destination == NotificationsDestination.created
                          ? _bgColor
                          : null,
                    ),
                    child: const Text('Created'),
                    onPressed: () {
                      setState(() {
                        _destination = NotificationsDestination.created;
                      });
                    }),
              ],
            ),
            const Divider(height: 0),
            Flexible(
              child: _destination.destination,
            )
          ],
        )),
      ),
    );
  }
}
