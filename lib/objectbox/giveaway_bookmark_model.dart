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

import 'package:objectbox/objectbox.dart';

@Entity()
class GiveawayBookmarkModel {
  @Id()
  int id;
  String gaId;
  String name;
  String type;
  String appid;
  int agoStamp;
  int remainingStamp;
  bool favourite;

  GiveawayBookmarkModel(
      {this.id = 0,
      required this.gaId,
      required this.name,
      required this.type,
      required this.appid,
      required this.agoStamp,
      required this.remainingStamp,
      required this.favourite});
}
