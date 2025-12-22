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

import 'package:snag/common/custom_network_image.dart';
import 'package:snag/common/vars/obx.dart';
import 'package:snag/nav/custom_nav.dart';
import 'package:snag/objectbox/game_bookmark_model.dart';
import 'package:snag/views/giveaways/game.dart';
import 'package:snag/views/giveaways/giveaway/giveaway_theme.dart';

class GameBookmarks extends StatefulWidget {
  const GameBookmarks({super.key});

  @override
  State<GameBookmarks> createState() => _GameBookmarksState();
}

class _GameBookmarksState extends State<GameBookmarks> {
  List<GameBookmarkModel> _bookmarks = [];

  @override
  void initState() {
    super.initState();
    _bookmarks = objectbox.getGameBookmarks();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: _bookmarks.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
              leading: CustomNetworkImage(
                resize: true,
                url:
                    'https://shared.akamai.steamstatic.com/store_item_assets/steam/${_bookmarks[index].type}s/${_bookmarks[index].appid}/capsule_184x69.jpg',
                width: CustomListTileTheme.leadingWidth,
              ),
              title: Text(_bookmarks[index].name),
              onTap: () async {
                await customNav(
                    Game(
                      href: '/game/${_bookmarks[index].href}/',
                    ),
                    context);
                _bookmarks = objectbox.getGameBookmarks();
                setState(() {});
              },
              trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                            title: const Text('Delete'),
                            content: const Text(
                                'Are you sure you want to delete this bookmark?'),
                            actions: [
                              TextButton(
                                child: const Text('Cancel'),
                                onPressed: () => Navigator.pop(context),
                              ),
                              TextButton(
                                child: const Text('Yes'),
                                onPressed: () {
                                  objectbox.removeGameBookmark(_bookmarks[index].id);
                                  _bookmarks = objectbox.getGameBookmarks();
                                  setState(() {});
                                  Navigator.pop(context);
                                },
                              )
                            ],
                          ))));
        });
  }
}
