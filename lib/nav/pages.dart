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

import 'package:snag/views/discussions/discussions.dart';
import 'package:snag/views/giveaways/giveaway/giveaway_list.dart';

abstract class _PageRoute {
  final String route;

  const _PageRoute(this.route);
}

abstract class Pages extends _PageRoute {
  final String url;
  final String name;

  const Pages(this.url, this.name, super.route);
}

class PagesList {
  final List<Pages> pagesList;

  static const giveawaypages = PagesList([
    GiveawayPages.all,
    GiveawayPages.wishlist,
    GiveawayPages.group,
    GiveawayPages.dlc,
    GiveawayPages.multi,
    GiveawayPages.recommended,
    GiveawayPages.latest
  ]);

  static const discussionpages = PagesList([
    DiscussionPages.subscribed,
    DiscussionPages.all,
    DiscussionPages.tools,
    DiscussionPages.announcements,
    DiscussionPages.suggestions,
    DiscussionPages.deals,
    DiscussionPages.showcase,
    DiscussionPages.general,
    DiscussionPages.recruitment,
    DiscussionPages.hardware,
    DiscussionPages.help,
    DiscussionPages.letsplay,
    DiscussionPages.movies,
    DiscussionPages.offtopic,
    DiscussionPages.puzzles,
    DiscussionPages.projects,
    DiscussionPages.whitelist
  ]);
  List<Pages> get pages => pagesList;

  const PagesList(this.pagesList);
}

class GiveawayPages extends Pages {
  static const all =
      GiveawayPages("https://www.steamgifts.com/giveaways/search?", "All", "/");
  static const wishlist = GiveawayPages(
      "https://www.steamgifts.com/giveaways/search?type=wishlist",
      "Wishlist",
      "/wishlist");
  static const group = GiveawayPages(
      "https://www.steamgifts.com/giveaways/search?type=group", "Group", "/group");
  static const dlc = GiveawayPages(
      "https://www.steamgifts.com/giveaways/search?dlc=true", "DLC", "/dlc");
  static const multi = GiveawayPages(
      "https://www.steamgifts.com/giveaways/search?copy_min=2", "Multiple", "/multiple");
  static const recommended = GiveawayPages(
      "https://www.steamgifts.com/giveaways/search?type=recommended",
      "Recommended",
      "/recommended");
  static const latest = GiveawayPages(
      "https://www.steamgifts.com/giveaways/search?type=new", "Latest", "/latest");

  static Map<String, Widget> get widgetsMap => {
        all.route: const GiveawayList(page: GiveawayPages.all),
        wishlist.route: const GiveawayList(page: GiveawayPages.wishlist),
        group.route: const GiveawayList(page: GiveawayPages.group),
        dlc.route: const GiveawayList(page: GiveawayPages.dlc),
        multi.route: const GiveawayList(page: GiveawayPages.multi),
        recommended.route: const GiveawayList(page: GiveawayPages.recommended),
        latest.route: const GiveawayList(page: GiveawayPages.latest),
      };

  const GiveawayPages(super._url, super._name, super._route);
}

class Entered extends Pages {
  static const entered = Entered(
      "https://www.steamgifts.com/giveaways/entered/search?", "Entered", "/entered");

  const Entered(super._url, super._name, super._route);
}

class DiscussionPages extends Pages {
  static const subscribed = DiscussionPages(
      "https://www.steamgifts.com/discussions/subscribed/search?",
      "Subscribed",
      "/discussions/subscribed");
  static const all = DiscussionPages(
      "https://www.steamgifts.com/discussions/search?", "All", "/discussions");
  static const tools = DiscussionPages(
      "https://www.steamgifts.com/discussions/addons-tools/search?",
      "Addons & Tools",
      "/discussions/addons-tools");
  static const announcements = DiscussionPages(
      "https://www.steamgifts.com/discussions/announcements/search?",
      "Announcements",
      "/discussions/announcements");
  static const suggestions = DiscussionPages(
      "https://www.steamgifts.com/discussions/bugs-suggestions/search?",
      "Bugs & Suggestions",
      "/discussions/bugs-suggestions");
  static const deals = DiscussionPages(
      "https://www.steamgifts.com/discussions/deals/search?",
      "Deals",
      "/discussions/deals");
  static const showcase = DiscussionPages(
      "https://www.steamgifts.com/discussions/game-showcase/search?",
      "Game Showcase",
      "/discussions/game-showcase");
  static const general = DiscussionPages(
      "https://www.steamgifts.com/discussions/general/search?",
      "General",
      "/discussions/general");
  static const recruitment = DiscussionPages(
      "https://www.steamgifts.com/discussions/group-recruitment/search?",
      "Group Recruitment",
      "/discussions/group-recruitment");
  static const hardware = DiscussionPages(
      "https://www.steamgifts.com/discussions/hardware/search?",
      "Hardware",
      "/discussions/hardware");
  static const help = DiscussionPages(
    "https://www.steamgifts.com/discussions/help/search?",
    "Help",
    "/discussions/help",
  );
  static const letsplay = DiscussionPages(
    "https://www.steamgifts.com/discussions/lets-play-together/search?",
    "Let's Play Together",
    "/discussions/lets-play-together",
  );
  static const movies = DiscussionPages(
    "https://www.steamgifts.com/discussions/movies-tv/search?",
    "Movies & TV",
    "/discussions/movies-tv",
  );
  static const offtopic = DiscussionPages(
    "https://www.steamgifts.com/discussions/off-topic/search?",
    "Off Topic",
    "/discussions/off-topic",
  );
  static const puzzles = DiscussionPages(
    "https://www.steamgifts.com/discussions/puzzles-events/search?",
    "Puzzles & Events",
    "/discussions/puzzles-events",
  );
  static const projects = DiscussionPages(
    "https://www.steamgifts.com/discussions/user-projects/search?",
    "User Projects",
    "/discussions/user-projects",
  );
  static const whitelist = DiscussionPages(
    "https://www.steamgifts.com/discussions/whitelist-recruitment/search?",
    "Whitelist Recruitment",
    "/discussions/whitelist-recruitment",
  );

  static Map<String, Widget> get widgetsMap => {
        subscribed.route: const Discussions(page: DiscussionPages.subscribed),
        all.route: const Discussions(page: DiscussionPages.all),
        tools.route: const Discussions(page: DiscussionPages.tools),
        announcements.route: const Discussions(page: DiscussionPages.announcements),
        suggestions.route: const Discussions(page: DiscussionPages.suggestions),
        deals.route: const Discussions(page: DiscussionPages.deals),
        showcase.route: const Discussions(page: DiscussionPages.showcase),
        general.route: const Discussions(page: DiscussionPages.general),
        recruitment.route: const Discussions(page: DiscussionPages.recruitment),
        hardware.route: const Discussions(page: DiscussionPages.hardware),
        help.route: const Discussions(page: DiscussionPages.help),
        letsplay.route: const Discussions(page: DiscussionPages.letsplay),
        movies.route: const Discussions(page: DiscussionPages.movies),
        offtopic.route: const Discussions(page: DiscussionPages.offtopic),
        puzzles.route: const Discussions(page: DiscussionPages.puzzles),
        projects.route: const Discussions(page: DiscussionPages.projects),
        whitelist.route: const Discussions(page: DiscussionPages.whitelist)
      };

  const DiscussionPages(super._url, super._name, super._route);
}

class LoginRoute extends _PageRoute {
  static const login = LoginRoute("/login");

  const LoginRoute(super.route);
}

class NotificationsRoute extends _PageRoute {
  static const created = NotificationsRoute("/created");
  static const won = NotificationsRoute("/won");
  static const messages = NotificationsRoute("/messages");

  const NotificationsRoute(super.route);
}

class GiveawayRoute extends _PageRoute {
  static const giveaway = GiveawayRoute("/giveaway");

  const GiveawayRoute(super.route);
}

class DiscussionRoute extends _PageRoute {
  static const discussion = DiscussionRoute("/discussion");

  const DiscussionRoute(super.route);
}

class UserRoute extends _PageRoute {
  static const user = UserRoute("/user");

  const UserRoute(super.route);
}

class GroupRoute extends _PageRoute {
  static const group = GroupRoute("/group");

  const GroupRoute(super.route);
}

class GameRoute extends _PageRoute {
  static const game = GameRoute("/game");

  const GameRoute(super.route);
}
