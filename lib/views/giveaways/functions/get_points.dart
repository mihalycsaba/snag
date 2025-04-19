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
import 'package:provider/provider.dart';

import 'package:snag/common/vars/prefs.dart';
import 'package:snag/provider_models/points_provider.dart';

void getPoints(dom.Document document, BuildContext context) {
  String points = document.getElementsByClassName('nav__points')[0].text;
  if (prefs.getBool(PrefsKeys.pointsNotification.key)! &&
      int.parse(points) < prefs.getInt(PrefsKeys.pointLimit.key)!) {
    prefs.setBool(PrefsKeys.pointsNotification.key, false);
  }
  context.read<PointsProvider>().updatePoints(points);
}
