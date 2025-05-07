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

import 'package:html/dom.dart' as dom;
import 'package:snag/views/notifications/notifications_model.dart';

NotificationModel fetchNotifications(
  dom.Document document,
) {
  dom.Element notifications =
      document.getElementsByClassName('nav__right-container')[0];
  String gifts =
      notifications.children[0].innerHtml.contains('nav__notification')
          ? notifications.children[0]
              .getElementsByClassName('nav__notification')[0]
              .text
          : '0';
  String won = '0';
  bool keysAvailable = false;
  if (notifications.children[1].innerHtml.contains('nav__notification')) {
    dom.Element nav = notifications.children[1];
    won = nav.getElementsByClassName('nav__notification')[0].text;
    keysAvailable = nav
        .getElementsByClassName('nav__notification fade_infinite')
        .isNotEmpty;
  }

  String messages =
      notifications.children[2].innerHtml.contains('nav__notification')
          ? notifications.children[2]
              .getElementsByClassName('nav__notification')[0]
              .text
          : '0';
  return NotificationModel(gifts, won, messages, keysAvailable);
}
