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
import 'package:snag/common/functions/res_status_code.dart';
import 'package:snag/common/paged_progress_indicator.dart';
import 'package:snag/nav/custom_nav.dart';
import 'package:snag/provider_models/theme_provider.dart';
import 'package:snag/views/giveaways/giveaway/giveaway_theme.dart';
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
  final _pagingController = PagingController<int, WinnerModel>(firstPageKey: 1);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _pagingController.addPageRequestListener((pageKey) {
      fetchWinnerList(pageKey, context);
    });
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
            onRefresh: () => Future.sync(() => _pagingController.refresh()),
            child: Consumer<ThemeProvider>(
                builder: (context, theme, child) => PagedListView<int, WinnerModel>(
                    itemExtent:
                        CustomPagedListTheme.itemExtent + addItemExtent(theme.fontSize),
                    pagingController: _pagingController,
                    builderDelegate: PagedChildBuilderDelegate<WinnerModel>(
                      itemBuilder: (context, item, index) => Consumer<ThemeProvider>(
                          builder: (context, theme, child) => ListTile(
                              contentPadding: CustomListTileTheme.contentPadding,
                              minVerticalPadding: CustomListTileTheme.minVerticalPadding,
                              dense: CustomListTileTheme.dense,
                              leading: CustomNetworkImage(
                                resize: true,
                                url: item.image,
                                width: 40,
                              ),
                              title: Text(
                                item.name,
                                style: TextStyle(
                                    fontSize: CustomListTileTheme.titleTextSize +
                                        theme.fontSize),
                              ),
                              subtitle: widget.self
                                  ? Text(
                                      item.email!,
                                      style: TextStyle(
                                          fontSize: CustomListTileTheme.subtitleTextSize +
                                              theme.fontSize),
                                    )
                                  : null,
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
                                      child: Text('Send',
                                          style: TextStyle(
                                              fontSize:
                                                  CustomListTileTheme.titleTextSize +
                                                      theme.fontSize)))
                                  : null)),
                      newPageProgressIndicatorBuilder: (context) =>
                          const PagedProgressIndicator(),
                    )))));
  }

  Future<void> fetchWinnerList(int pageKey, BuildContext context) async {
    String data = await fetchBody(
        url:
            'https://www.steamgifts.com${widget.link}/search?page=${pageKey.toString()}');
    List<WinnerModel> winnerList = parseWinnerList(data);
    dom.Document document = parse(data);
    addPage(winnerList, _pagingController, pageKey,
        document.getElementsByClassName('widget-container').first);
  }

  List<WinnerModel> parseWinnerList(String data) {
    List<WinnerModel> winnerList = [];
    parse(data).getElementsByClassName('table__row-inner-wrap').forEach((element) {
      winnerList.add(parseWinnerListElement(element));
    });
    return winnerList;
  }

  WinnerModel parseWinnerListElement(dom.Element element) {
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
