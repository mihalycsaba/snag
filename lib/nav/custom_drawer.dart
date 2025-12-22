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
import 'package:provider/provider.dart';

import 'package:snag/common/custom_network_image.dart';
import 'package:snag/common/vars/globals.dart';
import 'package:snag/nav/custom_nav.dart';
import 'package:snag/nav/go_nav.dart';
import 'package:snag/nav/pages.dart';
import 'package:snag/provider_models/theme_provider.dart';
import 'package:snag/views/bookmarks/bookmarks.dart';
import 'package:snag/views/misc/about.dart';
import 'package:snag/views/misc/open_code.dart';
import 'package:snag/views/misc/settings.dart';
import 'package:snag/views/misc/user.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({
    super.key,
    required this.giveawaysOpen,
  });
  final bool giveawaysOpen;
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          const SizedBox(height: 12),
          Consumer<ThemeProvider>(
            builder: (context, theme, child) => ListTile(
              minVerticalPadding: 3,
              dense: true,
              leading: CustomNetworkImage(url: avatar, resize: false, width: 36),
              title: Text(username,
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14.0 + theme.fontSize)),
              subtitle: Text('Level $userLevel',
                  style: TextStyle(fontSize: 12.0 + theme.fontSize)),
              onTap: () => customNav(User(name: username), context),
            ),
          ),
          const Divider(height: 0),
          ExpansionTile(
              initiallyExpanded: giveawaysOpen,
              title: const Text('Giveaways'),
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: _ExpansionListView(
                      pages: PagesList.giveawaypages, map: GiveawayPages.widgetsMap),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: ListTile(
                      title: Text(Entered.entered.name),
                      onTap: () => goNav(context, Entered.entered.route)),
                )
              ]),
          const Divider(height: 0),
          ExpansionTile(
              initiallyExpanded: !giveawaysOpen,
              title: const Text('Discussions'),
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: _ExpansionListView(
                      pages: PagesList.discussionpages, map: DiscussionPages.widgetsMap),
                ),
              ]),
          const Divider(height: 0),
          ListTile(
            title: const Text('Notifications'),
            onTap: () => context.push(NotificationsRoute.messages.route),
          ),
          ListTile(
            title: const Text('Bookmarks'),
            onTap: () => customNav(const Bookmarks(), context),
          ),
          ListTile(
            title: const Text('Open Code'),
            onTap: () => customNav(const OpenCode(), context),
          ),
          const SizedBox(height: 20),
          ListTile(
            title: const Text('Settings'),
            onTap: () => customNav(const Settings(), context),
          ),
          const SizedBox(height: 10),
          ListTile(
            title: const Text('About'),
            onTap: () => customNav(const About(), context),
          )
        ],
      ),
    );
  }
}

class _ExpansionListView extends StatelessWidget {
  const _ExpansionListView({required this.pages, required this.map});
  final PagesList pages;
  final Map<String, Widget> map;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        itemCount: pages.pages.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
              title: Text(pages.pages[index].name),
              onTap: () {
                goNav(context, pages.pages[index].route);
              });
        });
  }
}
