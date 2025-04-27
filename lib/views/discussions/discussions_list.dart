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
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';

import 'package:snag/common/functions/add_page.dart';
import 'package:snag/common/functions/fetch_body.dart';
import 'package:snag/common/functions/get_avatar.dart';
import 'package:snag/common/paged_progress_indicator.dart';
import 'package:snag/nav/custom_nav.dart';
import 'package:snag/provider_models/theme_provider.dart';
import 'package:snag/views/discussions/discussion.dart';
import 'package:snag/views/discussions/discussion_model.dart';
import 'package:snag/views/giveaways/giveaway/giveaway_theme.dart';
import 'package:snag/views/notifications/get_notifications.dart';

class DiscussionsList extends StatelessWidget {
  const DiscussionsList({required this.pagingController, super.key});

  final PagingController<int, DiscussionModel> pagingController;

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, theme, child) => PagedListView<int, DiscussionModel>(
        itemExtent:
            CustomPagedListTheme.itemExtent + addItemExtent(theme.fontSize),
        pagingController: pagingController,
        builderDelegate: PagedChildBuilderDelegate<DiscussionModel>(
          itemBuilder: (context, discussion, index) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                contentPadding: CustomListTileTheme.contentPadding,
                minVerticalPadding: CustomListTileTheme.minVerticalPadding,
                dense: CustomListTileTheme.dense,
                leading: SizedBox(
                  width: 40,
                  height: 40,
                  child: CachedNetworkImage(
                    imageUrl: discussion.avatar,
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                  ),
                ),
                title: Row(
                  children: [
                    discussion.closed
                        ? const Icon(
                            Icons.lock,
                            color: Colors.red,
                            size: 12,
                          )
                        : Container(),
                    discussion.poll
                        ? const Icon(
                            Icons.poll_outlined,
                            size: 14,
                            color: Colors.green,
                          )
                        : Container(),
                    Flexible(
                      child: Consumer<ThemeProvider>(
                        builder: (context, theme, child) => Text(
                          discussion.title,
                          style: TextStyle(
                              fontSize: CustomListTileTheme.titleTextSize +
                                  theme.fontSize),
                          overflow: CustomListTileTheme.overflow,
                        ),
                      ),
                    ),
                  ],
                ),
                subtitle: Consumer<ThemeProvider>(
                    builder: (context, theme, child) => Row(children: [
                          Text(
                            '${discussion.user} · ${discussion.topic} · C: ${discussion.created} ago${discussion.last} · ${discussion.comments} ',
                            style: TextStyle(
                                fontSize: CustomListTileTheme.subtitleTextSize +
                                    theme.fontSize / 2),
                          ),
                          Icon(Icons.comment_outlined,
                              size: CustomListTileTheme.iconSize -
                                  2 +
                                  theme.fontSize / 2),
                        ])),
                onTap: () =>
                    customNav(Discussion(href: discussion.href), context),
              ),
            ],
          ),
          newPageProgressIndicatorBuilder: (context) =>
              PagedProgressIndicator(),
        ),
      ),
    );
  }
}

Future<void> fetchDiscussions(
    {bool user = false,
    required PagingController<int, DiscussionModel> pagingController,
    required int pageKey,
    required String url,
    required BuildContext context}) async {
  String data = await fetchBody(url: '$url&page=${pageKey.toString()}');
  dom.Document document = parse(data);
  if (context.mounted) {
    getNotifications(document, context);
  }
  List<DiscussionModel> discussions = _parseDiscussionList(document);
  addPage(discussions, pagingController, pageKey,
      document.getElementsByClassName('widget-container').first);
}

List<DiscussionModel> _parseDiscussionList(dom.Document document) {
  List<DiscussionModel> discussions = [];
  document.getElementsByClassName('table__row-inner-wrap').forEach((element) {
    dom.Element heading =
        element.getElementsByClassName('table__column__heading')[0];
    List<dom.Element> secondary =
        element.getElementsByClassName('table__column__secondary-link');
    List<dom.Element> last =
        element.getElementsByClassName('table__column--width-fill text-right');
    discussions.add(DiscussionModel(
        title: heading.text,
        topic: secondary[0].text,
        user: secondary[1].text,
        href: heading.attributes['href']!,
        avatar: getAvatar(element, 'table_image_avatar'),
        closed: element
            .getElementsByClassName('icon-red icon-heading fa fa-lock')
            .isNotEmpty,
        comments: secondary[2].text,
        created: secondary[0].nextElementSibling!.text,
        last: last.isNotEmpty
            ? ' · L: ${last[0].nodes[1].text!.split(' ago').first} ago'
            : '',
        poll: element
            .getElementsByClassName('icon-heading fa fa-align-left')
            .isNotEmpty));
  });
  return discussions;
}
