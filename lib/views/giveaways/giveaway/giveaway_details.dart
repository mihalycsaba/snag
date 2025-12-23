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

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import 'package:snag/common/card_theme.dart';
import 'package:snag/common/custom_network_image.dart';
import 'package:snag/common/functions/res_status_code.dart';
import 'package:snag/common/functions/url_launcher.dart';
import 'package:snag/common/image_sliver_appbar.dart';
import 'package:snag/common/vars/globals.dart';
import 'package:snag/common/vars/obx.dart';
import 'package:snag/nav/custom_nav.dart';
import 'package:snag/nav/pages.dart';
import 'package:snag/objectbox/giveaway_bookmark_model.dart';
import 'package:snag/provider_models/points_provider.dart';
import 'package:snag/provider_models/theme_provider.dart';
import 'package:snag/views/comments/comment_editor.dart';
import 'package:snag/views/comments/comment_message.dart';
import 'package:snag/views/comments/comments.dart';
import 'package:snag/views/comments/refresh_controller.dart';
import 'package:snag/views/giveaways/error/error_page.dart';
import 'package:snag/views/giveaways/error/error_string.dart';
import 'package:snag/views/giveaways/functions/change_giveaway_state.dart';
import 'package:snag/views/giveaways/functions/get_points.dart';
import 'package:snag/views/giveaways/game.dart';
import 'package:snag/views/giveaways/giveaway/giveaway_model.dart';
import 'package:snag/views/giveaways/giveaway/winners.dart';
import 'package:snag/views/giveaways/groups.dart';
import 'package:snag/views/misc/user.dart';

class _GiveawayDetailsModel extends GiveawayModel {
  String? creatorHref;
  String? steamHref;
  String? error;
  String? winners;
  String gameID;
  bool hidden;
  String more;
  _GiveawayDetailsModel(
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
      required super.level,
      required this.creatorHref,
      required this.steamHref,
      required this.error,
      required this.winners,
      required this.gameID,
      required this.hidden,
      required this.more});
}

class GiveawayDetails extends StatefulWidget {
  const GiveawayDetails(
      {required this.href, required this.data, this.isBlacklisted = false, super.key});
  final String href;
  final String data;
  final bool isBlacklisted;

  @override
  State<GiveawayDetails> createState() => _GiveawayDetailsState();
}

class _GiveawayDetailsState extends State<GiveawayDetails> {
  static const double _detailsFontSize = 14;
  String _type = '';
  String _appid = '';
  List<dom.Element> _descriptionText = [];
  Widget _description = Container();
  late _GiveawayDetailsModel _giveaway;
  String _exception = '';
  String _stackTrace = '';
  String _url = '';
  String _name = '';
  String _agoStamp = '';
  String _remainingStamp = '';
  List<GiveawayBookmarkModel> _bookmark = [];
  bool _bookmarked = false;
  final RefreshController _controller = RefreshController();
  final ScrollController _scrollController = ScrollController();
  double _padding = 0;
  double _appbarHeight = 0;
  dom.Document _document = dom.Document();
  static const double _iconSize = 18.0;
  static const EdgeInsets _iconPadding = EdgeInsets.only(left: 4.0);
  String _groupUrl = '';

  @override
  void initState() {
    super.initState();
    try {
      _url = 'https://www.steamgifts.com${widget.href}';
      _document = parse(widget.data);
      List<String> values = _document
          .getElementsByClassName(
              'global__image-outer-wrap global__image-outer-wrap--game-large')[0]
          .attributes['href']!
          .split('/');
      _type = values[3];
      _appid = values[4].split('?')[0];
      List<dom.Element> group =
          _document.getElementsByClassName('featured__column--group');
      bool groupNotEmpty = group.isNotEmpty;
      _groupUrl = groupNotEmpty ? group[0].attributes['href']! : '';
      List<dom.Element> headingSmall =
          _document.getElementsByClassName('featured__heading__small');
      bool noCopies = headingSmall.length == 1;
      bool hasScreenshots =
          _document.getElementsByClassName('fa fa-fw fa-camera').isNotEmpty;
      int moreIndex = noCopies ? 4 : 5;
      moreIndex = hasScreenshots ? moreIndex : moreIndex - 1;
      String points = noCopies ? headingSmall[0].text : headingSmall[1].text;
      dom.Element createdElement = _document.getElementsByClassName(
          'featured__column featured__column--width-fill text-right')[0];
      dom.Node ago = createdElement.nodes[0];
      _agoStamp = ago.attributes['data-timestamp']!;
      dom.Element remaining = _document.getElementsByClassName('featured__column')[0];
      String remainingText = remaining.text.trim();
      bool notStarted = remainingText.contains('Begins');
      _remainingStamp = remaining.nodes[2].attributes['data-timestamp']!;
      List<dom.Element> sidebarError = _document.getElementsByClassName('sidebar__error');
      String? error = sidebarError.isNotEmpty ? sidebarError[0].text.trim() : null;
      _name = _document.getElementsByClassName('featured__heading__medium')[0].text;
      String winners = !notStarted
          ? _document
              .getElementsByClassName('sidebar__navigation__item__link')[2]
              .attributes['href']!
          : '';
      List<dom.Element> entries = _document
          .getElementsByClassName('sidebar__navigation__item__count live__entry-count');
      String image = _document
              .getElementsByClassName('featured__inner-wrap')[0]
              .children[0]
              .children[0]
              .attributes['src'] ??
          '';
      List<dom.Element> lvl =
          _document.getElementsByClassName('featured__column--contributor-level');
      _giveaway = _GiveawayDetailsModel(
        name: _name,
        entries: entries.isNotEmpty ? entries[0].text : '0',
        image: NetworkImage(image.replaceAll('_292x136', '')),
        href: widget.href,
        entered: _document.getElementsByClassName('sidebar__entry-insert').isNotEmpty &&
            _document.getElementsByClassName('sidebar__entry-delete is-hidden').isEmpty &&
            _document.getElementsByClassName('sidebar__error is-disabled').isEmpty,
        remaining: remainingText,
        points: int.parse(points.substring(1, points.length - 2)),
        copies: noCopies ? null : headingSmall[0].text,
        ago: ago.text,
        creator: createdElement.nodes[2].text,
        creatorHref: createdElement.nodes[2].attributes['href'],
        steamHref: _document
                .getElementsByClassName('featured__heading')[0]
                .children[2]
                .attributes['href'] ??
            _document
                .getElementsByClassName('featured__heading')[0]
                .children[3]
                .attributes['href'],
        notEnded: !remainingText.contains('Ended'),
        notStarted: !notStarted,
        error: error,
        inviteOnly:
            _document.getElementsByClassName('featured__column--invite-only').isNotEmpty,
        group: groupNotEmpty,
        whitelist:
            _document.getElementsByClassName('featured__column--whitelist').isNotEmpty,
        region: _document
            .getElementsByClassName('featured__column--region-restricted')
            .isNotEmpty,
        winners: winners.contains('winners') ? winners : null,
        gameID: widget.isBlacklisted
            ? ''
            : _document
                .getElementsByClassName(
                    'featured__outer-wrap featured__outer-wrap--giveaway')[0]
                .attributes['data-game-id']!,
        hidden: _document.getElementsByClassName('featured__giveaway__hide').isEmpty,
        more: _document
            .getElementsByClassName('featured__heading')[0]
            .children[moreIndex]
            .attributes['href']!,
        level:
            lvl.isEmpty ? 0 : int.parse(lvl[0].text.substring(6, lvl[0].text.length - 1)),
      );
      _descriptionText =
          _document.getElementsByClassName('page__description__display-state');
      _description = _parseDescription(_descriptionText);
    } catch (error, stack) {
      if (widget.isBlacklisted) {
        String error = errorString(_document);
        _exception = error.toString().trim();
        _stackTrace = '';
      } else {
        _exception = error.toString();
        _stackTrace = stack.toString();
      }
    }
    _bookmark = objectbox.getGiveawayBookmarked(widget.href);
    _bookmarked = _bookmark.isNotEmpty;
    _scrollController.addListener(_scrollListener);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!widget.isBlacklisted) {
        getPoints(_document, context);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _appbarHeight = MediaQuery.of(context).viewPadding.top;
  }

  void _scrollListener() {
    if (_scrollController.offset >= 200 + _appbarHeight + kToolbarHeight) {
      if (_padding < _appbarHeight) {
        setState(() {
          _padding = _padding + 0.5;
        });
      }
    } else {
      if (_padding > 0) {
        setState(() {
          _padding = _padding - 0.5;
        });
      }
    }
  }

  Widget _parseDescription(List<dom.Element> descriptionText) {
    if (descriptionText.isNotEmpty) {
      return Column(
        children: [
          CommentMessage(data: descriptionText[0].children[0]),
          const Divider(height: 10),
        ],
      );
    } else {
      return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return _exception.isEmpty
        ? PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, result) {
              if (didPop) {
                return;
              }
              _popResult(context);
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              controller: _scrollController,
              slivers: <Widget>[
                ImageSliverAppBar(
                  appbarHeight: _appbarHeight,
                  image: CustomNetworkImage(
                      fit: BoxFit.cover, width: 200, height: 180, image: _giveaway.image),
                ),
                SliverAppBar(
                  primary: false,
                  toolbarHeight: kToolbarHeight + _padding,
                  floating: true,
                  leadingWidth: 100,
                  leading: Padding(
                    padding: EdgeInsets.only(top: _padding),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () {
                            _popResult(context);
                          },
                        ),
                        Builder(
                            builder: (context) => IconButton(
                                  icon: const Icon(Icons.menu),
                                  onPressed: () => Scaffold.of(context).openDrawer(),
                                ))
                      ],
                    ),
                  ),
                  title: Padding(
                      padding: EdgeInsets.only(top: _padding),
                      child: Consumer<PointsProvider>(
                        builder: (context, user, child) => Text(
                          '${user.points}P',
                          style: const TextStyle(fontSize: 18),
                        ),
                      )),
                  actions: [
                    !widget.isBlacklisted
                        ? _giveaway.hidden
                            ? _CustomIconPadding(
                                padding: _padding,
                                child: InkWell(
                                  onTap: () async {
                                    int statusCode = await resStatusCode(
                                        '&do=remove_filter&game_id=${_giveaway.gameID}');
                                    if (statusCode == 200) {
                                      setState(() {
                                        _giveaway.hidden = false;
                                      });
                                    }
                                  },
                                  child: const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Icon(
                                      Icons.visibility,
                                      color: Colors.red,
                                    ),
                                  ),
                                ))
                            : _CustomIconPadding(
                                padding: _padding,
                                child: InkWell(
                                  onTap: () async {
                                    int statusCode = await resStatusCode(
                                        '&game_id=${_giveaway.gameID}&do=hide_giveaways_by_game_id');
                                    if (statusCode == 200) {
                                      setState(() {
                                        _giveaway.hidden = true;
                                      });
                                    }
                                  },
                                  child: const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Icon(Icons.visibility_off),
                                  ),
                                ))
                        : Container(),
                    _CustomIconPadding(
                      padding: _padding,
                      child: InkWell(
                          onTap: () {
                            _changeBookmark();
                            setState(() {
                              _bookmarked = !_bookmarked;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Icon(
                              _bookmarked ? Icons.bookmark : Icons.bookmark_border,
                            ),
                          )),
                    ),
                    _CustomIconPadding(
                      padding: _padding,
                      child: InkWell(
                        onTap: () =>
                            SharePlus.instance.share(ShareParams(uri: Uri.parse(_url))),
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.share,
                          ),
                        ),
                      ),
                    ),
                    _CustomIconPadding(
                      padding: _padding,
                      child: InkWell(
                          onTap: () => urlLauncher(_giveaway.steamHref!),
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: FaIcon(FontAwesomeIcons.steamSymbol),
                          )),
                    ),
                    MenuAnchor(
                        builder: (context, controller, child) => _CustomIconPadding(
                            padding: _padding,
                            child: InkWell(
                              onTap: () {
                                if (controller.isOpen) {
                                  controller.close();
                                } else {
                                  controller.open();
                                }
                              },
                              child: const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Icon(Icons.more_vert_outlined),
                              ),
                            )),
                        menuChildren: [
                          CustomMenuItem(
                              icon: Icons.person,
                              text: _giveaway.creator!,
                              onPressed: () =>
                                  customNav(User(name: _giveaway.creator!), context)),
                          _giveaway.group
                              ? CustomMenuItem(
                                  icon: Icons.groups,
                                  text: 'Groups',
                                  onPressed: () =>
                                      customNav(Groups(groupUrl: _groupUrl), context))
                              : Container(),
                          CustomMenuItem(
                              icon: Icons.search,
                              text: 'More Giveaways',
                              onPressed: () =>
                                  customNav(Game(href: _giveaway.more), context)),
                          _giveaway.winners != null
                              ? CustomMenuItem(
                                  icon: Icons.emoji_events,
                                  text: 'Winners',
                                  onPressed: () => customNav(
                                      Winners(
                                          link: _giveaway.winners!,
                                          self: _giveaway.creator == username),
                                      context))
                              : Container(),
                        ])
                  ],
                ),
                SliverToBoxAdapter(
                    child: Card(
                  surfaceTintColor: CustomCardTheme.surfaceTintColor,
                  elevation: CustomCardTheme.elevation,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                        child: Column(
                          children: [
                            Align(
                                alignment: Alignment.centerLeft,
                                //overflow comes from site
                                child: Consumer<ThemeProvider>(
                                  builder: (context, theme, child) => Text(
                                    _giveaway.name,
                                    style: TextStyle(
                                        fontSize: 20.0 + theme.fontSize,
                                        fontWeight: FontWeight.bold),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                )),
                            Row(children: [
                              GestureDetector(
                                  onTap: () =>
                                      customNav(User(name: _giveaway.creator!), context),
                                  child: Consumer<ThemeProvider>(
                                      builder: (context, theme, child) => Row(children: [
                                            Icon(Icons.person,
                                                size: 16.0 + theme.fontSize),
                                            Text(_giveaway.creator!,
                                                style: TextStyle(
                                                    fontSize: _detailsFontSize +
                                                        4 +
                                                        theme.fontSize)),
                                          ]))),
                              const Spacer(),
                              _giveaway.copies != null
                                  ? Padding(
                                      padding: const EdgeInsets.only(right: 4.0),
                                      child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            _giveaway.copies!,
                                          )),
                                    )
                                  : Container(),
                              Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text('Level ${_giveaway.level}'))
                            ]),
                            Consumer<ThemeProvider>(
                              builder: (context, theme, child) => Row(children: [
                                Icon(Icons.group, size: 14.0 + theme.fontSize),
                                const SizedBox(width: 1),
                                Text(
                                  '${_giveaway.entries} entries ',
                                  style: TextStyle(
                                      fontSize: _detailsFontSize + theme.fontSize),
                                ),
                                Icon(Icons.calendar_today, size: 10.0 + theme.fontSize),
                                const SizedBox(width: 1),
                                Text('${_giveaway.ago!} ago',
                                    style: TextStyle(
                                        fontSize: _detailsFontSize + theme.fontSize)),
                                const Spacer(),
                                Icon(Icons.schedule, size: 12.0 + theme.fontSize),
                                const SizedBox(width: 1),
                                Text(_giveaway.remaining.toLowerCase(),
                                    style: TextStyle(
                                        fontSize: _detailsFontSize + theme.fontSize)),
                              ]),
                            )
                          ],
                        ),
                      ),
                      const Divider(height: 10),
                      _description,
                      Row(
                        children: [
                          Align(
                              alignment: Alignment.centerLeft,
                              child: widget.isBlacklisted
                                  ? const Padding(
                                      padding: EdgeInsets.only(left: 8.0),
                                      child: Text('Blacklisted',
                                          style: TextStyle(color: Colors.red)),
                                    )
                                  : _giveaway.error == null
                                      ? _giveaway.notEnded &&
                                              _giveaway.notStarted! &&
                                              _giveaway.creator != username
                                          ? TextButton(
                                              onPressed: _giveaway.entered ||
                                                      context
                                                              .read<PointsProvider>()
                                                              .points >=
                                                          _giveaway.points!
                                                  ? () async {
                                                      await changeGiveawayState(
                                                          _giveaway, context, setState);
                                                    }
                                                  : null,
                                              child: _giveaway.entered
                                                  ? Text('Leave (${_giveaway.points}P)')
                                                  : Text('Enter (${_giveaway.points}P)'))
                                          : Container()
                                      : Padding(
                                          padding: const EdgeInsets.only(left: 8.0),
                                          child: Text(_giveaway.error!),
                                        )),
                          widget.isBlacklisted
                              ? Container()
                              : TextButton(
                                  onPressed: () async {
                                    Object? refresh = await customNav(
                                        CommentEditor(
                                            data: _descriptionText.isNotEmpty
                                                ? _descriptionText[0].children[0]
                                                : dom.Element.html('<p></p>'),
                                            name: _giveaway.creator!,
                                            url: _url),
                                        context);
                                    if (refresh == true) {
                                      _controller.method();
                                    }
                                  },
                                  child: const Text('Comment')),
                          const Spacer(),
                          _giveaway.inviteOnly
                              ? const Icon(
                                  Icons.lock,
                                  size: _iconSize,
                                )
                              : Container(),
                          _giveaway.group
                              ? InkWell(
                                  onTap: () =>
                                      customNav(Groups(groupUrl: _groupUrl), context),
                                  child: const Padding(
                                    padding: _iconPadding,
                                    child: Icon(Icons.groups,
                                        size: _iconSize + 4, color: Colors.green),
                                  ),
                                )
                              : Container(),
                          _giveaway.whitelist
                              ? const Padding(
                                  padding: _iconPadding,
                                  child: Icon(Icons.favorite,
                                      size: _iconSize, color: Colors.pinkAccent),
                                )
                              : Container(),
                          _giveaway.region
                              ? const Padding(
                                  padding: _iconPadding,
                                  child: Icon(Icons.public,
                                      size: _iconSize, color: Colors.blueGrey),
                                )
                              : Container(),
                          const SizedBox(width: 10)
                        ],
                      )
                    ],
                  ),
                )),
                Comments(
                    href: widget.href,
                    isGiveaway: true,
                    firstPage: widget.data,
                    refresh: _controller,
                    isBlacklisted: widget.isBlacklisted),
              ],
            ))
        : ErrorPage(
            error: _exception,
            url: _url,
            stackTrace: _stackTrace,
            type: 'giveaway',
          );
  }

  void _popResult(BuildContext context) {
    if (context.canPop()) {
      Navigator.pop(context, _giveaway.entered);
    } else {
      context.go(GiveawayPages.all.route);
    }
  }

  void _changeBookmark() {
    if (_bookmarked) {
      _bookmark = objectbox.getGiveawayBookmarked(widget.href);
      objectbox.removeGiveawayBookmark(_bookmark.first.id);
    } else {
      objectbox.addGiveawayBookmark(
          href: widget.href,
          name: _name,
          type: _type,
          appid: _appid,
          agoStamp: int.parse(_agoStamp),
          remainingStamp: int.parse(_remainingStamp),
          favourite: false);
    }
  }
}

class CustomMenuItem extends StatelessWidget {
  const CustomMenuItem({
    super.key,
    required this.icon,
    required this.text,
    required this.onPressed,
  });

  final IconData icon;
  final String text;
  final Function onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: MenuItemButton(
        onPressed: () => onPressed(),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Icon(icon),
            ),
            Text(text,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.normal)),
          ],
        ),
      ),
    );
  }
}

class _CustomIconPadding extends StatelessWidget {
  const _CustomIconPadding({required this.padding, required this.child});

  final double padding;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(padding: EdgeInsets.only(top: padding, right: 6), child: child);
  }
}
