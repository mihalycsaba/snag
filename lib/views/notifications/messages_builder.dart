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

import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';

import 'package:snag/common/functions/add_page.dart';
import 'package:snag/common/functions/button_background_color.dart';
import 'package:snag/common/functions/fetch_body.dart';
import 'package:snag/common/functions/get_avatar.dart';
import 'package:snag/common/functions/res_map.dart';
import 'package:snag/common/paged_progress_indicator.dart';
import 'package:snag/common/vars/prefs.dart';
import 'package:snag/nav/custom_nav.dart';
import 'package:snag/provider_models/messages_provider.dart';
import 'package:snag/provider_models/theme_provider.dart';
import 'package:snag/views/comments/comment_message.dart';
import 'package:snag/views/discussions/discussion.dart';
import 'package:snag/views/giveaways/giveaway/giveaway.dart';

abstract class _MessagesListModel {
  Widget? message;

  _MessagesListModel({this.message});
}

class _MessageModel extends _MessagesListModel {
  String url;
  String title;
  List<_ReplyModel> replies = [];

  _MessageModel(
      {required this.url, required this.title, required this.replies, super.message});
}

class _ReplyModel extends _MessagesListModel {
  String id;

  _ReplyModel({required this.id, super.message});
}

class MessagesBuilder extends StatefulWidget {
  const MessagesBuilder({super.key});

  @override
  State<MessagesBuilder> createState() => _MessagesBuilderState();
}

class _MessagesBuilderState extends State<MessagesBuilder> {
  final PagingController<int, _MessageModel> _pagingController =
      PagingController(firstPageKey: 1);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _pagingController.addPageRequestListener((pageKey) {
      _fetchMessagesList(pageKey, context);
    });
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Consumer<MessagesProvider>(
            builder: (context, user, child) =>
                (user.messages == '0') ? Container() : const _MarkWidget()),
        Flexible(
          child: RefreshIndicator(
              onRefresh: () => Future.sync(() => _pagingController.refresh()),
              child: PagedListView<int, _MessageModel>(
                  pagingController: _pagingController,
                  builderDelegate: PagedChildBuilderDelegate<_MessageModel>(
                      itemBuilder: (context, message, index) =>
                          _MessageEntry(message: message),
                      newPageProgressIndicatorBuilder: (context) =>
                          const PagedProgressIndicator()))),
        ),
      ],
    );
  }

  void _fetchMessagesList(int pageKey, BuildContext context) async {
    String data = await fetchBody(
        url: 'https://www.steamgifts.com/messages/search?page=${pageKey.toString()}');
    dom.Document document = parse(data);
    var notifications = document.getElementsByClassName('nav__right-container')[0];
    String messages = notifications.children[2].innerHtml.contains('nav__notification')
        ? notifications.children[2].getElementsByClassName('nav__notification')[0].text
        : '0';
    if (!context.mounted) return;
    context.read<MessagesProvider>().updateMessages(messages);
    prefs.setInt(PrefsKeys.messages.key, int.parse(messages));
    List<_MessageModel> messagesList = _parseMessagesList(document);
    addPage(messagesList, _pagingController, pageKey,
        document.getElementsByClassName('widget-container').first);
  }

  List<_MessageModel> _parseMessagesList(dom.Document document) {
    List<_MessageModel> messagesList = [];
    List<dom.Element> elements = document
        .getElementsByClassName('widget-container')[0]
        .children[1]
        .children[1]
        .children;
    int messageIndex = -1;
    for (int index = 0; index < elements.length; index++) {
      dom.Element element = elements[index];
      if (element.className == 'comments__entity') {
        messagesList.add(_parseMessageElement(element));
        messageIndex++;
      }
      if (element.className == 'comments') {
        element.getElementsByClassName('comment__parent').forEach((element) {
          messagesList[messageIndex].replies.add(_parseReplyElement(element));
        });
      }
    }
    return messagesList;
  }

  _ReplyModel _parseReplyElement(dom.Element element) {
    dom.Element user = element.getElementsByClassName('comment__username')[0].children[0];
    List<dom.Element> role = element.getElementsByClassName('comment__role-name');
    return _ReplyModel(
        message: CommentMessage(
          data: element.getElementsByClassName('comment__description markdown')[0],
          name: user.text,
          userHref: user.attributes['href']!,
          avatar: getAvatar(element, 'global__image-inner-wrap'),
          active: element.getElementsByClassName('comment__envelope').isNotEmpty,
          ago: element
              .getElementsByClassName('comment__actions')[0]
              .nodes[1]
              .nodes[0]
              .text,
          patron: element.getElementsByClassName('fa fa-star').isNotEmpty,
          role: role.isNotEmpty ? role[0].text.trim() : '',
        ),
        id: element.getElementsByClassName('comment__summary')[0].attributes['id']!);
  }

  _MessageModel _parseMessageElement(dom.Element element) {
    List<dom.Element> comment =
        element.getElementsByClassName('comments__entity__description');
    dom.Element title = element.getElementsByClassName('comments__entity__name')[0];
    return _MessageModel(
      message: comment.isNotEmpty ? CommentMessage(data: comment[0]) : null,
      title: title.text,
      url: title.children[0].attributes['href']!,
      replies: [],
    );
  }
}

class _MarkWidget extends StatefulWidget {
  const _MarkWidget();

  @override
  State<_MarkWidget> createState() => _MarkWidgetState();
}

class _MarkWidgetState extends State<_MarkWidget> {
  bool _active = true;
  late WidgetStateProperty<Color?> _bgColor;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _bgColor = buttonBackgroundColor(context);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
            style: ButtonStyle(
              backgroundColor: _bgColor,
            ),
            onPressed: _active ? _mark : null,
            child: const Text('Mark as read')),
        const Divider(height: 0)
      ],
    );
  }

  void _mark() async {
    String body = 'xsrf_token=${prefs.getString(PrefsKeys.xsrf.key)}&do=read_messages';
    Map responseMap = await resMap(body, 'https://www.steamgifts.com/messages');
    if (responseMap['type'] == 'success') {
      if (!mounted) return;
      context.read<MessagesProvider>().updateMessages('0');
      setState(() {
        _active = !_active;
      });
    }
  }
}

class _MessageEntry extends StatefulWidget {
  const _MessageEntry({required this.message});

  final _MessageModel message;

  @override
  State<_MessageEntry> createState() => _MessageEntryState();
}

class _MessageEntryState extends State<_MessageEntry> {
  bool _customTileExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card.filled(
      child: Column(
        children: [
          ExpansionTile(
              shape: LinearBorder.none,
              collapsedShape: LinearBorder.none,
              tilePadding: const EdgeInsets.only(left: 10.0, top: 10.0, bottom: 4.0),
              title: Consumer<ThemeProvider>(
                builder: (context, theme, child) => Text(widget.message.title,
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 20.0 + theme.fontSize),
                    textAlign: TextAlign.left),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.link,
                    ),
                    onPressed: () {
                      if (widget.message.url.startsWith('/giveaway/')) {
                        customNav(Giveaway(href: widget.message.url), context);
                      } else {
                        customNav(Discussion(href: widget.message.url), context);
                      }
                    },
                  ),
                  widget.message.message != null
                      ? _customTileExpanded
                          ? const Padding(
                              padding: EdgeInsets.only(right: 10.0),
                              child: Icon(Icons.keyboard_arrow_up),
                            )
                          : const Padding(
                              padding: EdgeInsets.only(right: 10.0),
                              child: Icon(Icons.keyboard_arrow_down),
                            )
                      : Container(),
                ],
              ),
              onExpansionChanged: (bool expanded) {
                setState(() {
                  _customTileExpanded = expanded;
                });
              },
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: widget.message.message != null
                      ? widget.message.message!
                      : Container(),
                )
              ]),
          for (var reply in widget.message.replies)
            _userReplyEntry(reply: reply.message!),
        ],
      ),
    );
  }

  Widget _userReplyEntry({required Widget reply}) {
    return Padding(
      padding: const EdgeInsets.only(left: 22.0, right: 4.0),
      child: reply,
    );
  }
}
