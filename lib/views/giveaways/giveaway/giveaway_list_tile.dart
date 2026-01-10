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

import 'package:snag/common/custom_network_image.dart';
import 'package:snag/common/vars/globals.dart';
import 'package:snag/nav/custom_nav.dart';
import 'package:snag/provider_models/points_provider.dart';
import 'package:snag/provider_models/theme_provider.dart';
import 'package:snag/views/giveaways/giveaway/giveaway.dart';
import 'package:snag/views/giveaways/giveaway/giveaway_model.dart';
import 'package:snag/views/giveaways/giveaway/giveaway_theme.dart';

typedef TileChangeCallback = void Function();

class GiveawayListTile extends StatefulWidget {
  const GiveawayListTile({required this.giveaway, this.onTileChange, super.key});
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

  @override
  void initState() {
    super.initState();
    _copies = widget.giveaway.copies != null ? ' ${widget.giveaway.copies}' : null;
    _points = widget.giveaway.points != null
        ? '${widget.giveaway.points.toString()}P · '
        : null;
    _gaLevel = widget.giveaway.level > 0 ? 'L${widget.giveaway.level} · ' : '';
    _remaining = _remainingTime();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Consumer<ThemeProvider>(
          builder: (context, theme, child) => ListTile(
              selected: widget.giveaway.entered,
              leading: CustomNetworkImage(
                  image: widget.giveaway.image,
                  width: GiveawayListTileTheme.leadingWidth),
              title: Row(
                children: [
                  Flexible(
                    //flexible wraps the text if it is too long
                    child: Text(
                      widget.giveaway.name,
                      overflow: GiveawayListTileTheme.overflow,
                    ),
                  ),
                  widget.giveaway.copies != null
                      ? Text(
                          _copies!,
                        )
                      : Container()
                ],
              ),
              subtitle: Row(
                children: [
                  widget.giveaway.inviteOnly
                      ? Icon(Icons.lock,
                          size: GiveawayListTileTheme.iconSize + theme.fontSize)
                      : Container(),
                  widget.giveaway.group
                      ? Icon(Icons.groups,
                          size: GiveawayListTileTheme.iconSize + 3 + theme.fontSize,
                          color: Colors.green)
                      : Container(),
                  widget.giveaway.whitelist
                      ? Icon(Icons.favorite,
                          size: GiveawayListTileTheme.iconSize - 1 + theme.fontSize,
                          color: Colors.pinkAccent)
                      : Container(),
                  widget.giveaway.region
                      ? Icon(Icons.public,
                          size: GiveawayListTileTheme.iconSize + theme.fontSize,
                          color: Colors.blueGrey)
                      : Container(),
                  const SizedBox(width: 2),
                  widget.giveaway.points != null
                      ? Text(
                          _points!,
                        )
                      : Container(),
                  Text(_gaLevel,
                      style: TextStyle(
                          color: widget.giveaway.level <= userLevel ? null : Colors.red)),
                  Text(
                    '${widget.giveaway.entries} ',
                  ),
                  Icon(Icons.people,
                      size: GiveawayListTileTheme.iconSize + 2 + theme.fontSize),
                  Text(
                    _remaining,
                  )
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
                        width: GiveawayListTileTheme.trailingWidth,
                        height: GiveawayListTileTheme.trailingHeight,
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
                      widget.giveaway.entered =
                          await customNav(Giveaway(href: widget.giveaway.href!), context)
                              as bool;
                      setState(() {});
                    }
                  : null),
        ),
      ],
    );
  }

  String _remainingTime() {
    if (widget.giveaway.notEnded && !widget.giveaway.notStarted!) {
      if (widget.giveaway.remaining.split(' ').first == '1') {
        return ' · ${widget.giveaway.remaining}';
      }
      return ' · ${widget.giveaway.remaining}';
    } else if (widget.giveaway.notStarted!) {
      return ' · Begins in ${widget.giveaway.remaining}';
    } else {
      return ' · ${widget.giveaway.remaining} ago';
    }
  }
}
