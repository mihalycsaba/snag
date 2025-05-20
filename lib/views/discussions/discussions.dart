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

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';

import 'package:snag/nav/custom_drawer.dart';
import 'package:snag/nav/custom_drawer_appbar.dart';
import 'package:snag/nav/pages.dart';
import 'package:snag/provider_models/discussion_filter_provider.dart';
import 'package:snag/views/discussions/discussion_filter.dart';
import 'package:snag/views/discussions/discussion_model.dart';
import 'package:snag/views/discussions/discussions_list.dart';
import 'package:snag/common/functions/initialize_notifications.dart';

class Discussions extends StatefulWidget {
  const Discussions({super.key, required this.page});
  final Pages page;

  @override
  State<Discussions> createState() => _DiscussionsState();
}

class _DiscussionsState extends State<Discussions> {
  final PagingController<int, DiscussionModel> _pagingController =
      PagingController(firstPageKey: 1);
  final FlutterLocalNotificationsPlugin _status =
      FlutterLocalNotificationsPlugin();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _pagingController.addPageRequestListener((pageKey) => fetchDiscussions(
        pagingController: _pagingController,
        pageKey: pageKey,
        url: widget.page.url + context.read<DiscussionFilterProvider>().filter,
        context: context));
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    initializeNotifications(_status, context);
    return Scaffold(
        appBar: CustomDrawerAppBar(
          name: widget.page.name,
          showPoints: false,
          filter: DiscussionFilter(pagingController: _pagingController),
        ),
        drawer: const CustomDrawer(
          giveawaysOpen: false,
        ),
        body: Center(
            child: RefreshIndicator(
          onRefresh: () => Future.sync(() => _pagingController.refresh()),
          child: DiscussionsList(pagingController: _pagingController),
        )));
  }
}
