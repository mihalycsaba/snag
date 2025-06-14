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

import 'package:go_router/go_router.dart';

import 'package:snag/common/functions/url_launcher.dart';
import 'package:snag/nav/custom_nav.dart';
import 'package:snag/nav/pages.dart';
import 'package:snag/views/misc/about.dart';

class LoggedOut extends StatelessWidget {
  const LoggedOut({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          children: [
            const Expanded(
              flex: 5,
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(
                  'Snag',
                  style: TextStyle(fontSize: 80, fontWeight: FontWeight.bold),
                ),
                Text(
                  textAlign: TextAlign.center,
                  'Client application for SteamGifts',
                  style: TextStyle(fontSize: 20),
                ),
              ]),
            ),
            Expanded(
              flex: 5,
              child: Center(
                child: GestureDetector(
                  onTap: () => urlLauncher('https://www.steamgifts.com/', true),
                  child: const Text.rich(
                      textAlign: TextAlign.center,
                      TextSpan(
                          text: 'You need an account on',
                          style: TextStyle(fontSize: 22),
                          children: [
                            TextSpan(
                                text: ' steamgifts.com ',
                                style:
                                    TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
                            TextSpan(
                                text: 'to use this app.', style: TextStyle(fontSize: 22)),
                          ])),
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Padding(
                  padding: EdgeInsets.all(14.0),
                  child: Text('If you have an account:', style: TextStyle(fontSize: 18)),
                ),
                FilledButton(
                    child: const Text(
                      'Login',
                      style: TextStyle(fontSize: 26),
                    ),
                    onPressed: () => context.push(LoginRoute.login.route)),
              ]),
            ),
            Expanded(
              flex: 2,
              child: TextButton(
                  onPressed: () => customNav(const About(), context),
                  child: const Text('About', style: TextStyle(fontSize: 20))),
            )
          ],
        ),
      ),
    ));
  }
}
