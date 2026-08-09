// Copyright (C) 2026 Mihaly Csaba
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

import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

typedef ListFetchFunction<T> = Future<List<T>> Function(
  int pageKey,
  String url,
  Function parser,
  BuildContext context, {
  void Function(bool hasNextPage)? updateHasNextPage,
});

int? getNextPageKey<T>({
  required PagingState<int, T> state,
  required bool hasNextPage,
}) {
  if (!state.hasNextPage || !hasNextPage || state.lastPageIsEmpty) {
    return null;
  }
  return state.nextIntPageKey;
}

Future<List<T>> fetchPage<T>({
  required int pageKey,
  required ListFetchFunction<T> fetcher,
  required String url,
  required Function parser,
  required BuildContext context,
  required PagingController<int, T> pagingController,
  required bool hasNextPage,
  required void Function(bool hasNextPage) updateHasNextPage,
}) async {
  final items = await fetcher(
    pageKey,
    url,
    parser,
    context,
    updateHasNextPage: updateHasNextPage,
  );

  pagingController.value = pagingController.value.copyWith(
    hasNextPage: hasNextPage,
  );
  return items;
}

bool refreshList<T>({required PagingController<int, T> pagingController}) {
  pagingController.refresh();
  return true;
}
