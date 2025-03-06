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

import 'package:provider/provider.dart';

import 'package:snag/common/vars/globals.dart';
import 'package:snag/nav/custom_nav.dart';
import 'package:snag/provider_models/points_provider.dart';
import 'package:snag/views/giveaways/giveaway/giveaway.dart';
import 'package:snag/views/giveaways/giveaway/giveaway_model.dart';
import 'package:snag/views/giveaways/giveaway/giveaway_theme.dart';

typedef TileChangeCallback = void Function();

class GiveawayListTile extends StatefulWidget {
  const GiveawayListTile(
      {required this.giveaway, this.onTileChange, super.key});
  final GiveawayListModel giveaway;
  final TileChangeCallback? onTileChange;

  @override
  State<GiveawayListTile> createState() => _GiveawayListTileState();
}

class _GiveawayListTileState extends State<GiveawayListTile> {
  late final String? _copies;
  late final String? _points;
  late final String _gaLevel;
  late final String _remaining;
  late final TextStyle _levelTextStyle;

  @override
  void initState() {
    super.initState();
    _copies =
        widget.giveaway.copies != null ? ' ${widget.giveaway.copies}' : null;
    _points = widget.giveaway.points != null
        ? '${widget.giveaway.points.toString()}P · '
        : null;
    _gaLevel = widget.giveaway.level > 0 ? 'L${widget.giveaway.level} · ' : '';
    _levelTextStyle = TextStyle(
        fontSize: CustomListTileTheme.subtitleTextSize,
        color: widget.giveaway.level <= userLevel ? null : Colors.red);
    _remaining = _remainingTime();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
        contentPadding: CustomListTileTheme.contentPadding,
        minVerticalPadding: CustomListTileTheme.minVerticalPadding,
        dense: CustomListTileTheme.dense,
        selected: widget.giveaway.entered,
        leading: SizedBox(
            width: CustomListTileTheme.leadingWidth,
            child: widget.giveaway.image),
        title: Row(
          children: [
            Flexible(
              //flexible wraps the text if it is too long
              child: Text(
                widget.giveaway.name,
                style: CustomListTileTheme.titleTextStyle,
                overflow: CustomListTileTheme.overflow,
              ),
            ),
            widget.giveaway.copies != null
                ? Text(
                    _copies!,
                    style: CustomListTileTheme.titleTextStyle,
                  )
                : Container()
          ],
        ),
        subtitle: Row(
          children: [
            widget.giveaway.inviteOnly
                ? const Icon(Icons.lock, size: CustomListTileTheme.iconSize)
                : Container(),
            widget.giveaway.group
                ? const Icon(Icons.groups,
                    size: CustomListTileTheme.iconSize + 2, color: Colors.green)
                : Container(),
            widget.giveaway.whitelist
                ? const Icon(Icons.favorite,
                    size: CustomListTileTheme.iconSize,
                    color: Colors.pinkAccent)
                : Container(),
            widget.giveaway.region
                ? const Icon(Icons.public,
                    size: CustomListTileTheme.iconSize, color: Colors.blueGrey)
                : Container(),
            SizedBox(width: 2),
            widget.giveaway.points != null
                ? Text(_points!, style: CustomListTileTheme.subtitleTextStyle)
                : Container(),
            Text(_gaLevel, style: _levelTextStyle),
            Text('${widget.giveaway.entries} ',
                style: CustomListTileTheme.subtitleTextStyle),
            const Icon(Icons.people, size: CustomListTileTheme.iconSize),
            Text(_remaining, style: CustomListTileTheme.subtitleTextStyle)
          ],
        ),
        trailing: widget.onTileChange != null &&
                widget.giveaway.creator != username &&
                widget.giveaway.href != null &&
                widget.giveaway.notEnded &&
                widget.giveaway.level <= userLevel
            ? InkWell(
                onTap: () => widget.onTileChange!(),
                child: SizedBox(
                  width: CustomListTileTheme.trailingWidth,
                  height: CustomListTileTheme.trailingHeight,
                  child: widget.giveaway.entered
                      ? const Icon(Icons.remove)
                      : Consumer<PointsProvider>(
                          builder: (context, user, child) =>
                              (user.points >= (widget.giveaway.points as int))
                                  ? const Icon(Icons.add)
                                  : Container()),
                ))
            : const SizedBox(height: 0, width: 0),
        onTap: widget.giveaway.href != null
            ? () async {
                widget.giveaway.entered = await customNav(
                    Giveaway(href: widget.giveaway.href!), context) as bool;
                setState(() {});
              }
            : null);
  }

  String _remainingTime() {
    if (widget.giveaway.notEnded && !widget.giveaway.notStarted!) {
      if (widget.giveaway.remaining.split(' ').first == '1') {
        return ' · ${widget.giveaway.remaining} remains';
      }
      return ' · ${widget.giveaway.remaining} remain';
    } else if (widget.giveaway.notStarted!) {
      return ' · Begins in ${widget.giveaway.remaining}';
    } else {
      return ' · Ended ${widget.giveaway.remaining} ago';
    }
  }
}
