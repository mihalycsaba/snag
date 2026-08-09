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
import 'package:snag/common/functions/fetch_body.dart';
import 'package:snag/common/functions/has_next_page.dart';
import 'package:snag/common/functions/paging_functions.dart';
import 'package:snag/common/functions/resize_image.dart';
import 'package:snag/common/paged_progress_indicator.dart';
import 'package:snag/nav/custom_nav.dart';
import 'package:snag/provider_models/theme_provider.dart';
import 'package:snag/views/giveaways/giveaway/giveaway.dart';
import 'package:snag/views/giveaways/giveaway/giveaway_theme.dart';
import 'package:snag/views/giveaways/giveaway/winners.dart';

class _CreatedListModel {
  String name;
  String image;
  String time;
  String href;
  bool sent;
  bool received;
  String? sendLink;
  _CreatedListModel(
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
  bool _hasNextPage = true;
  late final PagingController<int, _CreatedListModel> _pagingController =
      PagingController<int, _CreatedListModel>(
    getNextPageKey: (state) => getNextPageKey(
      state: state,
      hasNextPage: _hasNextPage,
    ),
    fetchPage: (pageKey) => fetchPage(
        pageKey: pageKey,
        fetcher: _fetchCreatedList,
        url: 'https://www.steamgifts.com/giveaways/created/search?page=',
        parser: _parseCreatedList,
        context: context,
        pagingController: _pagingController,
        hasNextPage: _hasNextPage,
        updateHasNextPage: (hasNextPage) => _hasNextPage = hasNextPage),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
        onRefresh: () => Future.sync(() => _hasNextPage =
            refreshList<_CreatedListModel>(pagingController: _pagingController)),
        child: Consumer<ThemeProvider>(
          builder: (context, theme, child) => PagingListener<int, _CreatedListModel>(
            controller: _pagingController,
            builder: (context, state, fetchNextPage) =>
                PagedListView<int, _CreatedListModel>(
              itemExtent: CustomPagedListTheme.itemExtent + addItemExtent(theme.fontSize),
              state: state,
              fetchNextPage: fetchNextPage,
              builderDelegate: PagedChildBuilderDelegate<_CreatedListModel>(
                itemBuilder: (context, created, index) => Column(children: [
                  ListTile(
                    selected: !created.received,
                    leading: CustomNetworkImage(
                      image: resizeImage(
                          created.image, GiveawayListTileTheme.leadingWidth.toInt()),
                      width: GiveawayListTileTheme.leadingWidth,
                    ),
                    title: Text(created.name, overflow: GiveawayListTileTheme.overflow),
                    subtitle: Text(created.time),
                    onTap: () => customNav(Giveaway(href: created.href), context),
                    trailing: created.sendLink != null
                        ? TextButton(
                            child: const Text('Winners'),
                            onPressed: () => customNav(
                              Winners(link: created.sendLink!, self: true),
                              context,
                            ).then((value) => _hasNextPage =
                                refreshList<_CreatedListModel>(
                                    pagingController: _pagingController)),
                          )
                        : null,
                  ),
                ]),
                newPageProgressIndicatorBuilder: (context) =>
                    const PagedProgressIndicator(),
              ),
            ),
          ),
        ));
  }

  Future<List<_CreatedListModel>> _fetchCreatedList(
      int pageKey, String url, Function parser, BuildContext context,
      {void Function(bool hasNextPage)? updateHasNextPage}) async {
    String data = await fetchBody(url: '$url${pageKey.toString()}');
    dom.Document document = parse(data);
    updateHasNextPage
        ?.call(hasNextPage(document.getElementsByClassName('widget-container').first));
    return _parseCreatedList(document);
  }

  List<_CreatedListModel> _parseCreatedList(dom.Document document) {
    List<_CreatedListModel> createdList = [];
    document.getElementsByClassName('table__row-inner-wrap').forEach((element) {
      createdList.add(_parseCreatedListElement(element));
    });
    return createdList;
  }

  _CreatedListModel _parseCreatedListElement(dom.Element element) {
    dom.Document item = parse(element.innerHtml);
    List<dom.Element> img = item.getElementsByClassName('table_image_thumbnail');
    String image = img.isNotEmpty ? img[0].attributes['style']! : '';
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
    return _CreatedListModel(
        name: heading.text,
        image: image == '' ? '' : image.substring(21, image.length - 2),
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
