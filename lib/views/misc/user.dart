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

import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import 'package:snag/common/card_theme.dart';
import 'package:snag/common/functions/add_page.dart';
import 'package:snag/common/functions/button_background_color.dart';
import 'package:snag/common/functions/fetch_body.dart';
import 'package:snag/common/functions/get_avatar.dart';
import 'package:snag/common/functions/res_map_ajax.dart';
import 'package:snag/common/functions/url_launcher.dart';
import 'package:snag/common/paged_progress_indicator.dart';
import 'package:snag/common/vars/globals.dart';
import 'package:snag/common/vars/obx.dart';
import 'package:snag/common/vars/prefs.dart';
import 'package:snag/nav/pages.dart';
import 'package:snag/objectbox/user_bookmark_model.dart';
import 'package:snag/provider_models/theme_provider.dart';
import 'package:snag/views/discussions/discussion_model.dart';
import 'package:snag/views/discussions/discussions_list.dart';
import 'package:snag/views/giveaways/error/error_page.dart';
import 'package:snag/views/giveaways/functions/change_giveaway_state.dart';
import 'package:snag/views/giveaways/functions/parse_giveaway_list.dart';
import 'package:snag/views/giveaways/giveaway/giveaway_list_tile.dart';
import 'package:snag/views/giveaways/giveaway/giveaway_model.dart';
import 'package:snag/views/misc/logged_out.dart';

enum _ListType {
  whitelist('whitelist'),
  blacklist('blacklist');

  final String type;
  const _ListType(this.type);
}

class User extends StatefulWidget {
  const User({required this.name, super.key});
  final String name;

  @override
  State<User> createState() => _UserState();
}

class _UserState extends State<User> {
  static const TextStyle _detailsTextStyle = TextStyle(fontSize: 12);
  List<UserBookmarkModel> _bookmark = [];
  bool _bookmarked = false;
  bool _notLoading = true;
  final PagingController<int, GiveawayListModel> _giveawayPagingController =
      PagingController(firstPageKey: 1);
  final PagingController<int, DiscussionModel> _discussionsPagingController =
      PagingController(firstPageKey: 1);
  String _list = '';
  late String _url;
  late WidgetStateProperty<Color?> _bgColor;
  _UserModel _user = _UserModel(
      image: Container(),
      role: '',
      online: '',
      registered: '',
      comments: '',
      entered: '',
      won: '',
      sent: '',
      level: '',
      steam: '',
      id: '',
      whitelisted: false,
      blacklisted: false);
  late bool _isUser;
  late final String _href;
  String _exception = '';
  String _stackTrace = '';

  @override
  void initState() {
    super.initState();
    _isUser = widget.name == username;
    _href = '/user/${widget.name}';
    _bookmark = objectbox.getUserBookmarked(widget.name);
    _bookmarked = _bookmark.isNotEmpty;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _url = 'https://www.steamgifts.com$_href';
    _bgColor = buttonBackgroundColor(context);
    _giveawayPagingController.addPageRequestListener(
        (pageKey) => _fetchGiveawayList(pageKey, '$_url$_list', context));
    _discussionsPagingController.addPageRequestListener((pageKey) => fetchDiscussions(
        user: true,
        pagingController: _discussionsPagingController,
        pageKey: pageKey,
        url: '$_url/discussions/search?',
        context: context));
  }

  @override
  void dispose() {
    _giveawayPagingController.dispose();
    _discussionsPagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(context) {
    return _exception.isEmpty
        ? isLoggedIn
            ? Scaffold(
                appBar: AppBar(
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go(GiveawayPages.all.route);
                      }
                    },
                  ),
                  title: Text(widget.name, style: const TextStyle(fontSize: 18)),
                  backgroundColor: Theme.of(context).colorScheme.inversePrimary,
                  actions: <Widget>[
                    _isUser
                        ? Container()
                        : Padding(
                            padding: const EdgeInsets.only(right: 10.0),
                            child: InkWell(
                                onTap: _notLoading
                                    ? () {
                                        setState(() {
                                          _notLoading = false;
                                        });
                                        _changeListState(
                                            _ListType.whitelist, _user.whitelisted!);
                                      }
                                    : null,
                                child: _user.whitelisted!
                                    ? const Icon(Icons.favorite,
                                        color: Colors.lightBlueAccent)
                                    : const Icon(Icons.favorite_outline)),
                          ),
                    _isUser
                        ? Container()
                        : Padding(
                            padding: const EdgeInsets.only(right: 10.0),
                            child: InkWell(
                                onTap: _notLoading
                                    ? !_user.blacklisted!
                                        ? () => showDialog(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                title: const Text('Blacklist'),
                                                content: Text(
                                                    'Are you sure you want to blacklist ${widget.name}?'),
                                                actions: <Widget>[
                                                  TextButton(
                                                    child: const Text('Cancel'),
                                                    onPressed: () =>
                                                        Navigator.pop(context),
                                                  ),
                                                  TextButton(
                                                    child: const Text('Yes'),
                                                    onPressed: () {
                                                      _changeListState(
                                                        _ListType.blacklist,
                                                        _user.blacklisted!,
                                                      );
                                                      Navigator.pop(context);
                                                    },
                                                  ),
                                                ],
                                              ),
                                            )
                                        : () => _changeListState(
                                              _ListType.blacklist,
                                              _user.blacklisted!,
                                            )
                                    : null,
                                child: _user.blacklisted!
                                    ? const Icon(Icons.block, color: Colors.red)
                                    : const Icon(Icons.block)),
                          ),
                    _isUser
                        ? Container()
                        : Padding(
                            padding: const EdgeInsets.only(right: 7.0),
                            child: InkWell(
                              onTap: () {
                                _changeBookmark();
                                setState(() {
                                  _bookmarked = !_bookmarked;
                                });
                              },
                              child: Icon(
                                  _bookmarked ? Icons.bookmark : Icons.bookmark_border),
                            ),
                          ),
                    InkWell(
                      onTap: () =>
                          SharePlus.instance.share(ShareParams(uri: Uri.parse(_url))),
                      child: const Icon(Icons.share),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 10.0),
                      child: IconButton(
                          onPressed: () => urlLauncher(_user.steam),
                          icon: const FaIcon(FontAwesomeIcons.steamSymbol)),
                    )
                  ],
                ),
                body: RefreshIndicator(
                  onRefresh: () => Future.sync(() => _giveawayPagingController.refresh()),
                  child: Center(
                    child: Column(
                      children: [
                        Card(
                          surfaceTintColor: CustomCardTheme.surfaceTintColor,
                          elevation: CustomCardTheme.elevation,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                SizedBox(width: 80, height: 80, child: _user.image),
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: SizedBox(
                                    width: 170,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Role: ${_user.role}',
                                          style: _detailsTextStyle,
                                        ),
                                        Row(
                                          children: [
                                            const Text(
                                              'Online: ',
                                              style: _detailsTextStyle,
                                            ),
                                            Text(
                                              _user.online,
                                              style: _user.online.contains('Online')
                                                  ? const TextStyle(
                                                      color: Colors.green, fontSize: 12)
                                                  : _detailsTextStyle,
                                            ),
                                          ],
                                        ),
                                        Text(
                                          'Registered: ${_user.registered}',
                                          style: _detailsTextStyle,
                                        ),
                                        Text(
                                          'Comments: ${_user.comments}',
                                          style: _detailsTextStyle,
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Entered: ${_user.entered}',
                                      style: _detailsTextStyle,
                                    ),
                                    Text(
                                      'Won: ${_user.won}',
                                      style: _detailsTextStyle,
                                    ),
                                    Text(
                                      'Sent: ${_user.sent}',
                                      style: _detailsTextStyle,
                                    ),
                                    Text(
                                      'Level: ${_user.level}',
                                      style: _detailsTextStyle,
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            TextButton(
                                style: ButtonStyle(
                                  backgroundColor: _list == '' ? _bgColor : null,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _list = '';
                                  });
                                  _giveawayPagingController.refresh();
                                },
                                child: const Text('Sent')),
                            TextButton(
                              style: ButtonStyle(
                                backgroundColor:
                                    _list == '/giveaways/won' ? _bgColor : null,
                              ),
                              onPressed: () {
                                setState(() {
                                  _list = '/giveaways/won';
                                });
                                _giveawayPagingController.refresh();
                              },
                              child: const Text('Won'),
                            ),
                            TextButton(
                              style: ButtonStyle(
                                backgroundColor:
                                    _list == '/discussions' ? _bgColor : null,
                              ),
                              onPressed: () {
                                setState(() {
                                  _list = '/discussions';
                                  _discussionsPagingController.refresh();
                                });
                              },
                              child: const Text('Discussions'),
                            ),
                          ],
                        ),
                        Flexible(
                          child: _list == '/discussions'
                              ? DiscussionsList(
                                  pagingController: _discussionsPagingController)
                              : Consumer<ThemeProvider>(
                                  builder: (context, theme, child) => PagedListView<int,
                                          GiveawayListModel>(
                                      itemExtent: CustomPagedListTheme.itemExtent +
                                          addItemExtent(theme.fontSize),
                                      pagingController: _giveawayPagingController,
                                      builderDelegate:
                                          PagedChildBuilderDelegate<GiveawayListModel>(
                                              itemBuilder: (context, giveaway, index) =>
                                                  Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      GiveawayListTile(
                                                        giveaway: giveaway,
                                                        onTileChange: () =>
                                                            changeGiveawayState(giveaway,
                                                                context, setState),
                                                      ),
                                                    ],
                                                  ),
                                              newPageProgressIndicatorBuilder:
                                                  (context) =>
                                                      const PagedProgressIndicator())),
                                ),
                        ),
                      ],
                    ),
                  ),
                ))
            : const LoggedOut()
        : ErrorPage(error: _exception, url: _url, stackTrace: _stackTrace, type: 'user');
  }

  Future<void> _fetchGiveawayList(int pageKey, String page, BuildContext context) async {
    String data = await fetchBody(url: '$page?page=${pageKey.toString()}');
    _isUser = widget.name == username;
    try {
      dom.Element container = parse(data).getElementsByClassName('widget-container')[0];

      if (pageKey == 1 && _list == '') {
        dom.Element header =
            parse(data).getElementsByClassName('featured__inner-wrap')[0];
        List<dom.Element> details =
            header.getElementsByClassName('featured__table__column');
        dom.Element buttons =
            container.getElementsByClassName('sidebar__shortcut-inner-wrap')[0];
        _user = _UserModel(
            image: CachedNetworkImage(
                errorWidget: (context, url, error) => const SizedBox(
                      width: 80,
                      height: 80,
                      child: DecoratedBox(
                          decoration: BoxDecoration(color: Colors.grey),
                          child: Icon(Icons.error)),
                    ),
                width: 80,
                height: 80,
                imageUrl: getAvatar(header, 'global__image-inner-wrap')),
            role: details[0]
                .getElementsByClassName('featured__table__row')[0]
                .getElementsByClassName('featured__table__row__right')[0]
                .text
                .trim(),
            online: details[0]
                .getElementsByClassName('featured__table__row')[1]
                .getElementsByClassName('featured__table__row__right')[0]
                .text
                .trim(),
            registered: details[0]
                .getElementsByClassName('featured__table__row')[2]
                .getElementsByClassName('featured__table__row__right')[0]
                .text
                .trim(),
            comments: details[0]
                .getElementsByClassName('featured__table__row')[3]
                .getElementsByClassName('featured__table__row__right')[0]
                .text
                .trim(),
            entered: details[1]
                .getElementsByClassName('featured__table__row')[0]
                .getElementsByClassName('featured__table__row__right')[0]
                .text
                .trim(),
            won: details[1]
                .getElementsByClassName('featured__table__row')[1]
                .getElementsByClassName('featured__table__row__right')[0]
                .text
                .trim(),
            sent: details[1]
                .getElementsByClassName('featured__table__row')[2]
                .getElementsByClassName('featured__table__row__right')[0]
                .text
                .trim(),
            level: jsonDecode(details[1]
                .getElementsByClassName('featured__table__row')[3]
                .getElementsByClassName('featured__table__row__right')[0]
                .children[0]
                .attributes['data-ui-tooltip']!)['rows'][0]['columns'][1]['name'],
            steam: _isUser
                ? buttons.children[0].attributes['href']!
                : buttons.children[3].attributes['href']!,
            id: _isUser
                ? null
                : buttons.children[0].children[0].children[2].attributes['value']!,
            whitelisted: _isUser
                ? null
                : buttons
                    .getElementsByClassName('sidebar__shortcut__whitelist is-selected')
                    .isNotEmpty,
            blacklisted: _isUser
                ? null
                : buttons
                    .getElementsByClassName('sidebar__shortcut__blacklist is-selected')
                    .isNotEmpty);
        setState(() {});
      }
      List<GiveawayListModel> giveaways = parseList(container, widget.name);
      addPage(giveaways, _giveawayPagingController, pageKey, container);
    } catch (error, stack) {
      _exception = error.toString();
      _stackTrace = stack.toString();
      setState(() {});
    }
  }

  Future<void> _changeListState(_ListType type, bool active) async {
    setState(() {
      _notLoading = false;
    });
    String xsrf = prefs.getString(PrefsKeys.xsrf.key)!;
    String body = active
        ? 'xsrf_token=$xsrf&do=${type.type}&child_user_id=${_user.id}&action=delete'
        : 'xsrf_token=$xsrf&do=${type.type}&child_user_id=${_user.id}&action=insert';
    Map responseMap = await resMapAjax(body);
    if (responseMap['type'] == 'success') {
      if (type == _ListType.whitelist) {
        !_user.whitelisted! && _user.blacklisted! ? _user.blacklisted = false : null;
        _user.whitelisted = !_user.whitelisted!;
      } else {
        !_user.blacklisted! && _user.whitelisted! ? _user.whitelisted = false : null;
        _user.blacklisted = !_user.blacklisted!;
      }
      setState(() {
        _notLoading = true;
      });
    }
  }

  void _changeBookmark() {
    if (_bookmarked) {
      _bookmark = objectbox.getUserBookmarked(widget.name);
      objectbox.removeUserBookmark(_bookmark.first.id);
    } else {
      objectbox.addUserBookmark(name: widget.name);
    }
  }
}

class _UserModel {
  final Widget image;
  final String role;
  final String online;
  final String registered;
  final String comments;
  final String entered;
  final String won;
  final String sent;
  final String level;
  final String steam;
  final String? id;
  bool? whitelisted;
  bool? blacklisted;
  _UserModel(
      {required this.image,
      required this.role,
      required this.online,
      required this.registered,
      required this.comments,
      required this.entered,
      required this.won,
      required this.sent,
      required this.level,
      required this.steam,
      required this.id,
      required this.whitelisted,
      required this.blacklisted});
}
