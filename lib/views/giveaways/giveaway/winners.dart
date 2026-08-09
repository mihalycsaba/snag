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

import 'package:snag/common/custom_network_image.dart';
import 'package:snag/common/functions/fetch_body.dart';
import 'package:snag/common/functions/get_avatar.dart';
import 'package:snag/common/functions/has_next_page.dart';
import 'package:snag/common/functions/paging_functions.dart';
import 'package:snag/common/functions/res_status_code.dart';
import 'package:snag/common/functions/resize_image.dart';
import 'package:snag/common/paged_progress_indicator.dart';
import 'package:snag/nav/custom_nav.dart';
import 'package:snag/views/misc/user.dart';

class WinnerModel {
  final String name;
  final String image;
  final String? email;
  final String? id;
  bool sent;
  bool anonymous;
  WinnerModel(
      {required this.name,
      required this.image,
      required this.email,
      required this.id,
      required this.sent,
      required this.anonymous});
}

class Winners extends StatefulWidget {
  const Winners({required this.link, required this.self, super.key});
  final String link;
  final bool self;

  @override
  State<Winners> createState() => _WinnersState();
}

class _WinnersState extends State<Winners> {
  bool _hasNextPage = true;
  late final PagingController<int, WinnerModel> _pagingController =
      PagingController<int, WinnerModel>(
    getNextPageKey: (state) => getNextPageKey(
      state: state,
      hasNextPage: _hasNextPage,
    ),
    fetchPage: (pageKey) => fetchPage<WinnerModel>(
      pageKey: pageKey,
      fetcher: _fetchWinnerList,
      url: 'https://www.steamgifts.com${widget.link}/search?page=',
      parser: _parseWinnerList,
      context: context,
      pagingController: _pagingController,
      hasNextPage: _hasNextPage,
      updateHasNextPage: (hasNextPage) => _hasNextPage = hasNextPage,
    ),
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
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text('Winners'),
        ),
        body: RefreshIndicator(
            onRefresh: () => Future.sync(() => _hasNextPage =
                refreshList<WinnerModel>(pagingController: _pagingController)),
            child: PagingListener<int, WinnerModel>(
              controller: _pagingController,
              builder: (context, state, fetchNextPage) => PagedListView<int, WinnerModel>(
                state: state,
                fetchNextPage: fetchNextPage,
                builderDelegate: PagedChildBuilderDelegate<WinnerModel>(
                  itemBuilder: (context, item, index) => ListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 14.0),
                      leading: CustomNetworkImage(
                        image: resizeImage(item.image, 40),
                        width: 40,
                      ),
                      title: Text(item.name),
                      subtitle: widget.self ? Text(item.email!) : null,
                      onTap: item.anonymous
                          ? null
                          : () => customNav(User(name: item.name), context),
                      trailing: widget.self
                          ? TextButton(
                              onPressed: item.sent
                                  ? null
                                  : () async {
                                      int statusCode = await resStatusCode(
                                          '&action=1&do=sent_feedback&winner_id=${item.id}');
                                      if (statusCode == 200) {
                                        setState(() {
                                          item.sent = true;
                                        });
                                      }
                                    },
                              child: const Text('Send'))
                          : null),
                  newPageProgressIndicatorBuilder: (context) =>
                      const PagedProgressIndicator(),
                ),
              ),
            )));
  }

  Future<List<WinnerModel>> _fetchWinnerList(
      int pageKey, String url, Function parser, BuildContext context,
      {void Function(bool hasNextPage)? updateHasNextPage}) async {
    String data = await fetchBody(url: '$url${pageKey.toString()}');
    dom.Document document = parse(data);
    updateHasNextPage
        ?.call(hasNextPage(document.getElementsByClassName('widget-container').first));
    return _parseWinnerList(document);
  }

  List<WinnerModel> _parseWinnerList(dom.Document document) {
    List<WinnerModel> winnerList = [];
    document.getElementsByClassName('table__row-inner-wrap').forEach((element) {
      winnerList.add(_parseWinnerListElement(element));
    });
    return winnerList;
  }

  WinnerModel _parseWinnerListElement(dom.Element element) {
    dom.Document item = parse(element.innerHtml);
    dom.Element heading = item.getElementsByClassName('table__column__heading')[0];
    return WinnerModel(
        id: widget.self
            ? item
                .getElementsByClassName('table__column--width-small')[0]
                .children[0]
                .children[6]
                .attributes['value']!
            : null,
        name: heading.text,
        image: getAvatar(item.body!, 'table_image_avatar'),
        email: widget.self
            ? item
                .getElementsByClassName('table__column--width-fill')[0]
                .children[1]
                .nodes[8]
                .text!
                .trim()
            : null,
        sent: widget.self
            ? item
                .getElementsByClassName('table__gift-sent is-clickable is-hidden')
                .isEmpty
            : false,
        anonymous: heading.children.isEmpty);
  }
}
