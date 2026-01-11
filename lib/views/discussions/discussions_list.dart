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

import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';

import 'package:snag/common/custom_network_image.dart';
import 'package:snag/common/functions/add_page.dart';
import 'package:snag/common/functions/fetch_body.dart';
import 'package:snag/common/functions/get_avatar.dart';
import 'package:snag/common/functions/resize_image.dart';
import 'package:snag/common/paged_progress_indicator.dart';
import 'package:snag/nav/custom_nav.dart';
import 'package:snag/provider_models/theme_provider.dart';
import 'package:snag/views/discussions/discussion.dart';
import 'package:snag/views/notifications/get_notifications.dart';

class DiscussionModel {
  String title;
  String href;
  String avatar;
  String user;
  String topic;
  bool closed;
  String comments;
  String created;
  String last;
  bool poll;
  DiscussionModel(
      {required this.title,
      required this.href,
      required this.avatar,
      required this.user,
      required this.topic,
      required this.closed,
      required this.comments,
      required this.created,
      required this.last,
      required this.poll});
}

class DiscussionsList extends StatelessWidget {
  const DiscussionsList({required this.pagingController, super.key});

  final PagingController<int, DiscussionModel> pagingController;

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, theme, child) => PagedListView<int, DiscussionModel>(
        pagingController: pagingController,
        builderDelegate: PagedChildBuilderDelegate<DiscussionModel>(
          itemBuilder: (context, discussion, index) => Card(
              child: InkWell(
                  onTap: () => customNav(Discussion(href: discussion.href), context),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomNetworkImage(
                                image: resizeImage(discussion.avatar, 64),
                                width: 56.0 + theme.fontSize),
                            Row(
                              children: [
                                Icon(
                                  Icons.comment_outlined,
                                  size: 14.0 + theme.fontSize,
                                ),
                                const SizedBox(width: 2),
                                Text(discussion.comments,
                                    style: TextStyle(fontSize: 12.0 + theme.fontSize)),
                              ],
                            ),
                            Row(children: [
                              if (discussion.closed)
                                Icon(
                                  Icons.lock,
                                  size: 14.0 + theme.fontSize,
                                  color: Colors.red,
                                ),
                              if (discussion.poll)
                                Icon(
                                  Icons.poll_outlined,
                                  size: 15.0 + theme.fontSize,
                                  color: Colors.green,
                                ),
                            ])
                          ],
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                discussion.title,
                                style: TextStyle(
                                    fontSize: 14.0 + theme.fontSize,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(discussion.user,
                                  style: TextStyle(fontSize: 12.0 + theme.fontSize)),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${discussion.topic} · Created: ${discussion.created} ago · Active: ${discussion.last} ago',
                                      style: TextStyle(
                                        fontSize: 10.0 + theme.fontSize,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ))),
          newPageProgressIndicatorBuilder: (context) => const PagedProgressIndicator(),
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
    dom.Element heading = element.getElementsByClassName('table__column__heading')[0];
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
        closed:
            element.getElementsByClassName('icon-red icon-heading fa fa-lock').isNotEmpty,
        comments: secondary[2].text,
        created: secondary[0].nextElementSibling!.text,
        last: last.isNotEmpty ? last[0].nodes[1].text!.split(' ago').first : '',
        poll:
            element.getElementsByClassName('icon-heading fa fa-align-left').isNotEmpty));
  });
  return discussions;
}
