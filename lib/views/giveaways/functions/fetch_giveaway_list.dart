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

import 'package:snag/common/functions/fetch_body.dart';
import 'package:snag/common/functions/has_next_page.dart';
import 'package:snag/views/giveaways/functions/get_points.dart';
import 'package:snag/views/giveaways/giveaway/giveaway_model.dart';
import 'package:snag/views/notifications/get_notifications.dart';

Future<List<GiveawayListModel>> fetchGiveawayList(
  int pageKey,
  String url,
  Function parser,
  BuildContext context, {
  void Function(bool hasNextPage)? updateHasNextPage,
}) async {
  String data = await fetchBody(url: '$url&page=${pageKey.toString()}');
  dom.Document document = parse(data);
  dom.Element? container = document.getElementsByClassName('widget-container').isNotEmpty
      ? document.getElementsByClassName('widget-container').first
      : null;
  if (container != null) {
    updateHasNextPage?.call(hasNextPage(container));
  }
  if (context.mounted) {
    getPoints(document, context);
    getNotifications(document, context);
  }
  return parser(data, pageKey);
}
