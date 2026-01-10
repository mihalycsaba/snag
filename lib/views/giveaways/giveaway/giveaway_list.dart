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

import 'dart:async';

import 'package:flutter/material.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';

import 'package:snag/common/functions/initialize_notifications.dart';
import 'package:snag/common/paged_progress_indicator.dart';
import 'package:snag/common/vars/globals.dart';
import 'package:snag/nav/custom_drawer.dart';
import 'package:snag/nav/custom_drawer_appbar.dart';
import 'package:snag/nav/pages.dart';
import 'package:snag/provider_models/giveaway_filter_provider.dart';
import 'package:snag/provider_models/theme_provider.dart';
import 'package:snag/views/giveaways/functions/change_giveaway_state.dart';
import 'package:snag/views/giveaways/functions/fetch_giveaway_list.dart';
import 'package:snag/views/giveaways/functions/parse_giveaway_list.dart';
import 'package:snag/views/giveaways/giveaway/giveaway_filter.dart';
import 'package:snag/views/giveaways/giveaway/giveaway_list_tile.dart';
import 'package:snag/views/giveaways/giveaway/giveaway_model.dart';
import 'package:snag/views/misc/logged_out.dart';

class GiveawayList extends StatefulWidget {
  const GiveawayList({super.key, required this.page});
  final GiveawayPages page;

  @override
  State<GiveawayList> createState() => _GiveawayListState();
}

class _GiveawayListState extends State<GiveawayList> with WidgetsBindingObserver {
  final PagingController<int, GiveawayListModel> _pagingController =
      PagingController(firstPageKey: 1);
  final FlutterLocalNotificationsPlugin _status = FlutterLocalNotificationsPlugin();
  bool _refresh = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _pagingController.addPageRequestListener((pageKey) => fetchGiveawayList(
        pageKey,
        widget.page.url + context.read<GiveawayFilterProvider>().filter,
        _parseGiveawayList,
        _pagingController,
        context));
  }

  List<GiveawayListModel> _parseGiveawayList(String data, int pageKey) {
    List<GiveawayListModel> giveaways = [];
    dom.Document document = parse(data);
    if (document.getElementsByClassName('pinned-giveaways__outer-wrap').isEmpty) {
      document.getElementsByClassName('giveaway__row-outer-wrap').forEach((element) {
        giveaways.add(parseGiveawayListElement(element));
      });
    } else {
      if (pageKey == 1 && widget.page.name == 'All' || widget.page.name == 'Multiple') {
        parse(document
                .getElementsByClassName('pinned-giveaways__outer-wrap')[0]
                .innerHtml)
            .getElementsByClassName('giveaway__row-outer-wrap')
            .forEach((element) {
          giveaways.add(parseGiveawayListElement(element));
        });
      }
      parse(document.getElementsByClassName('widget-container')[0].innerHtml)
          .children[0]
          .children[1]
          .children[1]
          .children[2]
          .getElementsByClassName('giveaway__row-outer-wrap')
          .forEach((element) {
        giveaways.add(parseGiveawayListElement(element));
      });
    }
    return giveaways;
  }

  @override
  void dispose() {
    _pagingController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        if (_refresh) {
          _refresh = false;
          _pagingController.refresh();
        }
        break;
      case AppLifecycleState.paused:
        Timer(const Duration(seconds: 300), () => _refresh = true);
        break;
      default:
    }
  }

  @override
  Widget build(BuildContext context) {
    initializeNotifications(_status, context);
    return isLoggedIn
        ? Scaffold(
            appBar: CustomDrawerAppBar(
              name: widget.page.name,
              showPoints: true,
              filter: GiveawayFilter(pagingController: _pagingController),
            ),
            drawer: const CustomDrawer(giveawaysOpen: true),
            body: Center(
              child: RefreshIndicator(
                  onRefresh: () => Future.sync(() => _pagingController.refresh()),
                  child: Consumer<ThemeProvider>(
                    builder: (context, theme, child) => PagedListView<int,
                            GiveawayListModel>(
                        itemExtent: CustomPagedListTheme.itemExtent +
                            addItemExtent(theme.fontSize),
                        pagingController: _pagingController,
                        builderDelegate: PagedChildBuilderDelegate<GiveawayListModel>(
                            itemBuilder: (context, giveaway, index) => GiveawayListTile(
                                  giveaway: giveaway,
                                  onTileChange: () =>
                                      changeGiveawayState(giveaway, context, setState),
                                ),
                            newPageProgressIndicatorBuilder: (context) =>
                                const PagedProgressIndicator())),
                  )),
            ))
        : const LoggedOut();
  }
}
