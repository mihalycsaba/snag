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
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

void addPage(List list, PagingController pagingController, int pageKey,
    dom.Element container) {
  List<dom.Element> pagination =
      container.getElementsByClassName('pagination__navigation');
  final bool isLastPage = pagination.isEmpty ||
      !pagination.first.innerHtml.contains('<span>Next</span>');
  if (isLastPage) {
    pagingController.appendLastPage(list);
  } else {
    pagingController.appendPage(list, pageKey + 1);
  }
}
