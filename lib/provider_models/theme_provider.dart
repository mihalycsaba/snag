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

import 'package:snag/common/vars/prefs.dart';

class ThemeProvider extends ChangeNotifier {
  bool dynamicColor = prefs.getBool(PrefsKeys.dynamicColor.key)!;
  int fontSize = prefs.getInt(PrefsKeys.fontSize.key)!;

  void updateDynamic(bool value) {
    dynamicColor = value;
    prefs.setBool(PrefsKeys.dynamicColor.key, value);
    notifyListeners();
  }

  void updateFontSize(int value) {
    fontSize = value;
    prefs.setInt(PrefsKeys.fontSize.key, value);
    notifyListeners();
  }
}
