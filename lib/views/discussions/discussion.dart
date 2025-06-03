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

import 'package:go_router/go_router.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import 'package:snag/common/card_theme.dart';
import 'package:snag/common/functions/fetch_body.dart';
import 'package:snag/common/functions/get_avatar.dart';
import 'package:snag/common/functions/res_map_ajax.dart';
import 'package:snag/common/vars/globals.dart';
import 'package:snag/common/vars/obx.dart';
import 'package:snag/common/vars/prefs.dart';
import 'package:snag/nav/custom_nav.dart';
import 'package:snag/nav/pages.dart';
import 'package:snag/objectbox/discussion_bookmark_model.dart';
import 'package:snag/provider_models/theme_provider.dart';
import 'package:snag/views/comments/comment_editor.dart';
import 'package:snag/views/comments/comment_message.dart';
import 'package:snag/views/comments/comments.dart';
import 'package:snag/views/comments/refresh_controller.dart';
import 'package:snag/views/giveaways/error/error_page.dart';
import 'package:snag/views/misc/logged_out.dart';

class Discussion extends StatefulWidget {
  const Discussion({super.key, required this.href});
  final String href;

  @override
  State<Discussion> createState() => _DiscussionState();
}

class _DiscussionState extends State<Discussion> {
  final RefreshController _controller = RefreshController();
  String _url = '';

  @override
  void initState() {
    super.initState();
    _url = 'https://www.steamgifts.com${widget.href}';
  }

  @override
  Widget build(BuildContext context) {
    return isLoggedIn
        ? FutureBuilder(
            future: fetchBody(url: _url),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Scaffold(
                    appBar: AppBar(
                      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
                    ),
                    body: const Center(child: CircularProgressIndicator()));
              } else if (snapshot.hasData) {
                String? data = snapshot.data;
                return RefreshIndicator(
                  onRefresh: () => Future.sync(() => setState(() {})),
                  edgeOffset: MediaQuery.of(context).viewPadding.top + kToolbarHeight,
                  child: _DiscussionDetails(
                      href: widget.href, url: _url, data: data!, controller: _controller),
                );
              }
              return Container();
            })
        : const LoggedOut();
  }
}

class _DiscussionDetails extends StatefulWidget {
  const _DiscussionDetails(
      {required this.href,
      required this.url,
      required this.data,
      required this.controller});

  final String href;
  final String url;
  final String data;
  final RefreshController controller;

  @override
  State<_DiscussionDetails> createState() => _DiscussionDetailsState();
}

class _DiscussionDetailsState extends State<_DiscussionDetails> {
  List<DiscussionBookmarkModel> _bookmark = [];
  bool _bookmarked = false;
  dom.Element _desctiption = dom.Element.tag('');
  String _username = '';
  String _name = '';
  String? _userHref;
  dom.Element _comment = dom.Element.tag('');
  String _ago = '';
  bool _closed = false;
  bool _poll = false;
  String _question = '';
  final List<_AnswerModel> _answers = [];
  bool _results = false;
  int _total = 0;
  bool _patron = false;
  List<dom.Element> _role = [];
  String _exception = '';
  String _stackTrace = '';

  @override
  void initState() {
    super.initState();
    _bookmark = objectbox.getDiscussionBookmarked(widget.href);
    _bookmarked = _bookmark.isNotEmpty;
    try {
      dom.Document document = parse(widget.data);
      _comment = document.getElementsByClassName('comments')[0];
      _desctiption = _comment.getElementsByClassName('comment__description markdown')[0];
      dom.Element user = _comment.getElementsByClassName('comment__username')[0];
      _username = user.text;
      List<dom.Element> userChildren = user.children;
      _userHref = userChildren.isNotEmpty ? userChildren[0].attributes['href']! : null;
      _ago =
          _comment.getElementsByClassName('comment__actions')[0].nodes[1].nodes[0].text!;
      _name = document
          .getElementsByClassName('page__heading__breadcrumbs')[0]
          .children[4]
          .firstChild!
          .text!;
      _closed = document
          .getElementsByClassName('page__heading__button page__heading__button--red')
          .isNotEmpty;
      _poll = document.getElementsByClassName('poll__view-results-container').isNotEmpty;
      _patron = _comment.getElementsByClassName('fa fa-star').isNotEmpty;
      _role = _comment.getElementsByClassName('comment__role-name');
      if (_poll) {
        _question =
            document.getElementsByClassName('table__heading')[0].nodes[1].text!.trim();
        document
            .getElementsByClassName('table__row-outer-wrap poll__answer-container')
            .forEach((element) {
          int votes = int.parse(element.attributes['data-votes']!);
          _total += votes;
          _answers.add(_AnswerModel(
              answer:
                  element.getElementsByClassName('table__column__heading')[0].text.trim(),
              votes: votes,
              id: element.nodes[1].nodes[3].nodes[1].nodes[5].attributes['value']!,
              voted: element.className.contains('is-selected')));
        });
      }
    } catch (error, stack) {
      _exception = error.toString();
      _stackTrace = stack.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return _exception.isEmpty
        ? Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go(DiscussionPages.all.route);
                  }
                },
              ),
              actions: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: InkWell(
                    onTap: () {
                      _changeBookmark();
                      setState(() {
                        _bookmarked = !_bookmarked;
                      });
                    },
                    child: Icon(
                      _bookmarked ? Icons.bookmark : Icons.bookmark_border,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 20.0, top: 10.0, bottom: 10.0),
                  child: GestureDetector(
                    onTap: () =>
                        SharePlus.instance.share(ShareParams(uri: Uri.parse(widget.url))),
                    child: const Icon(
                      Icons.share,
                    ),
                  ),
                ),
              ],
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
              title: Consumer<ThemeProvider>(
                builder: (context, theme, child) => Text(
                  style: TextStyle(fontSize: 18.0 + theme.fontSize),
                  _name,
                  maxLines: 2,
                ),
              ),
            ),
            body: CustomScrollView(slivers: <Widget>[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Card(
                      elevation: CustomCardTheme.elevation,
                      surfaceTintColor: CustomCardTheme.surfaceTintColor,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CommentMessage(
                            data: _desctiption,
                            name: _username,
                            userHref: _userHref,
                            ago: _ago,
                            avatar: getAvatar(_comment, 'global__image-inner-wrap'),
                            patron: _patron,
                            role: _role.isNotEmpty ? _role[0].text.trim() : '',
                          ),
                          _poll
                              ? Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                        child: Consumer<ThemeProvider>(
                                          builder: (context, theme, child) => Text(
                                            _question,
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16.0 + theme.fontSize),
                                          ),
                                        ),
                                      ),
                                      TextButton(
                                          onPressed: () {
                                            setState(() {
                                              _results = !_results;
                                            });
                                          },
                                          child: const Text('Results'))
                                    ],
                                  ),
                                )
                              : Container(),
                          _poll
                              ? ListView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: _answers.length,
                                  shrinkWrap: true,
                                  itemBuilder: (context, index) => Padding(
                                        padding: const EdgeInsets.all(2.0),
                                        child: GestureDetector(
                                          onTap: () => _vote(_answers[index]),
                                          child: Card.filled(
                                            elevation: 0.1,
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.only(right: 6.0),
                                                child: Column(
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        Flexible(
                                                            child: Text(
                                                                _answers[index].answer)),
                                                        SizedBox(
                                                            width: 12,
                                                            child: _answers[index].voted
                                                                ? const Icon(
                                                                    Icons.circle,
                                                                    size: 16,
                                                                    color: Colors.green,
                                                                  )
                                                                : const Icon(
                                                                    Icons.circle_outlined,
                                                                    size: 16,
                                                                  ))
                                                      ],
                                                    ),
                                                    _results
                                                        ? Padding(
                                                            padding:
                                                                const EdgeInsets.only(
                                                                    top: 8.0),
                                                            child: Row(
                                                              children: [
                                                                SizedBox(
                                                                  width: 75,
                                                                  child: Text(
                                                                      '${_answers[index].votes} votes'),
                                                                ),
                                                                Flexible(
                                                                  child: SizedBox(
                                                                    height: 8,
                                                                    child:
                                                                        FractionallySizedBox(
                                                                            widthFactor:
                                                                                _answers[index]
                                                                                        .votes /
                                                                                    _total,
                                                                            child:
                                                                                Divider(
                                                                              color: _answers[
                                                                                          index]
                                                                                      .voted
                                                                                  ? Colors
                                                                                      .green
                                                                                  : Colors
                                                                                      .grey[500],
                                                                              height: 0,
                                                                              thickness:
                                                                                  8,
                                                                            )),
                                                                  ),
                                                                )
                                                              ],
                                                            ),
                                                          )
                                                        : Container(),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ))
                              : Container(),
                          const Divider(height: 0),
                          !_closed
                              ? TextButton(
                                  onPressed: () async {
                                    Object? refresh = await customNav(
                                        CommentEditor(
                                            data: _desctiption,
                                            name: _username,
                                            url: widget.url),
                                        context);
                                    if (refresh == true) {
                                      widget.controller.method();
                                    }
                                  },
                                  child: const Text('Comment'))
                              : const Padding(
                                  padding:
                                      EdgeInsets.only(left: 8.0, top: 4.0, bottom: 4.0),
                                  child: Text('Closed'),
                                ),
                        ],
                      )),
                ),
              ),
              Comments(
                href: widget.href,
                isGiveaway: false,
                firstPage: widget.data,
                refresh: widget.controller,
                closed: _closed,
              ),
            ]),
          )
        : ErrorPage(
            error: _exception,
            url: widget.url,
            stackTrace: _stackTrace,
            type: 'discussion',
          );
  }

  void _changeBookmark() {
    if (_bookmarked) {
      _bookmark = objectbox.getDiscussionBookmarked(widget.href);
      objectbox.removeDiscussionBookmark(_bookmark.first.id);
    } else {
      objectbox.addDiscussionBookmark(href: widget.href, name: _name);
    }
  }

  void _vote(_AnswerModel answer) async {
    String body = '';
    if (answer.voted) {
      body =
          'xsrf_token=${prefs.getString(PrefsKeys.xsrf.key)}&do=poll_vote_delete&poll_answer_id=${answer.id}';
    } else {
      body =
          'xsrf_token=${prefs.getString(PrefsKeys.xsrf.key)}&do=poll_vote_insert&poll_answer_id=${answer.id}';
    }
    Map responseMap = await resMapAjax(body);
    if (responseMap['type'] == 'success') {
      if (answer.voted) {
        _total--;
        answer.votes--;
      } else {
        for (var element in _answers) {
          if (element.id != answer.id) {
            if (element.voted == !answer.voted) {
              _total--;
              element.votes--;
              element.voted = !element.voted;
            }
          }
        }
        _total++;
        answer.votes++;
      }
      answer.voted = !answer.voted;
      setState(() {});
    }
  }
}

class _AnswerModel {
  final String answer;
  int votes;
  final String id;
  bool voted;

  _AnswerModel(
      {required this.answer, required this.votes, required this.id, required this.voted});
}
