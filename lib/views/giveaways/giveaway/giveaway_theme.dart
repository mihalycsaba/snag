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

class CustomListTileTheme {
  CustomListTileTheme._();

  static const EdgeInsets contentPadding = EdgeInsets.zero;
  static const double minVerticalPadding = 3;
  static const bool dense = true;
  static const double subtitleTextSize = 10;
  static const TextStyle subtitleTextStyle =
      TextStyle(fontSize: subtitleTextSize);
  static const double leadingWidth = 86;
  static const TextStyle titleTextStyle = TextStyle(fontSize: 14);
  static const TextOverflow overflow = TextOverflow.ellipsis;
  static const double trailingWidth = 60;
  static const double trailingHeight = 40;
  static const double iconSize = 12;
}
