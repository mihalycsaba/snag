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

import 'package:provider/provider.dart';

import 'package:snag/common/functions/res_map_ajax.dart';
import 'package:snag/common/vars/prefs.dart';
import 'package:snag/provider_models/points_provider.dart';
import 'package:snag/views/giveaways/giveaway/giveaway_model.dart';

Future<void> changeGiveawayState(
    GiveawayModel giveaway, BuildContext context, Function callback) async {
  String xsrf = prefs.getString(PrefsKeys.xsrf.key)!;
  String body = giveaway.entered
      ? 'xsrf_token=$xsrf&do=entry_delete&code=${giveaway.href!.split('/')[2]}'
      : 'xsrf_token=$xsrf&do=entry_insert&code=${giveaway.href!.split('/')[2]}';

  Map responseMap = await resMapAjax(body);

  if (responseMap['type'] == 'success') {
    if (prefs.getBool(PrefsKeys.pointsNotification.key)! &&
        int.parse(responseMap['points']) <
            prefs.getInt(PrefsKeys.pointLimit.key)!) {
      prefs.setBool(PrefsKeys.pointsNotification.key, false);
    }
    if (context.mounted) {
      context.read<PointsProvider>().updatePoints(responseMap['points']);
    }
    callback(() {
      giveaway.entries = responseMap['entry_count'];
      giveaway.entered = !giveaway.entered;
    });
  }
}
