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

import 'package:snag/common/vars/obx.dart';
import 'package:snag/nav/custom_nav.dart';
import 'package:snag/objectbox/group_bookmark_model.dart';
import 'package:snag/views/misc/group.dart';

class GroupBookmarks extends StatefulWidget {
  const GroupBookmarks({super.key});

  @override
  State<GroupBookmarks> createState() => _GroupBookmarksState();
}

class _GroupBookmarksState extends State<GroupBookmarks> {
  List<GroupBookmarkModel> _bookmarks = [];

  @override
  void initState() {
    super.initState();
    _bookmarks = objectbox.getGroupBookmarks();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: _bookmarks.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            title: Text(_bookmarks[index].name),
            onTap: () async {
              await customNav(Group(href: '/group/${_bookmarks[index].href}/'), context);
              _bookmarks = objectbox.getGroupBookmarks();
              setState(() {});
            },
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                          title: const Text('Delete'),
                          content: const Text(
                              'Are you sure you want to delete this bookmark?'),
                          actions: [
                            TextButton(
                              child: const Text('Cancel'),
                              onPressed: () => Navigator.pop(context),
                            ),
                            TextButton(
                              child: const Text('Yes'),
                              onPressed: () {
                                objectbox.removeGroupBookmark(_bookmarks[index].id);
                                _bookmarks = objectbox.getGroupBookmarks();
                                setState(() {});
                                Navigator.pop(context);
                              },
                            ),
                          ])),
            ),
          );
        });
  }
}
