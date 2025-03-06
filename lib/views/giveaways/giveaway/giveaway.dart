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

import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart';

import 'package:snag/common/functions/fetch_body.dart';
import 'package:snag/common/vars/globals.dart';
import 'package:snag/nav/custom_drawer.dart';
import 'package:snag/views/giveaways/error/error_page.dart';
import 'package:snag/views/giveaways/error/error_string.dart';
import 'package:snag/views/giveaways/giveaway/giveaway_details.dart';
import 'package:snag/views/misc/logged_out.dart';

class Giveaway extends StatefulWidget {
  final String href;
  const Giveaway({required this.href, super.key});

  @override
  State<Giveaway> createState() => _GiveawayState();
}

class _GiveawayState extends State<Giveaway> {
  String? _data = '';
  String _url = '';

  @override
  void initState() {
    super.initState();
    _url = "https://www.steamgifts.com${widget.href}";
  }

  @override
  Widget build(BuildContext context) {
    return isLoggedIn
        ? FutureBuilder(
            future: fetchBody(url: _url),
            builder: (context, snapshot) {
              try {
                Future<void> pullRefresh() async {
                  String newData = await fetchBody(url: _url);
                  setState(() {
                    _data = newData;
                  });
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasData) {
                  _data = snapshot.data;
                  dom.Document document = parse(_data);
                  String error = errorString(document);
                  if (error.contains("you have been blacklisted")) {
                    return FutureBuilder(
                        future: fetchBody(url: _url, isBlacklisted: true),
                        builder: (context, snapshot) {
                          _data = snapshot.data;
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          } else if (snapshot.hasData) {
                            return RefreshIndicator(
                                onRefresh: pullRefresh,
                                child: Scaffold(
                                  //extendBodyBehindAppBar: true,
                                  drawerEnableOpenDragGesture: false,
                                  drawer:
                                      const CustomDrawer(giveawaysOpen: true),
                                  body: _data != null
                                      ? GiveawayDetails(
                                          href: widget.href,
                                          data: _data!,
                                          isBlacklisted: true,
                                        )
                                      : Scaffold(body: Container()),
                                ));
                          }
                          return Scaffold(body: Container());
                        });
                  } else if (error.contains('required Steam groups')) {
                    return ErrorPage(
                        error:
                            'You are not a member of the required Steam groups.',
                        url: _url,
                        stackTrace: '');
                  } else if (error.contains(
                      "not a member of the giveaway creator's whitelist.")) {
                    return ErrorPage(
                        error:
                            "You are not a member of the giveaway creator's whitelist.",
                        url: _url,
                        stackTrace: '');
                  } else if (error.contains('Deleted ')) {
                    return ErrorPage(error: error, url: _url, stackTrace: '');
                  }
                  return RefreshIndicator(
                      onRefresh: pullRefresh,
                      child: Scaffold(
                        //extendBodyBehindAppBar: true,
                        drawerEnableOpenDragGesture: false,
                        drawer: const CustomDrawer(giveawaysOpen: true),
                        body: _data != null
                            ? GiveawayDetails(href: widget.href, data: _data!)
                            : Scaffold(body: Container()),
                      ));
                }
                return Container();
              } catch (e, s) {
                return ErrorPage(
                    error: e.toString(), url: _url, stackTrace: s.toString());
              }
            })
        : LoggedOut();
  }
}
