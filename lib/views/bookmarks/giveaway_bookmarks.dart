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
import 'package:provider/provider.dart';

import 'package:snag/common/vars/obx.dart';
import 'package:snag/nav/custom_nav.dart';
import 'package:snag/provider_models/giveaway_bookmarks_provider.dart';
import 'package:snag/views/giveaways/giveaway/giveaway.dart';
import 'package:snag/views/giveaways/giveaway/giveaway_theme.dart';

class GiveawayBookmarks extends StatefulWidget {
  const GiveawayBookmarks({super.key});

  @override
  State<GiveawayBookmarks> createState() => _GiveawayBookmarksState();
}

class _GiveawayBookmarksState extends State<GiveawayBookmarks> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<GiveawayBookmarksProvider>()
          .updateGiveawayBookmarks(objectbox.getGiveawayBookmarks());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GiveawayBookmarksProvider>(
        builder: (context, user, child) => ListView.builder(
              itemCount: user.giveaways.length,
              itemBuilder: (BuildContext context, int index) {
                String remaining = '';
                bool ended = false;
                (remaining, ended) =
                    _calcRemaining(user.giveaways[index].remainingStamp);
                return ListTile(
                  contentPadding: CustomListTileTheme.contentPadding,
                  minVerticalPadding: CustomListTileTheme.minVerticalPadding,
                  dense: CustomListTileTheme.dense,
                  selected: ended,
                  selectedColor: Colors.grey[600],
                  title: Text(user.giveaways[index].name,
                      style: CustomListTileTheme.titleTextStyle,
                      overflow: CustomListTileTheme.overflow),
                  subtitle: Text(
                      '${_calcSeconds(user.giveaways[index].agoStamp)} ago - $remaining',
                      style: CustomListTileTheme.subtitleTextStyle),
                  leading: SizedBox(
                    width: CustomListTileTheme.leadingWidth,
                    child: CachedNetworkImage(
                      imageUrl:
                          'https://shared.akamai.steamstatic.com/store_item_assets/steam/${user.giveaways[index].type}s/${user.giveaways[index].appid}/capsule_184x69.jpg',
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    ),
                  ),
                  onTap: () async {
                    await customNav(
                        Giveaway(
                            href: '/giveaway/${user.giveaways[index].gaId}/'),
                        context);
                    if (context.mounted) {
                      context
                          .read<GiveawayBookmarksProvider>()
                          .updateGiveawayBookmarks(
                              objectbox.getGiveawayBookmarks());
                    }
                  },
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        child: SizedBox(
                            width: CustomListTileTheme.trailingWidth - 4,
                            height: CustomListTileTheme.trailingHeight,
                            child: Icon(
                                user.giveaways[index].favourite
                                    ? Icons.star
                                    : Icons.star_border,
                                size: CustomListTileTheme.iconSize + 7)),
                        onTap: () {
                          objectbox.updateGiveawayBookmark(
                              id: user.giveaways[index].id,
                              gaId: user.giveaways[index].gaId,
                              name: user.giveaways[index].name,
                              type: user.giveaways[index].type,
                              appid: user.giveaways[index].appid,
                              agoStamp: user.giveaways[index].agoStamp,
                              remainingStamp:
                                  user.giveaways[index].remainingStamp,
                              favourite: !user.giveaways[index].favourite);
                          context
                              .read<GiveawayBookmarksProvider>()
                              .updateGiveawayBookmarks(
                                  objectbox.getGiveawayBookmarks());
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
                            content: Text.rich(TextSpan(
                                text: 'Are you sure you want to delete the ',
                                children: [
                                  TextSpan(
                                      text: user.giveaways[index].name,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)),
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
                                  objectbox.removeGiveawayBookmark(
                                      user.giveaways[index].id);
                                  context
                                      .read<GiveawayBookmarksProvider>()
                                      .updateGiveawayBookmarks(
                                          objectbox.getGiveawayBookmarks());
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
            ));
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
