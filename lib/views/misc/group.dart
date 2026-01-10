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

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import 'package:snag/common/custom_network_image.dart';
import 'package:snag/common/functions/add_page.dart';
import 'package:snag/common/functions/fetch_body.dart';
import 'package:snag/common/functions/get_avatar.dart';
import 'package:snag/common/functions/url_launcher.dart';
import 'package:snag/common/paged_progress_indicator.dart';
import 'package:snag/common/vars/globals.dart';
import 'package:snag/common/vars/obx.dart';
import 'package:snag/nav/pages.dart';
import 'package:snag/objectbox/group_bookmark_model.dart';
import 'package:snag/provider_models/theme_provider.dart';
import 'package:snag/views/giveaways/error/error_page.dart';
import 'package:snag/views/giveaways/functions/change_giveaway_state.dart';
import 'package:snag/views/giveaways/functions/parse_giveaway_list.dart';
import 'package:snag/views/giveaways/giveaway/giveaway_list_tile.dart';
import 'package:snag/views/giveaways/giveaway/giveaway_model.dart';
import 'package:snag/views/misc/logged_out.dart';

class Group extends StatefulWidget {
  const Group({required this.href, super.key});

  final String href;

  @override
  State<Group> createState() => _GroupState();
}

class _GroupState extends State<Group> {
  final PagingController<int, GiveawayListModel> _pagingController =
      PagingController<int, GiveawayListModel>(firstPageKey: 1);
  static const double _fontSize = 12;
  static const TextStyle _detailsTextStyle = TextStyle(fontSize: _fontSize);

  List<GroupBookmarkModel> _bookmark = [];
  bool _bookmarked = false;

  _GroupModel _group = _GroupModel(
    name: '',
    image: Container(),
    first: '',
    last: '',
    average: '',
    contributors: '',
    winners: '',
    sent: '',
    giveaways: '',
    users: '',
    steam: '',
  );
  String _url = '';
  String _exception = '';
  String _stackTrace = '';

  @override
  void initState() {
    super.initState();
    _bookmark = objectbox.getGroupBookmarked(widget.href);
    _bookmarked = _bookmark.isNotEmpty;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _url = 'https://www.steamgifts.com${widget.href}/';
    _pagingController.addPageRequestListener((pageKey) => _fetchPage(pageKey, context));
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _exception.isEmpty
        ? isLoggedIn
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
                  backgroundColor: Theme.of(context).colorScheme.inversePrimary,
                  title: Text(_group.name),
                  actions: [
                    IconButton(
                        onPressed: () {
                          if (_bookmarked) {
                            _bookmark = objectbox.getGroupBookmarked(widget.href);
                            objectbox.removeGroupBookmark(_bookmark[0].id);
                          } else {
                            objectbox.addGroupBookmark(
                                name: _group.name, href: widget.href);
                          }
                          setState(() {
                            _bookmarked = !_bookmarked;
                          });
                        },
                        icon: Icon(_bookmarked ? Icons.bookmark : Icons.bookmark_border)),
                    IconButton(
                        icon: const Icon(Icons.share),
                        onPressed: () =>
                            SharePlus.instance.share(ShareParams(uri: Uri.parse(_url)))),
                    IconButton(
                        onPressed: () => urlLauncher(_group.steam),
                        icon: const FaIcon(FontAwesomeIcons.steamSymbol))
                  ],
                ),
                body: RefreshIndicator(
                    onRefresh: () => Future.sync(() => _pagingController.refresh()),
                    child: CustomScrollView(slivers: <Widget>[
                      SliverToBoxAdapter(
                          child: Center(
                              child: Card.filled(
                                  child: Padding(
                        padding: const EdgeInsets.only(
                            top: 8.0, bottom: 8.0, left: 4.0, right: 8.0),
                        child: Row(children: [
                          SizedBox(
                            width: 70,
                            height: 70,
                            child: _group.image,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SizedBox(
                              width: 175,
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('First Giveaway: ${_group.first}',
                                        style: _detailsTextStyle),
                                    Row(
                                      children: [
                                        const Text('Last Giveaway: ',
                                            style: _detailsTextStyle),
                                        Text(_group.last,
                                            style: _group.last.contains('Open')
                                                ? const TextStyle(
                                                    color: Colors.green,
                                                    fontSize: _fontSize)
                                                : _detailsTextStyle)
                                      ],
                                    ),
                                    Text('Average Entries: ${_group.average}',
                                        style: _detailsTextStyle),
                                    Text('Giveaways: ${_group.giveaways}',
                                        style: _detailsTextStyle),
                                  ]),
                            ),
                          ),
                          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text('Contributors: ${_group.contributors}',
                                style: _detailsTextStyle),
                            Text('Winners: ${_group.winners}', style: _detailsTextStyle),
                            Text('Gifts Sent: ${_group.sent}', style: _detailsTextStyle),
                            Text('Users: ${_group.users}', style: _detailsTextStyle),
                          ])
                        ]),
                      )))),
                      Consumer<ThemeProvider>(
                          builder: (context, theme, child) => PagedSliverList(
                              itemExtent: CustomPagedListTheme.itemExtent +
                                  addItemExtent(theme.fontSize),
                              pagingController: _pagingController,
                              builderDelegate:
                                  PagedChildBuilderDelegate<GiveawayListModel>(
                                itemBuilder: (context, giveaway, index) =>
                                    Column(mainAxisSize: MainAxisSize.min, children: [
                                  GiveawayListTile(
                                    giveaway: giveaway,
                                    onTileChange: () =>
                                        changeGiveawayState(giveaway, context, setState),
                                  ),
                                ]),
                                newPageProgressIndicatorBuilder: (context) =>
                                    const PagedProgressIndicator(),
                              )))
                    ])))
            : const LoggedOut()
        : ErrorPage(error: _exception, url: _url, stackTrace: _stackTrace, type: 'group');
  }

  void _fetchPage(int pageKey, BuildContext context) async {
    try {
      String data = await fetchBody(url: '${_url}search?page=${pageKey.toString()}');

      dom.Document document = parse(data);
      dom.Element container = document.getElementsByClassName('widget-container')[0];
      if (pageKey == 1) {
        _url =
            'https://www.steamgifts.com${container.getElementsByClassName('page__heading__breadcrumbs').first.nodes.first.attributes['href']}/';
        dom.Element featured = document.getElementsByClassName('featured__inner-wrap')[0];
        List<dom.Element> details =
            featured.getElementsByClassName('featured__table__column');
        dom.Element sidebar = container.getElementsByClassName('sidebar')[0];
        List<dom.Element> itemCount =
            sidebar.getElementsByClassName('sidebar__navigation__item__count');
        _group = _GroupModel(
            name: featured
                .getElementsByClassName('featured__heading__medium')[0]
                .text
                .trim(),
            image: CustomNetworkImage(
              image: NetworkImage(getAvatar(featured, 'global__image-inner-wrap')),
              width: 70,
            ),
            first: details[0]
                .getElementsByClassName('featured__table__row')[0]
                .getElementsByClassName('featured__table__row__right')[0]
                .text
                .trim(),
            last: details[0]
                .getElementsByClassName('featured__table__row')[1]
                .getElementsByClassName('featured__table__row__right')[0]
                .text
                .trim(),
            average: details[0]
                .getElementsByClassName('featured__table__row')[2]
                .getElementsByClassName('featured__table__row__right')[0]
                .text
                .trim(),
            contributors: details[1]
                .getElementsByClassName('featured__table__row')[0]
                .getElementsByClassName('featured__table__row__right')[0]
                .text
                .trim(),
            winners: details[1]
                .getElementsByClassName('featured__table__row')[1]
                .getElementsByClassName('featured__table__row__right')[0]
                .text
                .trim(),
            sent: details[1]
                .getElementsByClassName('featured__table__row')[2]
                .getElementsByClassName('featured__table__row__right')[0]
                .text
                .trim(),
            giveaways: itemCount[0].text.trim(),
            users: itemCount[1].text.trim(),
            steam: sidebar
                .getElementsByClassName('sidebar__shortcut-inner-wrap')[0]
                .nodes[1]
                .attributes['href']!);
        setState(() {});
      }
      List<GiveawayListModel> giveaways = parseList(container);
      addPage(giveaways, _pagingController, pageKey, container);
    } catch (error, stack) {
      _exception = error.toString();
      _stackTrace = stack.toString();
      setState(() {});
    }
  }
}

class _GroupModel {
  final String name;
  final Widget image;
  final String first;
  final String last;
  final String average;
  final String contributors;
  final String winners;
  final String sent;
  final String giveaways;
  final String users;
  final String steam;

  _GroupModel(
      {required this.name,
      required this.image,
      required this.first,
      required this.last,
      required this.average,
      required this.contributors,
      required this.winners,
      required this.sent,
      required this.giveaways,
      required this.users,
      required this.steam});
}
