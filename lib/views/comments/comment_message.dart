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
import 'package:provider/provider.dart';

import 'package:snag/common/custom_network_image.dart';
import 'package:snag/common/functions/res_map_ajax.dart';
import 'package:snag/common/vars/globals.dart';
import 'package:snag/common/vars/prefs.dart';
import 'package:snag/nav/custom_nav.dart';
import 'package:snag/provider_models/theme_provider.dart';
import 'package:snag/views/comments/comment_editor.dart';
import 'package:snag/views/comments/custom_html.dart';
import 'package:snag/views/misc/user.dart';

typedef ReplyAddedCallback = void Function();

class CommentMessage extends StatefulWidget {
  const CommentMessage(
      {super.key,
      required this.data,
      this.id,
      this.name,
      this.url,
      this.avatar,
      this.onReply,
      this.userHref,
      this.ago,
      this.active = false,
      this.indented = false,
      this.closed = false,
      this.isBlacklisted = false,
      this.editText = '',
      this.undelete = false,
      this.patron = false,
      this.role = ''});
  final dom.Element data;
  final String? id;
  final String? name;
  final String? url;
  final String? avatar;
  final bool active;
  final ReplyAddedCallback? onReply;
  final bool indented;
  final String? userHref;
  final String? ago;
  final bool closed;
  final bool isBlacklisted;
  final String editText;
  final bool undelete;
  final bool patron;
  final String role;

  @override
  State<CommentMessage> createState() => _CommentMessageState();
}

class _CommentMessageState extends State<CommentMessage> {
  final List<Widget> attachedImages = [];
  @override
  void initState() {
    super.initState();
    List<dom.Element> images =
        widget.data.getElementsByClassName('comment__toggle-attached');
    if (images.isNotEmpty) {
      for (dom.Element image in widget.data.getElementsByTagName('img')) {
        attachedImages.add(_AttachedImage(data: image.attributes['src']!));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        widget.avatar != null
            ? const Padding(padding: EdgeInsets.only(top: 10))
            : Container(),
        GestureDetector(
          onTap: widget.userHref != null
              ? () => customNav(User(name: widget.name!), context)
              : null,
          child: Row(
            children: [
              widget.avatar != null
                  ? CustomNetworkImage(
                      resize: false,
                      url: widget.avatar!,
                      width: 30,
                    )
                  : Container(),
              widget.name != null
                  ? Padding(
                      padding: const EdgeInsets.only(left: 5),
                      child: Consumer<ThemeProvider>(
                        builder: (context, theme, child) => Text(
                          widget.name!,
                          style: TextStyle(
                              fontSize: 16.0 + theme.fontSize,
                              fontWeight: FontWeight.bold,
                              color: widget.active
                                  ? Theme.of(context).colorScheme.primary
                                  : null),
                        ),
                      ))
                  : Container(),
              widget.patron ? Icon(Icons.star, color: Colors.green[800]) : Container(),
              widget.role != ''
                  ? Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Text(widget.role),
                    )
                  : Container(),
              const Spacer(),
              widget.ago != null
                  ? Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Row(
                        children: [
                          Icon(Icons.access_time,
                              size: 10,
                              color: widget.active
                                  ? Theme.of(context).colorScheme.primary
                                  : null),
                          const SizedBox(
                            width: 1,
                          ),
                          Consumer<ThemeProvider>(
                            builder: (context, theme, child) => Text('${widget.ago!} ago',
                                style: TextStyle(
                                    fontSize: 10.0 + theme.fontSize,
                                    color: widget.active
                                        ? Theme.of(context).colorScheme.primary
                                        : null)),
                          ),
                        ],
                      ),
                    )
                  : Container(),
            ],
          ),
        ),
        DecoratedBox(
            decoration: BoxDecoration(
                border: widget.indented
                    ? Border(
                        left: BorderSide(
                            width: 2, color: Theme.of(context).colorScheme.primary))
                    : null),
            child: CustomHtml(data: widget.data, active: widget.active)),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(child: Column(children: attachedImages)),
            widget.undelete
                ? InkWell(
                    onTap: () async {
                      String body =
                          'xsrf_token=${prefs.getString(PrefsKeys.xsrf.key)}&do=comment_undelete&allow_replies=1&comment_id=${widget.id}';
                      Map responseMap = await resMapAjax(body);
                      if (responseMap['type'] == 'success') {
                        widget.onReply!();
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10.0, bottom: 5.0),
                      child: Icon(
                        Icons.restore_from_trash_outlined,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ))
                : Container(),
            widget.name == username &&
                    widget.id != null &&
                    !widget.closed &&
                    !widget.isBlacklisted
                ? InkWell(
                    onTap: () => showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                              title: const Text('Delete'),
                              content: const Text(
                                  'Are you sure you want to delete this comment?'),
                              actions: [
                                TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Cancel')),
                                TextButton(
                                    onPressed: () async {
                                      String body =
                                          'xsrf_token=${prefs.getString(PrefsKeys.xsrf.key)}&do=comment_delete&allow_replies=1&comment_id=${widget.id}';
                                      Map responseMap = await resMapAjax(body);
                                      if (responseMap['type'] == 'success') {
                                        widget.onReply!();
                                        if (context.mounted) {
                                          Navigator.pop(context);
                                        }
                                      }
                                    },
                                    child: const Text('Yes')),
                              ],
                            )),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10.0, bottom: 5.0),
                      child: Icon(
                        Icons.delete_outline,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                  )
                : Container(),
            widget.name == username &&
                    widget.id != null &&
                    !widget.closed &&
                    !widget.isBlacklisted
                ? InkWell(
                    onTap: () async {
                      await customNav(
                          CommentEditor(
                            data: widget.data,
                            id: widget.id!,
                            name: widget.name!,
                            url: widget.url!,
                            editText: widget.editText,
                            edit: true,
                          ),
                          context);
                      widget.onReply!();
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10.0, bottom: 5.0),
                      child: Icon(
                        Icons.edit_outlined,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                  )
                : Container(),
            widget.id != null && !widget.closed && !widget.isBlacklisted
                ? InkWell(
                    onTap: () async {
                      await customNav(
                          CommentEditor(
                              data: widget.data,
                              id: widget.id!,
                              name: widget.name!,
                              url: widget.url!),
                          context);
                      widget.onReply!();
                    },
                    child: Padding(
                      padding:
                          const EdgeInsets.only(left: 10.0, right: 10.0, bottom: 5.0),
                      child: Icon(
                        Icons.comment_outlined,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                  )
                : Container()
          ],
        )
      ],
    );
  }
}

class _AttachedImage extends StatefulWidget {
  const _AttachedImage({required this.data});
  final String data;

  @override
  State<_AttachedImage> createState() => _AttachedImageState();
}

class _AttachedImageState extends State<_AttachedImage> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    String data = widget.data;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: TextButton(
              onPressed: () => setState(() => _open = !_open),
              child: !_open
                  ? const Row(
                      children: [
                        Icon(Icons.image, size: 14),
                        Text(
                          ' View image',
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    )
                  : const Row(
                      children: [
                        Icon(Icons.image, size: 14),
                        Text(
                          ' Hide image',
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    )),
        ),
        _open
            ? CustomNetworkImage(
                resize: false,
                alignment: Alignment.topLeft,
                url: data,
              )
            : Container()
      ],
    );
  }
}
