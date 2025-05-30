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

import 'package:snag/common/vars/prefs.dart';

Future<Map> resMap(String body, String url) async {
  Response response = await post(Uri.parse(url),
      headers: <String, String>{
        'Cookie': 'PHPSESSID=${prefs.getString(PrefsKeys.sessid.key)}',
        'Content-Type': 'application/x-www-form-urlencoded'
      },
      encoding: Encoding.getByName('utf-8'),
      body: body);
  //301 when marking messages as read, 200 and empty body when voting
  if (response.statusCode == 301 || (response.statusCode == 200 && response.body == '')) {
    Map body = {};
    body['type'] = 'success';
    return body;
  }
  return jsonDecode(response.body);
}
