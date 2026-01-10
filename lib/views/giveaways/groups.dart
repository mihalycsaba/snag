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

import 'package:snag/common/custom_network_image.dart';
import 'package:snag/common/functions/fetch_body.dart';
import 'package:snag/common/functions/get_avatar.dart';
import 'package:snag/common/functions/resize_image.dart';
import 'package:snag/nav/custom_nav.dart';
import 'package:snag/views/common/custom_tile_theme.dart';
import 'package:snag/views/misc/group.dart';

class Groups extends StatefulWidget {
  const Groups({required this.groupUrl, super.key});

  final String groupUrl;

  @override
  State<Groups> createState() => _GroupsState();
}

class _GroupsState extends State<Groups> {
  final List<_GroupModel> _groups = [];

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    String data = await fetchBody(url: 'https://www.steamgifts.com/${widget.groupUrl}');
    dom.Document document = parse(data);
    document.getElementsByClassName('table__row-inner-wrap').forEach((element) {
      dom.Element group = element
          .getElementsByClassName('table__column--width-fill')[0]
          .nodes[1] as dom.Element;
      _groups.add(_GroupModel(
          name: group.text,
          url: group.attributes['href']!,
          avatar: getAvatar(element, 'table_image_avatar')));
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text('Groups'),
        ),
        body: ListView.builder(
          itemCount: _groups.length,
          itemBuilder: (context, index) => ListTile(
            contentPadding: CustomTileTheme.contentPadding,
            minVerticalPadding: CustomTileTheme.minVerticalPadding,
            leading: SizedBox(
              width: 40,
              height: 40,
              child: CustomNetworkImage(
                  image: resizeImage(_groups[index].avatar, 40), width: 40),
            ),
            title: Text(_groups[index].name),
            onTap: () => customNav(Group(href: _groups[index].url), context),
          ),
        ));
  }
}

class _GroupModel {
  _GroupModel({required this.name, required this.url, required this.avatar});
  final String name;
  final String url;
  final String avatar;
}
