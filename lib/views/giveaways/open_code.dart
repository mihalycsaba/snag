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

import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:snag/nav/custom_back_appbar.dart';
import 'package:snag/nav/custom_nav.dart';
import 'package:snag/views/discussions/discussion.dart';
import 'package:snag/views/giveaways/giveaway/giveaway.dart';
import 'package:snag/views/giveaways/game.dart';
import 'package:snag/views/misc/group.dart';
import 'package:snag/views/misc/user.dart';

typedef _MenuEntry = DropdownMenuEntry<_MenuLabel>;

enum _MenuLabel {
  giveaway('Giveaway', 'giveaway'),
  discussion('Discussion', 'discussion'),
  user('User', 'user'),
  game('Game', 'game'),
  group('Group', 'group');

  final String name;
  final String? url;
  const _MenuLabel(this.name, this.url);

  static final List<_MenuEntry> labels = UnmodifiableListView<_MenuEntry>(
      values.map<_MenuEntry>(
          (_MenuLabel entry) => _MenuEntry(value: entry, label: entry.name)));
}

class OpenCode extends StatefulWidget {
  const OpenCode({super.key});

  @override
  State<OpenCode> createState() => _OpenCodeState();
}

class _OpenCodeState extends State<OpenCode> {
  _MenuLabel _selectedEntry = _MenuLabel.giveaway;
  final TextEditingController _controller = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomBackAppBar(name: 'Open Code'),
        body: Column(
          children: [
            Padding(
                padding: const EdgeInsets.all(16.0),
                child: _selectedEntry != _MenuLabel.user
                    ? const Text(
                        'Enter the 5 character random code from the URL to open:')
                    : const Text('Enter the username to open:')),
            Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    DropdownMenu<_MenuLabel>(
                      initialSelection: _selectedEntry,
                      dropdownMenuEntries: _MenuLabel.labels,
                      onSelected: (_MenuLabel? label) {
                        setState(() {
                          _selectedEntry = label!;
                        });
                      },
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: TextFormField(
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp("[0-9a-zA-Z]"))
                            ],
                            autovalidateMode: AutovalidateMode.disabled,
                            validator: (value) {
                              if (_selectedEntry != _MenuLabel.user) {
                                if (value?.length != 5) {
                                  return 'Invalid code: 5 characters';
                                }
                              } else {}
                              return null;
                            },
                            controller: _controller,
                            keyboardType: TextInputType.text,
                            decoration:
                                const InputDecoration(labelText: 'Code'),
                            onFieldSubmitted: ((value) => _open())),
                      ),
                    ),
                    ElevatedButton(
                        onPressed: () => _open(), child: const Text('Open'))
                  ],
                ),
              ),
            ),
          ],
        ));
  }

  void _open() {
    if (_formKey.currentState!.validate()) {
      Widget destination = Container();
      switch (_selectedEntry) {
        case _MenuLabel.giveaway:
          destination =
              Giveaway(href: '/${_selectedEntry.url}/${_controller.text}/');
          break;
        case _MenuLabel.discussion:
          destination =
              Discussion(href: '/${_selectedEntry.url}/${_controller.text}/');
          break;
        case _MenuLabel.user:
          destination = User(name: _controller.text);
          break;
        case _MenuLabel.game:
          destination =
              Game(href: '/${_selectedEntry.url}/${_controller.text}/');
          break;
        case _MenuLabel.group:
          destination =
              Group(href: '/${_selectedEntry.url}/${_controller.text}/');
          break;
      }
      customNav(destination, context);
    }
  }
}
