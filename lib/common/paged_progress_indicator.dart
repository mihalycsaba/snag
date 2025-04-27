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

class CustomPagedListTheme {
  CustomPagedListTheme._();
  //has to be 35 because there is weird jiggle issue during slow scroll
  //41 doesn't have overflow
  //Todo: fix this maybe with custom lisstile widget
  static const double itemExtent = 41.0;
}

int addItemExtent(int size) {
  return 4 * size;
}

class PagedProgressIndicator extends StatelessWidget {
  const PagedProgressIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 40.0),
      child: Center(
        child: LinearProgressIndicator(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
    );
  }
}
