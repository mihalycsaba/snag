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

import 'package:snag/common/functions/add_page.dart';
import 'package:snag/common/functions/fetch_body.dart';
import 'package:snag/common/functions/get_avatar.dart';
import 'package:snag/common/paged_progress_indicator.dart';
import 'package:snag/common/vars/globals.dart';
import 'package:snag/views/comments/comment_message.dart';
import 'package:snag/views/comments/comment_model.dart';
import 'package:snag/views/comments/refresh_controller.dart';

class Comments extends StatefulWidget {
  const Comments(
      {required this.href,
      required this.isGiveaway,
      required this.firstPage,
      this.refresh,
      this.isBlacklisted = false,
      this.closed = false,
      super.key});
  final String href;
  final bool isGiveaway;
  final String firstPage;
  final RefreshController? refresh;
  final bool isBlacklisted;
  final bool closed;

  @override
  State<Comments> createState() => _CommentsState();
}

class _CommentsState extends State<Comments> {
  late final PagingController<int, CommentModel> _pagingController =
      PagingController(firstPageKey: 1);

  String _url = '';

  @override
  void initState() {
    _url = 'https://www.steamgifts.com${widget.href}';
    super.initState();
    if (widget.refresh != null) {
      widget.refresh!.method = _pagingController.refresh;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _pagingController
        .addPageRequestListener((pageKey) => _fetchComments(pageKey, _url));
  }

  Future<void> _fetchComments(int pageKey, String url) async {
    String data = pageKey == 1
        ? widget.firstPage
        : await fetchBody(
            url: '$url?page=${pageKey.toString()}',
            isBlacklisted: widget.isBlacklisted);
    dom.Element container =
        parse(data).getElementsByClassName('widget-container').first;
    List<dom.Element> list = container.getElementsByClassName('comments');
    List<CommentModel> comments = [];
    if (widget.isGiveaway) {
      comments = list.isNotEmpty ? _parseComments(list[0].children) : [];
    } else {
      comments = list.length != 1 ? _parseComments(list[1].children) : [];
    }
    addPage(comments, _pagingController, pageKey, container);
  }

  List<CommentModel> _parseComments(List<dom.Element> elements,
      [bool indented = false]) {
    List<CommentModel> comments = [];
    if (elements.isNotEmpty) {
      for (dom.Element element in elements) {
        List<dom.Element> comment = element.children;
        List<dom.Element> replies = comment[1].children;
        dom.Element data = comment[0]
            .getElementsByClassName('comment__description markdown')[0];
        String id = element.attributes['data-comment-id']!;
        dom.Element user =
            comment[0].getElementsByClassName('comment__username')[0];
        List<dom.Element> userChildren = user.children;
        List<dom.Element> role =
            comment[0].getElementsByClassName('comment__role-name');
        comments.add(CommentModel(
            message: CommentMessage(
              data: data,
              id: id,
              name: user.text,
              userHref: userChildren.isNotEmpty
                  ? userChildren[0].attributes['href']!
                  : null,
              ago: comment[0]
                  .getElementsByClassName('comment__actions')[0]
                  .nodes[1]
                  .nodes[0]
                  .text!,
              url: _url,
              avatar: getAvatar(comment[0], 'global__image-inner-wrap'),
              onReply: _pagingController.refresh,
              indented: indented,
              closed: widget.closed,
              isBlacklisted: widget.isBlacklisted,
              editText: user.text == username
                  ? comment[0]
                      .getElementsByClassName('comment__edit-state')[0]
                      .getElementsByTagName('textarea')[0]
                      .text
                  : '',
              undelete: comment[0]
                  .getElementsByClassName(
                      'comment__actions__button js__comment-undelete')
                  .isNotEmpty,
              patron:
                  comment[0].getElementsByClassName('fa fa-star').isNotEmpty,
              role: role.isNotEmpty ? role[0].text.trim() : '',
            ),
            messageLength: data.text.trim().length,
            replies: replies.isNotEmpty ? _parseComments(replies, true) : []));
      }
    }
    return comments;
  }

  @override
  Widget build(BuildContext context) {
    return PagedSliverList<int, CommentModel>(
        pagingController: _pagingController,
        builderDelegate: PagedChildBuilderDelegate<CommentModel>(
            itemBuilder: (context, comment, index) =>
                _Comment(comment: comment, indent: 0),
            newPageProgressIndicatorBuilder: (context) =>
                PagedProgressIndicator()));
  }
}

class _Comment extends StatelessWidget {
  const _Comment({required this.comment, required this.indent});
  final CommentModel comment;
  final double indent;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: indent),
          Flexible(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [comment.message, const SizedBox(height: 6)],
          )),
        ],
      ),
      const Divider(height: 0, indent: 130, endIndent: 130),
      ..._addReplies(comment)
    ]);
  }

  List<Widget> _addReplies(CommentModel comment) {
    List<Widget> replies = [];
    if (comment.replies.isNotEmpty) {
      for (CommentModel reply in comment.replies) {
        replies.add(_Comment(comment: reply, indent: indent + 20));
      }
    }
    return replies;
  }
}
