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

import 'package:flutter/widgets.dart';

abstract class GiveawayModel {
  String name;
  String entries;
  Widget image;
  String remaining;
  String? href;
  bool entered;
  bool notEnded;
  bool? notStarted;
  int? points;
  String? copies;
  String? ago;
  String? creator;
  bool inviteOnly;
  bool group;
  bool whitelist;
  bool region;
  int level;
  GiveawayModel(
      {required this.name,
      required this.entries,
      required this.image,
      required this.remaining,
      required this.href,
      required this.entered,
      required this.notEnded,
      required this.notStarted,
      required this.points,
      required this.copies,
      required this.ago,
      required this.creator,
      required this.inviteOnly,
      required this.group,
      required this.whitelist,
      required this.region,
      required this.level});
}

class GiveawayListModel extends GiveawayModel {
  GiveawayListModel(
      {required super.name,
      required super.entries,
      required super.image,
      required super.remaining,
      required super.href,
      required super.entered,
      required super.notEnded,
      required super.notStarted,
      required super.points,
      required super.copies,
      required super.ago,
      required super.creator,
      required super.inviteOnly,
      required super.group,
      required super.whitelist,
      required super.region,
      required super.level});
}
