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

import 'package:http/http.dart';

import 'package:snag/common/vars/prefs.dart';

Future<String> fetchBody(
    {required String url, final bool isBlacklisted = false}) async {
  Map<String, String> headers = {};
  if (!isBlacklisted) {
    headers['Cookie'] = 'PHPSESSID=${prefs.getString(PrefsKeys.sessid.key)}';
  }
  Response response = await get(Uri.parse(url), headers: headers);
  return response.body;
}
