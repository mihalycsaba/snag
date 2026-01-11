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

import 'package:share_plus/share_plus.dart';

import 'package:snag/common/functions/pop_nav.dart';
import 'package:snag/common/vars/prefs.dart';
import 'package:snag/nav/pages.dart';

class ErrorPage extends StatelessWidget {
  const ErrorPage(
      {super.key,
      required this.error,
      required this.url,
      this.stackTrace,
      required this.type});
  final String error;
  final String url;
  final String? stackTrace;
  final String type;

  @override
  Widget build(BuildContext context) {
    double fontSize = prefs.getInt(PrefsKeys.fontSize.key)!.toDouble();
    return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) =>
            popNav(context: context, didPop: didPop, route: GiveawayPages.all.route),
        child: Scaffold(
            appBar: _ErrorAppbar(url: url),
            body: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: Text(
                      'An error occurred while loading the $type:',
                      style: TextStyle(color: Colors.red, fontSize: 20 + fontSize),
                    ),
                  ),
                  Center(
                      child: Text(
                    stackTrace == null ? error : 'Most likely the URL is invalid.',
                    style: TextStyle(color: Colors.blue, fontSize: 18 + fontSize),
                  )),
                  Column(
                    children: [
                      Text('URL: $url',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      stackTrace != null ? Text(error) : Container(),
                      stackTrace != null ? Text(stackTrace!) : Container(),
                    ],
                  )
                ],
              ),
            )));
  }
}

class _ErrorAppbar extends StatelessWidget implements PreferredSizeWidget {
  const _ErrorAppbar({required this.url})
      : preferredSize = const Size.fromHeight(kToolbarHeight);

  final String url;

  @override
  final Size preferredSize;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('Error'),
      backgroundColor: Colors.red,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => popRoute(context: context, route: GiveawayPages.all.route),
      ),
      actions: <Widget>[
        GestureDetector(
          onTap: () => SharePlus.instance.share(ShareParams(uri: Uri.parse(url))),
          child: const Padding(
            padding: EdgeInsets.only(left: 10.0, right: 20.0, top: 10.0, bottom: 10.0),
            child: Icon(
              Icons.share,
            ),
          ),
        ),
      ],
    );
  }
}
