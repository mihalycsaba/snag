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

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:snag/objectbox/discussion_bookmark_model.dart';
import 'package:snag/objectbox/game_bookmark_model.dart';
import 'package:snag/objectbox/giveaway_bookmark_model.dart';
import 'package:snag/objectbox/group_bookmark_model.dart';
import 'package:snag/objectbox/objectbox.g.dart'; // created by `dart run build_runner build`
import 'package:snag/objectbox/user_bookmark_model.dart';

class ObjectBox {
  late final Store _store;
  late final Box<GiveawayBookmarkModel> _giveawayBookmarkBox;
  late final Box<DiscussionBookmarkModel> _discussionBookmarkBox;
  late final Box<UserBookmarkModel> _userBookmarkBox;
  late final Box<GameBookmarkModel> _gameBookmarkBox;
  late final Box<GroupBookmarkModel> _groupBookmarkBox;

  ObjectBox._create(this._store) {
    _giveawayBookmarkBox = Box<GiveawayBookmarkModel>(_store);
    _discussionBookmarkBox = Box<DiscussionBookmarkModel>(_store);
    _userBookmarkBox = Box<UserBookmarkModel>(_store);
    _gameBookmarkBox = Box<GameBookmarkModel>(_store);
    _groupBookmarkBox = Box<GroupBookmarkModel>(_store);
  }

  static Future<ObjectBox> create() async {
    final store = await openStore(
        directory: p.join(
            (await getApplicationDocumentsDirectory()).path, "obx-bookmarks"));
    return ObjectBox._create(store);
  }

  String _hrefSplit(String href, String split) =>
      href.split('$split/')[1].split('/')[0];

  // giveaways
  void addGiveawayBookmark(
      {required String href,
      required String name,
      required String type,
      required String appid,
      required int agoStamp,
      required int remainingStamp,
      required bool favourite}) {
    _giveawayBookmarkBox.put(GiveawayBookmarkModel(
        gaId: _hrefSplit(href, 'giveaway'),
        name: name,
        type: type,
        appid: appid,
        agoStamp: agoStamp,
        remainingStamp: remainingStamp,
        favourite: favourite));
  }

  void removeGiveawayBookmark(int id) => _giveawayBookmarkBox.remove(id);
  List<GiveawayBookmarkModel> getGiveawayBookmarked(String href) {
    return _giveawayBookmarkBox
        .query(GiveawayBookmarkModel_.gaId.equals(_hrefSplit(href, 'giveaway')))
        .build()
        .find();
  }

  List<GiveawayBookmarkModel> getGiveawayBookmarks() =>
      _giveawayBookmarkBox.query().build().find();

  void updateGiveawayBookmark({
    required int id,
    required String gaId,
    required String name,
    required String type,
    required String appid,
    required int agoStamp,
    required int remainingStamp,
    required bool favourite,
  }) =>
      _giveawayBookmarkBox.put(GiveawayBookmarkModel(
          id: id,
          gaId: gaId,
          name: name,
          type: type,
          appid: appid,
          agoStamp: agoStamp,
          remainingStamp: remainingStamp,
          favourite: favourite));

  // discussions
  void addDiscussionBookmark({
    required String href,
    required String name,
  }) =>
      _discussionBookmarkBox.put(DiscussionBookmarkModel(
        href: _hrefSplit(href, 'discussion'),
        name: name,
      ));
  void removeDiscussionBookmark(int id) => _discussionBookmarkBox.remove(id);
  List<DiscussionBookmarkModel> getDiscussionBookmarked(String href) =>
      _discussionBookmarkBox
          .query(DiscussionBookmarkModel_.href
              .equals(_hrefSplit(href, 'discussion')))
          .build()
          .find();
  List<DiscussionBookmarkModel> getDiscussionBookmarks() =>
      _discussionBookmarkBox.query().build().find();

  // users
  void addUserBookmark({
    required String name,
  }) =>
      _userBookmarkBox.put(UserBookmarkModel(
        name: name,
      ));
  void removeUserBookmark(int id) => _userBookmarkBox.remove(id);
  List<UserBookmarkModel> getUserBookmarked(String name) => _userBookmarkBox
      .query(UserBookmarkModel_.name.equals(name))
      .build()
      .find();
  List<UserBookmarkModel> getUserBookmarks() =>
      _userBookmarkBox.query().build().find();

  // games
  void addGameBookmark({
    required String name,
    required String href,
    required String type,
    required String appid,
  }) =>
      _gameBookmarkBox.put(GameBookmarkModel(
          name: name,
          href: _hrefSplit(href, 'game'),
          type: type,
          appid: appid));

  void removeGameBookmark(int id) => _gameBookmarkBox.remove(id);

  List<GameBookmarkModel> getGameBookmarked(String href) => _gameBookmarkBox
      .query(GameBookmarkModel_.href.equals(_hrefSplit(href, 'game')))
      .build()
      .find();

  List<GameBookmarkModel> getGameBookmarks() =>
      _gameBookmarkBox.query().build().find();

  // groups
  void addGroupBookmark({
    required String name,
    required String href,
  }) =>
      _groupBookmarkBox
          .put(GroupBookmarkModel(name: name, href: _hrefSplit(href, 'group')));

  void removeGroupBookmark(int id) => _groupBookmarkBox.remove(id);

  List<GroupBookmarkModel> getGroupBookmarked(String href) => _groupBookmarkBox
      .query(GroupBookmarkModel_.href.equals(_hrefSplit(href, 'group')))
      .build()
      .find();

  List<GroupBookmarkModel> getGroupBookmarks() =>
      _groupBookmarkBox.query().build().find();
}
