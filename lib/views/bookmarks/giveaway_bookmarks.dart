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

import 'package:cached_network_image/cached_network_image.dart';
import 'package:humanizer/humanizer.dart';

import 'package:snag/common/vars/obx.dart';
import 'package:snag/nav/custom_nav.dart';
import 'package:snag/objectbox/giveaway_bookmark_model.dart';
import 'package:snag/views/giveaways/giveaway/giveaway.dart';
import 'package:snag/views/giveaways/giveaway/giveaway_theme.dart';

class GiveawayBookmarks extends StatefulWidget {
  const GiveawayBookmarks({super.key});

  @override
  State<GiveawayBookmarks> createState() => _GiveawayBookmarksState();
}

class _GiveawayBookmarksState extends State<GiveawayBookmarks> {
  List<GiveawayBookmarkModel> _bookmarks = [];

  @override
  void initState() {
    super.initState();
    _bookmarks = objectbox.getGiveawayBookmarks();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _bookmarks.length,
      itemBuilder: (BuildContext context, int index) {
        String remaining = '';
        bool ended = false;
        (remaining, ended) = _calcRemaining(_bookmarks[index].remainingStamp);
        return ListTile(
          contentPadding: CustomListTileTheme.contentPadding,
          minVerticalPadding: CustomListTileTheme.minVerticalPadding,
          dense: CustomListTileTheme.dense,
          selected: ended,
          selectedColor: Colors.grey[600],
          title: Text(_bookmarks[index].name,
              style: CustomListTileTheme.titleTextStyle,
              overflow: CustomListTileTheme.overflow),
          subtitle: Text(
              '${_calcSeconds(_bookmarks[index].agoStamp)} ago - $remaining',
              style: CustomListTileTheme.subtitleTextStyle),
          leading: SizedBox(
            width: CustomListTileTheme.leadingWidth,
            child: CachedNetworkImage(
              imageUrl:
                  'https://shared.akamai.steamstatic.com/store_item_assets/steam/${_bookmarks[index].type}s/${_bookmarks[index].appid}/capsule_184x69.jpg',
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
          ),
          onTap: () async {
            await customNav(
                Giveaway(href: '/giveaway/${_bookmarks[index].gaId}/'),
                context);
            _bookmarks = objectbox.getGiveawayBookmarks();
            setState(() {});
          },
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                child: SizedBox(
                    width: CustomListTileTheme.trailingWidth - 4,
                    height: CustomListTileTheme.trailingHeight,
                    child: Icon(
                        _bookmarks[index].favourite
                            ? Icons.star
                            : Icons.star_border,
                        size: CustomListTileTheme.iconSize + 7)),
                onTap: () {
                  objectbox.updateGiveawayBookmark(
                      id: _bookmarks[index].id,
                      gaId: _bookmarks[index].gaId,
                      name: _bookmarks[index].name,
                      type: _bookmarks[index].type,
                      appid: _bookmarks[index].appid,
                      agoStamp: _bookmarks[index].agoStamp,
                      remainingStamp: _bookmarks[index].remainingStamp,
                      favourite: !_bookmarks[index].favourite);
                  _bookmarks = objectbox.getGiveawayBookmarks();
                  setState(() {});
                },
              ),
              InkWell(
                child: SizedBox(
                    width: CustomListTileTheme.trailingWidth - 4,
                    height: CustomListTileTheme.trailingHeight,
                    child: const Icon(Icons.delete,
                        size: CustomListTileTheme.iconSize + 6)),
                onTap: () => showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete'),
                    content: Text.rich(
                        TextSpan(
                            text: 'Are you sure you want to delete the ',
                            children: [
                          TextSpan(
                              text: _bookmarks[index].name,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          TextSpan(text: ' bookmark?')
                        ])),
                    actions: [
                      TextButton(
                        child: const Text('Cancel'),
                        onPressed: () => Navigator.pop(context),
                      ),
                      TextButton(
                        child: const Text('Yes'),
                        onPressed: () {
                          objectbox
                              .removeGiveawayBookmark(_bookmarks[index].id);
                          _bookmarks = objectbox.getGiveawayBookmarks();
                          setState(() {});
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _calcSeconds(int seconds) => DateTime.timestamp()
      .difference(DateTime.fromMillisecondsSinceEpoch(seconds * 1000))
      .toApproximateTime(round: false, isRelativeToNow: false);

  (String, bool) _calcRemaining(int remainingStamp) {
    String remaining = _calcSeconds(remainingStamp);
    if (DateTime.timestamp()
        .isBefore(DateTime.fromMillisecondsSinceEpoch(remainingStamp * 1000))) {
      return ('$remaining remaining', false);
    } else {
      return ('Ended $remaining ago', true);
    }
  }
}
