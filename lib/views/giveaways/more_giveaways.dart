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

import 'package:go_router/go_router.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:share_plus/share_plus.dart';

import 'package:snag/common/card_theme.dart';
import 'package:snag/common/functions/add_page.dart';
import 'package:snag/common/functions/fetch_body.dart';
import 'package:snag/common/paged_progress_indicator.dart';
import 'package:snag/common/vars/globals.dart';
import 'package:snag/common/vars/obx.dart';
import 'package:snag/objectbox/game_bookmark_model.dart';
import 'package:snag/views/giveaways/functions/change_giveaway_state.dart';
import 'package:snag/views/giveaways/functions/parse_giveaway_list.dart';
import 'package:snag/views/giveaways/giveaway/giveaway_list_tile.dart';
import 'package:snag/views/giveaways/giveaway/giveaway_model.dart';
import 'package:snag/views/misc/logged_out.dart';

import '../../nav/pages.dart';

class MoreGiveaways extends StatefulWidget {
  const MoreGiveaways({required this.href, super.key});

  final String href;

  @override
  State<MoreGiveaways> createState() => _MoreGiveawaysState();
}

class _MoreGiveawaysState extends State<MoreGiveaways> {
  final PagingController<int, GiveawayListModel> _pagingController =
      PagingController<int, GiveawayListModel>(firstPageKey: 1);
  static const TextStyle _detailsTextStyle = TextStyle(fontSize: 16);

  String _appid = '';
  String _type = '';
  List<GameBookmarkModel> _bookmark = [];
  bool _bookmarked = false;
  _GameModel _game = _GameModel(
      name: '',
      totalGiveaways: '',
      totalCopies: '',
      youEntered: '',
      received: '',
      reduced: '',
      noValue: '');

  @override
  void initState() {
    super.initState();
    _bookmark = objectbox.getGameBookmarked(widget.href);
    _bookmarked = _bookmark.isNotEmpty;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _pagingController.addPageRequestListener((pageKey) => _fetchPage(
        pageKey, 'https://www.steamgifts.com${widget.href}/search', context));
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return isLoggedIn
        ? Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go(GiveawayPages.all.route);
                  }
                },
              ),
              title: Text(_game.name),
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
              actions: [
                InkWell(
                  onTap: () {
                    if (_bookmarked) {
                      objectbox.removeGameBookmark(_bookmark.first.id);
                    } else {
                      objectbox.addGameBookmark(
                          name: _game.name,
                          href: widget.href,
                          type: _type,
                          appid: _appid);
                    }
                    setState(() {
                      _bookmarked = !_bookmarked;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Icon(
                        _bookmarked ? Icons.bookmark : Icons.bookmark_border),
                  ),
                ),
                InkWell(
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: const Icon(Icons.share),
                    ),
                    onTap: () => Share.shareUri(
                        Uri.parse('https://www.steamgifts.com${widget.href}'))),
              ],
            ),
            body: RefreshIndicator(
              onRefresh: () => Future.sync(() => _pagingController.refresh()),
              child: CustomScrollView(slivers: <Widget>[
                SliverToBoxAdapter(
                  child: Center(
                    child: Card(
                      surfaceTintColor: CustomCardTheme.surfaceTintColor,
                      elevation: CustomCardTheme.elevation,
                      child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Total giveaways: ${_game.totalGiveaways}',
                                        style: _detailsTextStyle,
                                      ),
                                      Text(
                                        'Total copies: ${_game.totalCopies}',
                                        style: _detailsTextStyle,
                                      ),
                                      Text(
                                        'You entered: ${_game.youEntered}',
                                        style: _detailsTextStyle,
                                      )
                                    ]),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Received: ${_game.received}',
                                      style: _detailsTextStyle,
                                    ),
                                    Text(
                                      'Reduced: ${_game.reduced}',
                                      style: _detailsTextStyle,
                                    ),
                                    Text(
                                      'No value: ${_game.noValue}',
                                      style: _detailsTextStyle,
                                    )
                                  ],
                                )
                              ])),
                    ),
                  ),
                ),
                PagedSliverList<int, GiveawayListModel>(
                    itemExtent: CustomPagedListTheme.itemExtent,
                    pagingController: _pagingController,
                    builderDelegate:
                        PagedChildBuilderDelegate<GiveawayListModel>(
                            itemBuilder: (context, giveaway, index) => Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      GiveawayListTile(
                                        giveaway: giveaway,
                                        onTileChange: () => changeGiveawayState(
                                            giveaway, context, setState),
                                      ),
                                    ]),
                            newPageProgressIndicatorBuilder: (context) =>
                                PagedProgressIndicator())),
              ]),
            ),
          )
        : LoggedOut();
  }

  void _fetchPage(int pageKey, String url, BuildContext context) async {
    String data = await fetchBody(url: '$url?page=${pageKey.toString()}');
    if (pageKey == 1) {
      dom.Element featured =
          parse(data).getElementsByClassName('featured__inner-wrap')[0];
      List<String> values = featured
          .getElementsByClassName(
              'global__image-outer-wrap global__image-outer-wrap--game-large')[0]
          .attributes['href']!
          .split('/');
      _type = values[3];
      _appid = values[4].split('?')[0];
      List<dom.Element> details =
          featured.getElementsByClassName('featured__table__column');
      _game = _GameModel(
        name: featured
            .getElementsByClassName('featured__heading__medium')[0]
            .text
            .trim(),
        totalGiveaways: details[0]
            .getElementsByClassName('featured__table__row')[0]
            .getElementsByClassName('featured__table__row__right')[0]
            .text
            .trim(),
        totalCopies: details[0]
            .getElementsByClassName('featured__table__row')[1]
            .getElementsByClassName('featured__table__row__right')[0]
            .text
            .trim(),
        youEntered: details[0]
            .getElementsByClassName('featured__table__row')[2]
            .getElementsByClassName('featured__table__row__right')[0]
            .text
            .trim(),
        received: details[1]
            .getElementsByClassName('featured__table__row')[0]
            .getElementsByClassName('featured__table__row__right')[0]
            .text
            .trim(),
        reduced: details[1]
            .getElementsByClassName('featured__table__row')[1]
            .getElementsByClassName('featured__table__row__right')[0]
            .text
            .trim(),
        noValue: details[1]
            .getElementsByClassName('featured__table__row')[2]
            .getElementsByClassName('featured__table__row__right')[0]
            .text
            .trim(),
      );
      setState(() {});
    }
    dom.Element container =
        parse(data).getElementsByClassName('widget-container')[0];
    List<GiveawayListModel> giveaways = parseList(container);
    addPage(giveaways, _pagingController, pageKey, 25);
  }
}

class _GameModel {
  final String name;
  final String totalGiveaways;
  final String totalCopies;
  final String youEntered;
  final String received;
  final String reduced;
  final String noValue;

  _GameModel({
    required this.name,
    required this.totalGiveaways,
    required this.totalCopies,
    required this.youEntered,
    required this.received,
    required this.reduced,
    required this.noValue,
  });
}
