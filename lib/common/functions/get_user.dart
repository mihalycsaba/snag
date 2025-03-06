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

import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart';

import 'package:snag/common/functions/get_avatar.dart';
import 'package:snag/common/vars/globals.dart';

Future<void> getUser(Map<String, String> headers, [Response? response]) async {
  Response loginGet = response ??
      await get(Uri.parse('https://www.steamgifts.com/about/brand-assets'),
          headers: headers);
  Document body = parse(loginGet.body);
  username = body
      .getElementsByClassName('nav__avatar-outer-wrap')[0]
      .attributes['href']!
      .split('/')
      .last;
  avatar = getAvatar(body.body!, 'nav__avatar-inner-wrap');
  userLevel = double.parse(body
      .getElementsByClassName('nav__points')[0]
      .nextElementSibling!
      .attributes['title']!);
}
