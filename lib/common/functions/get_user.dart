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

import 'dart:convert';

import 'package:http/http.dart';

import 'package:snag/common/vars/globals.dart';
import 'package:snag/common/vars/prefs.dart';

Future<void> getUser() async {
  Map<String, String> headers = {};
  headers['Cookie'] = 'PHPSESSID=${prefs.getString(PrefsKeys.sessid.key)}';
  Response response = await get(
      Uri.parse(
          'https://www.steamgifts.com/account/settings/profile?format=json'),
      headers: headers);
  Map<String, dynamic> json = jsonDecode(response.body);
  if (json['user'] == []) {
    isLoggedIn = false;
  } else {
    isLoggedIn = true;
    username = json['user']['username'];
    avatar = json['user']['avatar_medium'];
    userLevel = json['user']['contributor_level'];
  }
}
