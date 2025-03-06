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

import 'package:snag/common/functions/button_background_color.dart';
import 'package:snag/nav/custom_back_appbar.dart';
import 'package:snag/views/bookmarks/discussion_bookmarks.dart';
import 'package:snag/views/bookmarks/game_bookmarks.dart';
import 'package:snag/views/bookmarks/giveaway_bookmarks.dart';
import 'package:snag/views/bookmarks/group_bookmarks.dart';
import 'package:snag/views/bookmarks/user_bookmarks.dart';

class Bookmarks extends StatefulWidget {
  const Bookmarks({super.key});

  @override
  State<Bookmarks> createState() => _BookmarksState();
}

class _BookmarksState extends State<Bookmarks> {
  _BookmarksDestination _destination = _BookmarksDestination.giveaways;
  late WidgetStateProperty<Color?> _bgColor;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _bgColor = buttonBackgroundColor(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomBackAppBar(name: 'Bookmarks'),
        body: Center(
            child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            TextButton(
              style: ButtonStyle(
                backgroundColor: _destination == _BookmarksDestination.giveaways
                    ? _bgColor
                    : null,
              ),
              child: const Text('Giveaways'),
              onPressed: () {
                setState(() {
                  _destination = _BookmarksDestination.giveaways;
                });
              },
            ),
            TextButton(
              style: ButtonStyle(
                backgroundColor:
                    _destination == _BookmarksDestination.discussions
                        ? _bgColor
                        : null,
              ),
              child: const Text('Discussions'),
              onPressed: () {
                setState(() {
                  _destination = _BookmarksDestination.discussions;
                });
              },
            ),
            TextButton(
                style: ButtonStyle(
                  backgroundColor: _destination == _BookmarksDestination.users
                      ? _bgColor
                      : null,
                ),
                onPressed: () {
                  setState(() {
                    _destination = _BookmarksDestination.users;
                  });
                },
                child: const Text('Users')),
            TextButton(
                style: ButtonStyle(
                  backgroundColor: _destination == _BookmarksDestination.games
                      ? _bgColor
                      : null,
                ),
                onPressed: () {
                  setState(() {
                    _destination = _BookmarksDestination.games;
                  });
                },
                child: const Text('Games')),
            TextButton(
                style: ButtonStyle(
                  backgroundColor: _destination == _BookmarksDestination.groups
                      ? _bgColor
                      : null,
                ),
                onPressed: () {
                  setState(() {
                    _destination = _BookmarksDestination.groups;
                  });
                },
                child: const Text('Groups')),
          ]),
          const Divider(height: 0),
          Flexible(child: _destination.destination)
        ])));
  }
}

enum _BookmarksDestination {
  giveaways(GiveawayBookmarks()),
  discussions(DiscussionBookmarks()),
  users(UserBookmarks()),
  games(GameBookmarks()),
  groups(GroupBookmarks());

  final Widget destination;
  const _BookmarksDestination(this.destination);
}
