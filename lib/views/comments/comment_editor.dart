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

import 'package:snag/common/card_theme.dart';
import 'package:snag/common/custom_text_field.dart';
import 'package:snag/common/functions/res_map.dart';
import 'package:snag/common/functions/res_map_ajax.dart';
import 'package:snag/common/vars/prefs.dart';
import 'package:snag/common/vars/prefs_keys.dart';
import 'package:snag/views/comments/custom_html.dart';

class CommentEditor extends StatefulWidget {
  const CommentEditor(
      {super.key,
      required this.data,
      this.id = '',
      required this.name,
      required this.url,
      this.editText = '',
      this.edit = false});
  final dom.Element data;
  final String id;
  final String name;
  final String url;
  final String editText;
  final bool edit;

  @override
  State<CommentEditor> createState() => _CommentEditorState();
}

class _CommentEditorState extends State<CommentEditor> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    _controller.text = widget.editText;
    _controller.addListener(_listener);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.name),
      ),
      body: ListView(
        children: [
          widget.data.text.trim() != ''
              ? Card(
                  elevation: CustomCardTheme.elevation,
                  surfaceTintColor: CustomCardTheme.surfaceTintColor,
                  child: CustomHtml(
                    data: widget.data,
                  ),
                )
              : Container(),
          Padding(
            padding: const EdgeInsets.only(left: 15, right: 15),
            child: TextField(
              autofocus: true,
              controller: _controller,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              textCapitalization: TextCapitalization.sentences,
            ),
          ),
          Row(
            children: [
              IconButton(
                  icon: Icon(Icons.format_italic),
                  onPressed: () {
                    _addFormat('*');
                  }),
              IconButton(
                  icon: Icon(Icons.format_bold),
                  onPressed: () {
                    _addFormat('**');
                  }),
              IconButton(
                  icon: Icon(Icons.square),
                  onPressed: () {
                    _addFormat('~');
                  }),
              IconButton(
                  icon: Icon(Icons.strikethrough_s),
                  onPressed: () {
                    _addFormat('~~');
                  }),
              IconButton(
                  icon: Icon(Icons.link),
                  onPressed: () async {
                    TextSelection selection = _controller.selection;
                    String text = _controller.text;
                    String selectedText = selection.textInside(text);
                    showDialog(
                        context: context,
                        builder: (context) => _CommentDialog(
                            selectedText: selectedText,
                            name: 'Link')).then((value) {
                      _controller.text =
                          '${text.substring(0, selection.start)}[${value[0]}](${value[1]})${text.substring(selection.end, text.length)}';
                    });
                  }),
              IconButton(
                icon: Icon(Icons.image),
                onPressed: () async {
                  TextSelection selection = _controller.selection;
                  String text = _controller.text;
                  String selectedText = selection.textInside(text);
                  showDialog(
                      context: context,
                      builder: (context) => _CommentDialog(
                          selectedText: selectedText,
                          name: 'Image')).then((value) {
                    _controller.text =
                        '${text.substring(0, selection.start)}![${value[0]}](${value[1]})${text.substring(selection.end, text.length)}';
                  });
                },
              ),
              Spacer(),
              IconButton(
                  onPressed: _controller.text.isNotEmpty
                      ? () async {
                          String body = '';
                          if (widget.edit) {
                            body =
                                'xsrf_token=${prefs.getString(PrefsKeys.xsrf.key)}&do=comment_edit&allow_replies=1&comment_id=${widget.id}&description=${_controller.text}';
                          } else {
                            body =
                                'do=comment_new&xsrf_token=${prefs.getString(PrefsKeys.xsrf.key)}&parent_id=${widget.id}&description=${_controller.text}';
                          }
                          Map responseMap = widget.edit
                              ? await resMapAjax(body)
                              : await resMap(body, widget.url);
                          if (responseMap['type'] == 'success') {
                            if (context.mounted) Navigator.pop(context, true);
                          }
                        }
                      : null,
                  icon: const Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Icon(Icons.send),
                  )),
            ],
          ),
        ],
      ),
    );
  }

  void _addFormat(String formater) {
    TextSelection selection = _controller.selection;
    String text = _controller.text;
    String selectedText = selection.textInside(text);
    int cursor = selection.base.offset;
    bool empty = selectedText == '';
    _controller.text =
        '${text.substring(0, selection.start)}$formater$selectedText$formater${text.substring(selection.end, text.length)}';
    if (empty) {
      _controller.selection = TextSelection.fromPosition(
          TextPosition(offset: cursor + formater.length));
    }
  }

  void _listener() {
    setState(() {});
  }
}

class _CommentDialog extends StatefulWidget {
  const _CommentDialog({required this.selectedText, required this.name});
  final String selectedText;
  final String name;

  @override
  State<_CommentDialog> createState() => _CommentDialogState();
}

class _CommentDialogState extends State<_CommentDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController _text;
  final TextEditingController _link = TextEditingController();

  @override
  void initState() {
    _text = TextEditingController(text: widget.selectedText);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TextRow(
                    title: 'Text',
                    controller: _text,
                    type: TextInputType.text,
                    textCapitalization: TextCapitalization.sentences),
                _TextRow(
                    title: widget.name,
                    controller: _link,
                    type: TextInputType.url),
              ],
            )),
        actions: [
          TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              }),
          TextButton(
              child: const Text('Add'),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  Navigator.of(context).pop([_text.text, _link.text]);
                }
              })
        ]);
  }
}

class _TextRow extends StatelessWidget {
  const _TextRow(
      {required this.title,
      required this.controller,
      required this.type,
      this.textCapitalization = TextCapitalization.none});
  final String title;
  final TextEditingController controller;
  final TextInputType type;
  final TextCapitalization textCapitalization;
  final double height = 48;
  final double width = 50;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: height,
        child: Row(
          children: [
            SizedBox(width: width, child: Text(title)),
            CustomTextField(
                hintText: title,
                controller: controller,
                validator: textValidator,
                type: type,
                textCapitalization: textCapitalization),
          ],
        ));
  }
}
