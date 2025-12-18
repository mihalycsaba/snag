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
import 'package:flutter/services.dart';

import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html_table/flutter_html_table.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart';
import 'package:provider/provider.dart';

import 'package:snag/common/functions/url_launcher.dart';
import 'package:snag/nav/custom_nav.dart';
import 'package:snag/provider_models/theme_provider.dart';
import 'package:snag/views/discussions/discussion.dart';
import 'package:snag/views/giveaways/giveaway/giveaway.dart';

class CustomHtml extends StatefulWidget {
  const CustomHtml({super.key, required this.data, this.active = false});
  final dom.Element data;
  final bool active;

  @override
  State<CustomHtml> createState() => _CustomHtmlState();
}

class _CustomHtmlState extends State<CustomHtml> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () => showDialog(
          context: context,
          builder: (context) => SimpleDialog(title: const Text('Copy'), children: [
                SimpleDialogOption(
                    onPressed: () => _clipboard(widget.data.text.trim(), context),
                    child: const Text('Text')),
                SimpleDialogOption(
                    onPressed: () => _clipboard(
                        parse(widget.data.innerHtml)
                            .getElementsByTagName('a')
                            .where((e) => e.attributes.containsKey('href'))
                            .map((e) => e.attributes['href'])
                            .toList()
                            .join('\n\n'),
                        context),
                    child: const Text('Links'))
              ])),
      child: Consumer<ThemeProvider>(
        builder: (context, theme, child) => Html(
          doNotRenderTheseTags: const {'img', 'div', 'br', 'hr'},
          data: widget.data.innerHtml,
          style: {
            "p": Style(
                fontSize: FontSize(14.0 + theme.fontSize),
                color: widget.active ? Theme.of(context).colorScheme.primary : null)
          },
          onLinkTap: (url, attributes, element) => _checkUrl(url!, context),
          extensions: [
            const TableHtmlExtension(),
            TagWrapExtension(
                tagsToWrap: {'table'},
                builder: (child) {
                  return Scrollbar(
                      controller: _scrollController,
                      thumbVisibility: true,
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        scrollDirection: Axis.horizontal,
                        child: child,
                      ));
                }),
          ],
        ),
      ),
    );
  }

  Future<void> _clipboard(String text, BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Copied to clipboard')));
    }
  }

  void _checkUrl(String url, BuildContext context) {
    if (url.startsWith('/')) url = 'https://www.steamgifts.com$url';
    if (url.contains('steamgifts.com/giveaway/')) {
      customNav(Giveaway(href: url.substring(url.indexOf('.com') + 4)), context);
    } else if (url.contains('steamgifts.com/discussion/')) {
      customNav(Discussion(href: url.substring(url.indexOf('.com') + 4)), context);
    } else {
      urlLauncher(url);
    }
  }
}
