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
import 'package:snag/common/custom_text_field.dart';
import 'package:snag/common/functions/button_background_color.dart';
import 'package:snag/common/functions/resize_image.dart';
import 'package:snag/common/paged_progress_indicator.dart';
import 'package:snag/common/simple_filter_model.dart';
import 'package:snag/nav/custom_drawer.dart';
import 'package:snag/nav/custom_drawer_appbar.dart';
import 'package:snag/nav/custom_nav.dart';
import 'package:snag/nav/pages.dart';
import 'package:snag/provider_models/entered_filter_provider.dart';
import 'package:snag/provider_models/theme_provider.dart';
import 'package:snag/views/giveaways/functions/change_giveaway_state.dart';
import 'package:snag/views/giveaways/functions/fetch_giveaway_list.dart';
import 'package:snag/views/giveaways/giveaway/giveaway.dart';
import 'package:snag/views/giveaways/giveaway/giveaway_model.dart';
import 'package:snag/views/giveaways/giveaway/giveaway_theme.dart';

class EnteredList extends StatefulWidget {
  const EnteredList({super.key});

  @override
  State<EnteredList> createState() => _EnteredListState();
}

class _EnteredListState extends State<EnteredList> {
  final PagingController<int, GiveawayListModel> _pagingController =
      PagingController(firstPageKey: 1);
  String _sort = '';
  late WidgetStateProperty<Color?> _bgColor;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _bgColor = buttonBackgroundColor(context);
    _pagingController.addPageRequestListener((pageKey) => fetchGiveawayList(
        pageKey,
        Entered.entered.url + _sort + context.read<EnteredFilterProvider>().filter,
        _parseEnteredList,
        _pagingController,
        context));
  }

  List<GiveawayListModel> _parseEnteredList(String data, int pageKey) {
    List<GiveawayListModel> giveaways = [];
    parse(data).getElementsByClassName('table__row-inner-wrap').forEach((element) {
      giveaways.add(_parseEnteredListElement(element));
    });
    return giveaways;
  }

  GiveawayListModel _parseEnteredListElement(dom.Element element) {
    dom.Document item = parse(element.innerHtml);
    dom.Element name = item.getElementsByClassName('table__column__heading')[0];
    List<dom.Element> heading = item.getElementsByClassName('is-faded');
    List<dom.Element> img = item.getElementsByClassName('table_image_thumbnail');
    String image = img.isNotEmpty ? img[0].attributes['style']! : '';
    String remaining =
        item.getElementsByClassName('table__column--width-fill')[0].children[1].text;
    String? points = heading.last.text;
    return GiveawayListModel(
        level: 0,
        creator: null,
        notStarted: null,
        name: name.firstChild!.text!.trim(),
        copies: heading.length == 1 ? null : heading[0].text,
        points: int.parse(points.substring(1, points.length - 2)),
        entries:
            item.getElementsByClassName('table__column--width-small text-center')[0].text,
        image: resizeImage(image == '' ? '' : image.substring(21, image.length - 2),
            CustomListTileTheme.leadingWidth.toInt()),
        href: name.attributes['href']!,
        entered: true,
        remaining: remaining,
        notEnded: !remaining.contains('Ended') && !remaining.contains('Deleted'),
        inviteOnly: false,
        group: false,
        whitelist: false,
        region: false,
        ago:
            '${item.getElementsByClassName('table__column--width-small text-center')[1].children[0].text} ago');
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomDrawerAppBar(
          name: Entered.entered.name,
          showPoints: true,
          filter: _EnteredFilter(pagingController: _pagingController),
        ),
        drawer: const CustomDrawer(
          giveawaysOpen: true,
        ),
        body: Center(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                      style: ButtonStyle(
                        backgroundColor: _sort == '' ? _bgColor : null,
                      ),
                      child: const Text('Open / Closed'),
                      onPressed: () {
                        setState(() {
                          _sort = '';
                          _pagingController.refresh();
                        });
                      }),
                  TextButton(
                      style: ButtonStyle(
                        backgroundColor: _sort == '&sort=deleted' ? _bgColor : null,
                      ),
                      child: const Text('Deleted'),
                      onPressed: () {
                        setState(() {
                          _sort = '&sort=deleted';
                          _pagingController.refresh();
                        });
                      }),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextButton(
                        style: ButtonStyle(
                          backgroundColor: _sort == '&sort=all' ? _bgColor : null,
                        ),
                        child: const Text('All'),
                        onPressed: () {
                          setState(() {
                            _sort = '&sort=all';
                            _pagingController.refresh();
                          });
                        }),
                  )
                ],
              ),
              Flexible(
                child: RefreshIndicator(
                    onRefresh: () => Future.sync(() => _pagingController.refresh()),
                    child: Consumer<ThemeProvider>(
                      builder: (context, theme, child) =>
                          PagedListView<int, GiveawayListModel>(
                              itemExtent: CustomPagedListTheme.itemExtent +
                                  addItemExtent(theme.fontSize),
                              pagingController: _pagingController,
                              builderDelegate:
                                  PagedChildBuilderDelegate<GiveawayListModel>(
                                      itemBuilder: (context, giveaway, index) => Column(
                                            children: [
                                              _EnteredListTile(
                                                giveaway: giveaway,
                                                onTileChange: (giveaway) =>
                                                    changeGiveawayState(
                                                        giveaway, context, setState),
                                              ),
                                            ],
                                          ),
                                      newPageProgressIndicatorBuilder: (context) =>
                                          const PagedProgressIndicator())),
                    )),
              ),
            ],
          ),
        ));
  }
}

typedef _TileChangeCallback = void Function(GiveawayListModel giveaway);

class _EnteredListTile extends StatefulWidget {
  const _EnteredListTile({required this.giveaway, required this.onTileChange});
  final GiveawayListModel giveaway;
  final _TileChangeCallback onTileChange;

  @override
  State<_EnteredListTile> createState() => _EnteredListTileState();
}

class _EnteredListTileState extends State<_EnteredListTile> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, theme, child) => ListTile(
          contentPadding: CustomListTileTheme.contentPadding,
          minVerticalPadding: CustomListTileTheme.minVerticalPadding,
          dense: CustomListTileTheme.dense,
          selected: widget.giveaway.notEnded,
          leading: CustomNetworkImage(
              image: widget.giveaway.image, width: CustomListTileTheme.leadingWidth),
          title: Row(
            children: [
              Flexible(
                //flexible wraps the text if it is too long
                child: Text(widget.giveaway.name,
                    style: TextStyle(
                        fontSize: CustomListTileTheme.titleTextSize + theme.fontSize),
                    overflow: CustomListTileTheme.overflow),
              ),
              widget.giveaway.copies != null
                  ? Text(
                      ' ${widget.giveaway.copies}',
                      style: TextStyle(
                          fontSize: CustomListTileTheme.titleTextSize + theme.fontSize),
                    )
                  : Container()
            ],
          ),
          subtitle: Row(
            children: [
              Text(
                '${widget.giveaway.points.toString()}P · ${widget.giveaway.entries} ',
                style: TextStyle(
                    fontSize:
                        CustomListTileTheme.subtitleTextSize + theme.fontSize / 1.9),
              ),
              Icon(Icons.groups, size: 14.0 + theme.fontSize / 1.9),
              Text(' · ${widget.giveaway.remaining} · Entered ${widget.giveaway.ago}',
                  style: TextStyle(
                      fontSize:
                          CustomListTileTheme.subtitleTextSize + theme.fontSize / 1.9))
            ],
          ),
          trailing: widget.giveaway.notEnded
              ? InkWell(
                  onTap: () => widget.onTileChange(widget.giveaway),
                  child: SizedBox(
                      width: CustomListTileTheme.trailingWidth,
                      height: CustomListTileTheme.trailingHeight,
                      child: widget.giveaway.entered
                          ? const Icon(Icons.remove)
                          : const Icon(Icons.add)))
              : null,
          onTap: () async {
            widget.giveaway.entered =
                await customNav(Giveaway(href: widget.giveaway.href!), context) as bool;

            setState(() {});
          }),
    );
  }
}

class _EnteredFilter extends StatelessWidget {
  const _EnteredFilter({required this.pagingController});
  final PagingController<int, GiveawayListModel> pagingController;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 18, right: 19),
      child: InkWell(
        onTap: () async {
          String filter = context.read<EnteredFilterProvider>().filter;
          await showDialog(
              context: context,
              builder: (context) {
                return const _EnteredFilterDialog();
              });
          if (context.mounted) {
            if (filter != context.read<EnteredFilterProvider>().filter) {
              pagingController.refresh();
            }
          }
        },
        child: Consumer<EnteredFilterProvider>(
            builder: (context, user, child) => user.model == SimpleFilterModel()
                ? const Icon(Icons.filter_alt_off)
                : Icon(Icons.filter_alt, color: Colors.green[400])),
      ),
    );
  }
}

class _EnteredFilterDialog extends StatefulWidget {
  const _EnteredFilterDialog();

  @override
  State<_EnteredFilterDialog> createState() => _EnteredFilterDialogState();
}

class _EnteredFilterDialogState extends State<_EnteredFilterDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final double _height = 48;
  late TextEditingController _search;

  @override
  void initState() {
    _search =
        TextEditingController(text: context.read<EnteredFilterProvider>().model.search);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        content: Form(
          key: _formKey,
          child: SizedBox(
            height: _height,
            child: Row(
              children: [
                const SizedBox(width: 55, child: Text('Search')),
                CustomTextFormField(
                    hintText: 'Search',
                    controller: _search,
                    validator: textValidator,
                    type: TextInputType.text),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
              child: const Text('Clear'),
              onPressed: () {
                context.read<EnteredFilterProvider>().updateModel(SimpleFilterModel());
                context.read<EnteredFilterProvider>().updateFilter('');
                Navigator.of(context).pop();
              }),
          TextButton(
              child: const Text('Apply'),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  String filter = '';
                  if (_search.text != '') {
                    filter = '$filter&q=${_search.text}';
                  }

                  context
                      .read<EnteredFilterProvider>()
                      .updateModel(SimpleFilterModel(search: _search.text));
                  context.read<EnteredFilterProvider>().updateFilter(filter);

                  Navigator.of(context).pop();
                }
              })
        ]);
  }
}
