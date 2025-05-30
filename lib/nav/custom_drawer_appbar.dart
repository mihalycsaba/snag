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

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:snag/nav/pages.dart';
import 'package:snag/provider_models/gifts_provider.dart';
import 'package:snag/provider_models/messages_provider.dart';
import 'package:snag/provider_models/points_provider.dart';
import 'package:snag/provider_models/theme_provider.dart';
import 'package:snag/provider_models/won_provider.dart';

class CustomDrawerAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomDrawerAppBar(
      {required this.name, required this.showPoints, this.filter, super.key})
      : preferredSize = const Size.fromHeight(kToolbarHeight);
  final String name;
  final bool showPoints;
  final Widget? filter;

  @override
  final Size preferredSize;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      title: Consumer<ThemeProvider>(
        builder: (context, theme, child) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: TextStyle(fontSize: 18.0 + theme.fontSize),
            ),
            showPoints
                ? Consumer<PointsProvider>(
                    builder: (context, user, child) => Text(
                      user.points.toString(),
                      style: TextStyle(fontSize: 12.0 + theme.fontSize),
                    ),
                  )
                : Container()
          ],
        ),
      ),
      actions: [
        Consumer<GiftsProvider>(
            builder: (context, user, child) => (user.gifts == '0')
                ? Container()
                : InkWell(
                    onTap: () => context.push(NotificationsRoute.created.route),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Badge.count(
                        count: int.parse(user.gifts),
                        child: FaIcon(FontAwesomeIcons.gift, size: 19),
                      ),
                    ))),
        Consumer<WonProvider>(
            builder: (context, user, child) => (user.won == '0')
                ? Container()
                : Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: InkWell(
                        onTap: () => context.push(NotificationsRoute.won.route),
                        child: Badge.count(
                          backgroundColor:
                              user.keysAvailable ? Colors.green.shade700 : null,
                          count: int.parse(user.won),
                          child: const Icon(Icons.emoji_events),
                        )),
                  )),
        Consumer<MessagesProvider>(
            builder: (context, user, child) => (user.messages == '0')
                ? Container()
                : Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: InkWell(
                      onTap: () => context.push(NotificationsRoute.messages.route),
                      child: Badge.count(
                        count: int.parse(user.messages),
                        child: const Icon(Icons.mail),
                      ),
                    ),
                  )),
        filter ?? Container(),
      ],
    );
  }
}
