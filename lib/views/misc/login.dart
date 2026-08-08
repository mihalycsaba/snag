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

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart';

import 'package:snag/background_task.dart';
import 'package:snag/common/functions/cookie_string.dart';
import 'package:snag/common/functions/get_user.dart';
import 'package:snag/common/vars/globals.dart';
import 'package:snag/common/vars/prefs.dart';
import 'package:snag/nav/custom_back_appbar.dart';
import 'package:snag/nav/go_nav.dart';
import 'package:snag/nav/pages.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  void _change(WebUri? urlchange, BuildContext context) async {
    const String url = 'https://www.steamgifts.com/';
    if (urlchange?.rawValue == url) {
      await CookieManager()
          .getCookie(url: urlchange!, name: 'PHPSESSID')
          .then((value) => prefs.setString(PrefsKeys.sessid.key, value?.value));
      await get(Uri.parse(url), headers: <String, String>{
        'Cookie': cookieString(),
      }).then((value) => prefs.setString(
          PrefsKeys.xsrf.key,
          parse(value.body)
              .getElementsByClassName('nav__row is-clickable js__logout')[0]
              .attributes['data-form']!
              .split('=')[2]));
      backgroundTask();
      await getUser();
      isLoggedIn = true;
      if (!context.mounted) return;
      goNav(context, GiveawayPages.all.route);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomBackAppBar(name: 'Login'),
      body: InAppWebView(
        initialUrlRequest: URLRequest(
          url: WebUri(
              'https://steamcommunity.com/openid/login?openid.identity=http%3A%2F%2Fspecs.openid.net%2Fauth%2F2.0%2Fidentifier_select&openid.claimed_id=http%3A%2F%2Fspecs.openid.net%2Fauth%2F2.0%2Fidentifier_select&openid.ns=http%3A%2F%2Fspecs.openid.net%2Fauth%2F2.0&openid.mode=checkid_setup&openid.return_to=https%3A%2F%2Fwww.steamgifts.com%2F'),
        ),
        onLoadStart: (controller, url) {
          _change(url, context);
        },
      ),
    );
  }
}
