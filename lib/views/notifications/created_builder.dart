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
import 'package:snag/common/paged_progress_indicator.dart';
import 'package:snag/nav/custom_nav.dart';
import 'package:snag/provider_models/theme_provider.dart';
import 'package:snag/views/giveaways/giveaway/giveaway.dart';
import 'package:snag/views/giveaways/giveaway/giveaway_theme.dart';
import 'package:snag/views/giveaways/giveaway/winners.dart';

class CreatedListModel {
  String name;
  Widget image;
  String time;
  String href;
  bool sent;
  bool received;
  String? sendLink;
  CreatedListModel(
      {required this.name,
      required this.image,
      required this.time,
      required this.href,
      required this.sent,
      required this.received,
      this.sendLink});
}

class CreatedBuilder extends StatefulWidget {
  const CreatedBuilder({super.key});

  @override
  State<CreatedBuilder> createState() => _CreatedBuilderState();
}

class _CreatedBuilderState extends State<CreatedBuilder> {
  final PagingController<int, CreatedListModel> _pagingController =
      PagingController(firstPageKey: 1);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _pagingController.addPageRequestListener((pageKey) {
      fetchCreatedList(pageKey, context);
    });
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
        onRefresh: () => Future.sync(() => _pagingController.refresh()),
        child: Consumer<ThemeProvider>(
          builder: (context, theme, child) => PagedListView<int, CreatedListModel>(
              itemExtent: CustomPagedListTheme.itemExtent + addItemExtent(theme.fontSize),
              pagingController: _pagingController,
              builderDelegate: PagedChildBuilderDelegate<CreatedListModel>(
                  itemBuilder: (context, created, index) => Column(children: [
                        ListTile(
                            contentPadding: CustomListTileTheme.contentPadding,
                            minVerticalPadding: CustomListTileTheme.minVerticalPadding,
                            dense: CustomListTileTheme.dense,
                            selected: !created.received,
                            leading: SizedBox(
                              width: CustomListTileTheme.leadingWidth,
                              child: created.image,
                            ),
                            title: Consumer<ThemeProvider>(
                              builder: (context, theme, child) => Text(created.name,
                                  style: TextStyle(
                                      fontSize: CustomListTileTheme.titleTextSize +
                                          theme.fontSize),
                                  overflow: CustomListTileTheme.overflow),
                            ),
                            subtitle: Consumer<ThemeProvider>(
                              builder: (context, theme, child) => Text(
                                created.time,
                                style: TextStyle(
                                    fontSize: CustomListTileTheme.subtitleTextSize +
                                        theme.fontSize),
                              ),
                            ),
                            onTap: () => customNav(Giveaway(href: created.href), context),
                            trailing: created.sendLink != null
                                ? TextButton(
                                    child: const Text('Winners'),
                                    onPressed: () => customNav(
                                      Winners(link: created.sendLink!, self: true),
                                      context,
                                    ).then((value) => _pagingController.refresh()),
                                  )
                                : null),
                      ]),
                  newPageProgressIndicatorBuilder: (context) =>
                      const PagedProgressIndicator())),
        ));
  }

  Future<void> fetchCreatedList(int pageKey, BuildContext context) async {
    String data = await fetchBody(
        url:
            'https://www.steamgifts.com/giveaways/created/search?page=${pageKey.toString()}');
    List<CreatedListModel> createdList = parseCreatedList(data);
    addPage(createdList, _pagingController, pageKey,
        parse(data).getElementsByClassName('widget-container').first);
  }

  List<CreatedListModel> parseCreatedList(String data) {
    List<CreatedListModel> createdList = [];
    parse(data).getElementsByClassName('table__row-inner-wrap').forEach((element) {
      createdList.add(parseCreatedListElement(element));
    });
    return createdList;
  }

  CreatedListModel parseCreatedListElement(dom.Element element) {
    dom.Document item = parse(element.innerHtml);
    List<dom.Element> img = item.getElementsByClassName('table_image_thumbnail');
    String? image = img.isNotEmpty ? img[0].attributes['style'] : '';
    image = image == '' ? '' : image?.substring(21, image.length - 2);
    List<dom.Element> status =
        item.getElementsByClassName('table__column--width-small text-center');
    List<dom.Element> links =
        item.getElementsByClassName('table__column__secondary-link');
    dom.Element? sendLink = links.isEmpty
        ? null
        : links.length == 1
            ? links[0]
            : links[1];
    dom.Element heading = item.getElementsByClassName('table__column__heading')[0];
    return CreatedListModel(
        name: heading.text,
        image: image == ''
            ? const Icon(Icons.error)
            : CachedNetworkImage(
                imageUrl: image!,
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
        time: item
            .getElementsByClassName('table__column--width-fill')[0]
            .children[1]
            .text
            .trim(),
        href: heading.attributes['href']!,
        sent: status[3].text.contains('Sent'),
        received: status[3].text.contains('Received'),
        sendLink: sendLink != null && sendLink.text == 'Unsent'
            ? sendLink.attributes['href']
            : null);
  }
}
