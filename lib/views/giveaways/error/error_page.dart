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
import 'package:share_plus/share_plus.dart';

import 'package:snag/nav/pages.dart';

class ErrorPage extends StatelessWidget {
  const ErrorPage(
      {super.key,
      required this.error,
      required this.url,
      required this.stackTrace});
  final String error;
  final String url;
  final String stackTrace;

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) {
            return;
          }
          _popPage(context);
        },
        child: Scaffold(
            appBar: _ErrorAppbar(url: url),
            body: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Center(
                    child: Text(
                      'An error occurred while loading the giveaway:',
                      style: TextStyle(color: Colors.red, fontSize: 20),
                    ),
                  ),
                  Column(
                    children: [Text(url), Text(error), Text(stackTrace)],
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
        onPressed: () {
          _popPage(context);
        },
      ),
      actions: <Widget>[
        GestureDetector(
          onTap: () => Share.shareUri(Uri.parse(url)),
          child: const Padding(
            padding: EdgeInsets.only(
                left: 10.0, right: 20.0, top: 10.0, bottom: 10.0),
            child: Icon(
              Icons.share,
            ),
          ),
        ),
      ],
    );
  }
}

void _popPage(BuildContext context) {
  if (context.canPop()) {
    Navigator.pop(context);
  } else {
    context.go(GiveawayPages.all.route);
  }
}
