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

import 'package:flutter/widgets.dart';

import 'package:html/dom.dart' as dom;
import 'package:provider/provider.dart';

import 'package:snag/common/vars/prefs.dart';
import 'package:snag/provider_models/gifts_provider.dart';
import 'package:snag/provider_models/messages_provider.dart';
import 'package:snag/provider_models/won_provider.dart';
import 'package:snag/views/notifications/notifications_model.dart';

void getNotifications(dom.Document document, BuildContext context) {
  NotificationModel notifications = _fetchNotifications(document);
  _updateNotifications(context, notifications.gifts, notifications.won,
      notifications.messages, notifications.keysAvailable);
}

NotificationModel _fetchNotifications(
  dom.Document document,
) {
  dom.Element notifications = document.getElementsByClassName('nav__right-container')[0];
  String gifts = notifications.children[0].innerHtml.contains('nav__notification')
      ? notifications.children[0].getElementsByClassName('nav__notification')[0].text
      : '0';
  String won = '0';
  bool keysAvailable = false;
  if (notifications.children[1].innerHtml.contains('nav__notification')) {
    dom.Element nav = notifications.children[1];
    won = nav.getElementsByClassName('nav__notification')[0].text;
    keysAvailable =
        nav.getElementsByClassName('nav__notification fade_infinite').isNotEmpty;
  }

  String messages = notifications.children[2].innerHtml.contains('nav__notification')
      ? notifications.children[2].getElementsByClassName('nav__notification')[0].text
      : '0';
  return NotificationModel(gifts, won, messages, keysAvailable);
}

void _updateNotifications(
    BuildContext context, String gifts, String won, String messages, bool keysAvailable) {
  context.read<GiftsProvider>().updateGifts(gifts);
  context.read<WonProvider>().updateWon(won, keysAvailable);
  context.read<MessagesProvider>().updateMessages(messages);
  prefs.setInt(PrefsKeys.gifts.key, int.parse(gifts));
  prefs.setInt(PrefsKeys.won.key, int.parse(won));
  prefs.setInt(PrefsKeys.messages.key, int.parse(messages));
}
