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

import 'package:snag/common/functions/add_page.dart';
import 'package:snag/common/functions/fetch_body.dart';
import 'package:snag/views/giveaways/functions/get_points.dart';
import 'package:snag/views/giveaways/giveaway/giveaway_model.dart';
import 'package:snag/views/notifications/get_notifications.dart';

Future<void> fetchGiveawayList(
    int pageKey,
    String url,
    Function parser,
    PagingController<int, GiveawayListModel> pagingController,
    BuildContext context) async {
  String data = await fetchBody(url: '$url&page=${pageKey.toString()}');
  //Todo: maybe move the following into fetchBody
  dom.Document document = parse(data);
  if (context.mounted) {
    getPoints(document, context);
    getNotifications(document, context);
  }
  List<GiveawayListModel> giveaways = parser(data, pageKey);
  addPage(giveaways, pagingController, pageKey,
      document.getElementsByClassName('widget-container').first);
}
