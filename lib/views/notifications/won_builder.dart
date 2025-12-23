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

import 'package:snag/common/custom_network_image.dart';
import 'package:snag/common/functions/add_page.dart';
import 'package:snag/common/functions/fetch_body.dart';
import 'package:snag/common/functions/res_map_ajax.dart';
import 'package:snag/common/functions/resize_image.dart';
import 'package:snag/common/functions/url_launcher.dart';
import 'package:snag/common/paged_progress_indicator.dart';
import 'package:snag/common/vars/prefs.dart';
import 'package:snag/nav/custom_nav.dart';
import 'package:snag/provider_models/theme_provider.dart';
import 'package:snag/views/giveaways/giveaway/giveaway.dart';
import 'package:snag/views/giveaways/giveaway/giveaway_theme.dart';

class _WonListModel {
  String name;
  String image;
  bool opened;
  String href;
  String time;
  bool notReceived;
  bool keyIsRedeemable;
  String? keyButton;
  String? winnerId;
  String? redeemKeyLink;
  String? giftLink;
  bool giftLinkAvailable;
  bool active;
  _WonListModel(
      {required this.name,
      required this.image,
      required this.opened,
      required this.href,
      required this.time,
      required this.notReceived,
      required this.keyIsRedeemable,
      required this.keyButton,
      this.winnerId,
      this.redeemKeyLink,
      required this.active,
      this.giftLink,
      required this.giftLinkAvailable});
}

class WonBuilder extends StatefulWidget {
  const WonBuilder({super.key});

  @override
  State<WonBuilder> createState() => _WonBuilderState();
}

class _WonBuilderState extends State<WonBuilder> {
  final PagingController<int, _WonListModel> _pagingController =
      PagingController(firstPageKey: 1);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _pagingController.addPageRequestListener((pageKey) {
      fetchWonList(pageKey, context);
    });
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
        onRefresh: () => Future.sync(() => _pagingController.refresh()),
        child: Consumer<ThemeProvider>(
          builder: (context, theme, child) => PagedListView<int, _WonListModel>(
              itemExtent: CustomPagedListTheme.itemExtent + addItemExtent(theme.fontSize),
              pagingController: _pagingController,
              builderDelegate: PagedChildBuilderDelegate<_WonListModel>(
                itemBuilder: (context, giveaway, index) => Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 4.0),
                      child: ListTile(
                        selected: giveaway.notReceived,
                        contentPadding: CustomListTileTheme.contentPadding,
                        minVerticalPadding: CustomListTileTheme.minVerticalPadding,
                        dense: CustomListTileTheme.dense,
                        leading: CustomNetworkImage(
                            image: resizeImage(
                                giveaway.image, CustomListTileTheme.leadingWidth.toInt()),
                            width: CustomListTileTheme.leadingWidth),
                        title: Consumer<ThemeProvider>(
                          builder: (context, theme, child) => Text(giveaway.name,
                              style: TextStyle(
                                  fontSize:
                                      CustomListTileTheme.titleTextSize + theme.fontSize),
                              overflow: CustomListTileTheme.overflow),
                        ),
                        subtitle: Consumer<ThemeProvider>(
                          builder: (context, theme, child) => Text(
                            giveaway.time,
                            style: TextStyle(
                                fontSize: CustomListTileTheme.subtitleTextSize +
                                    theme.fontSize),
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            giveaway.keyButton != null
                                ? Consumer<ThemeProvider>(
                                    builder: (context, theme, child) => TextButton(
                                        child: Text('Open gift',
                                            style: TextStyle(
                                                fontSize: 12.0 + theme.fontSize)),
                                        onPressed: () async {
                                          await resMapAjax(giveaway.keyButton!)
                                              .then((value) {
                                            _pagingController.refresh();
                                          });
                                        }),
                                  )
                                : giveaway.keyIsRedeemable && giveaway.notReceived
                                    ? Consumer<ThemeProvider>(
                                        builder: (context, theme, child) => TextButton(
                                            onPressed: () =>
                                                urlLauncher(giveaway.redeemKeyLink!),
                                            child: Text('Redeem',
                                                style: TextStyle(
                                                    fontSize: 12.0 + theme.fontSize))),
                                      )
                                    : !giveaway.keyIsRedeemable &&
                                            giveaway.notReceived &&
                                            !giveaway.giftLinkAvailable
                                        ? const TextButton(
                                            onPressed: null,
                                            child: Text('No key'),
                                          )
                                        : giveaway.notReceived &&
                                                giveaway.giftLinkAvailable
                                            ? TextButton(
                                                onPressed: () =>
                                                    urlLauncher(giveaway.giftLink!),
                                                child: const Text(
                                                  'Link',
                                                ))
                                            : Container(),
                            giveaway.notReceived
                                ? _Received(
                                    pagingController: _pagingController,
                                    giveaway: giveaway,
                                    action: '1',
                                    icon: Icons.close,
                                    active: giveaway.active,
                                  )
                                : _Received(
                                    pagingController: _pagingController,
                                    giveaway: giveaway,
                                    action: '',
                                    icon: Icons.check,
                                    active: giveaway.active,
                                  )
                          ],
                        ),
                        onTap: () => customNav(Giveaway(href: giveaway.href), context),
                      ),
                    ),
                  ],
                ),
                newPageProgressIndicatorBuilder: (context) =>
                    const PagedProgressIndicator(),
              )),
        ));
  }

  Future<void> fetchWonList(int pageKey, BuildContext context) async {
    String data = await fetchBody(
        url:
            'https://www.steamgifts.com/giveaways/won/search?page=${pageKey.toString()}');
    List<_WonListModel> wonList = parseWonList(data);
    addPage(wonList, _pagingController, pageKey,
        parse(data).getElementsByClassName('widget-container').first);
  }

  List<_WonListModel> parseWonList(String data) {
    List<_WonListModel> wonList = [];
    parse(data).getElementsByClassName('table__row-inner-wrap').forEach((element) {
      wonList.add(parseWonListElement(element));
    });
    return wonList;
  }

  _WonListModel parseWonListElement(dom.Element element) {
    dom.Document item = parse(element.innerHtml);
    dom.Element name = item.getElementsByClassName('table__column__heading')[0];
    List<dom.Element> img = item.getElementsByClassName('table_image_thumbnail');
    String image = img.isNotEmpty ? img[0].attributes['style']! : '';
    List<dom.Element> redeemKey =
        item.getElementsByClassName('table__column__key__redeem');
    List<dom.Element> keyButton = item.getElementsByClassName('view_key_btn');
    bool keyIsRedeemable = redeemKey.isNotEmpty;
    List<dom.Element> giftLink =
        item.getElementsByClassName('table__column__secondary-link');
    bool giftLinkAvailable = giftLink.isNotEmpty;
    dom.Element feedback = item.getElementsByClassName('table__column--gift-feedback')[0];
    bool active = feedback.nodes.length > 3;
    bool notReceived =
        item.getElementsByClassName('table__gift-feedback-awaiting-reply').isNotEmpty &&
            item
                .getElementsByClassName('table__gift-feedback-awaiting-reply is-hidden')
                .isEmpty;
    return _WonListModel(
        name: name.text,
        image: image == '' ? '' : image.substring(21, image.length - 2),
        opened: item.getElementsByClassName('view_key_btn').isEmpty,
        href: name.attributes['href']!,
        time:
            item.getElementsByClassName('table__column--width-fill')[0].children[1].text,
        notReceived: notReceived,
        keyIsRedeemable: keyIsRedeemable,
        keyButton: keyButton.isNotEmpty ? keyButton[0].attributes['data-form']! : null,
        winnerId: active ? feedback.children[0].children[3].attributes['value'] : null,
        active: active,
        redeemKeyLink: keyIsRedeemable ? redeemKey[0].attributes['href']! : null,
        giftLinkAvailable: giftLinkAvailable,
        giftLink: giftLinkAvailable ? giftLink[0].attributes['href']! : null);
  }
}

class _Received extends StatelessWidget {
  const _Received({
    required this.pagingController,
    required this.giveaway,
    required this.action,
    required this.icon,
    required this.active,
  });
  final _WonListModel giveaway;
  final PagingController<int, _WonListModel> pagingController;
  final String action;
  final IconData icon;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonalIcon(
        onPressed: active
            ? () async {
                await resMapAjax(
                        'xsrf_token=${prefs.getString(PrefsKeys.xsrf.key)!}&do=received_feedback&action=$action&winner_id=${giveaway.winnerId!}')
                    .then((value) {
                  pagingController.refresh();
                });
              }
            : null,
        icon: Icon(
          icon,
          size: 14,
        ),
        label: Consumer<ThemeProvider>(
            builder: (context, theme, child) => Text(
                  'Received',
                  style: TextStyle(fontSize: 12.0 + theme.fontSize),
                )));
  }
}
