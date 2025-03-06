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
import 'package:snag/common/vars/prefs_keys.dart';
import 'package:snag/provider_models/gifts_provider.dart';
import 'package:snag/provider_models/messages_provider.dart';
import 'package:snag/provider_models/won_provider.dart';
import 'package:snag/views/notifications/fetch_notifications.dart';

void getNotifications(dom.Document document, BuildContext context) {
  String gifts, won, messages = '0';
  bool keysAvailable = false;
  (gifts, won, messages, keysAvailable) = fetchNotifications(document);
  _updateNotifications(context, gifts, won, messages, keysAvailable);
}

void _updateNotifications(BuildContext context, String gifts, String won,
    String messages, bool keysAvailable) {
  context.read<GiftsProvider>().updateGifts(gifts);
  context.read<WonProvider>().updateWon(won, keysAvailable);
  context.read<MessagesProvider>().updateMessages(messages);
  prefs.setInt(PrefsKeys.gifts.key, int.parse(gifts));
  prefs.setInt(PrefsKeys.won.key, int.parse(won));
  prefs.setInt(PrefsKeys.messages.key, int.parse(messages));
}
