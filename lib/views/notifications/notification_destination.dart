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

import 'package:snag/nav/pages.dart';

String notificationDestination(int id) {
  switch (id) {
    case 0:
      return GiveawayPages.all.route;
    case 1:
      return NotificationsRoute.created.route;
    case 2:
      return NotificationsRoute.won.route;
    case 3:
      return NotificationsRoute.messages.route;
  }
  if (id >= 100 && id < 200) {
    return NotificationsRoute.created.route;
  } else if (id >= 200 && id < 300) {
    return NotificationsRoute.won.route;
  } else if (id >= 300 && id < 400) {
    return NotificationsRoute.messages.route;
  }
  return GiveawayPages.all.route;
}
