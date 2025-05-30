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

import 'package:cached_network_image/cached_network_image.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart';

import 'package:snag/views/giveaways/giveaway/giveaway_model.dart';

List<GiveawayListModel> parseList(dom.Element container, [String? username]) {
  List<GiveawayListModel> giveaways = [];
  container.getElementsByClassName('giveaway__row-outer-wrap').forEach((element) {
    giveaways.add(parseGiveawayListElement(element, username));
  });
  return giveaways;
}

GiveawayListModel parseGiveawayListElement(dom.Element element, [String? username]) {
  dom.Document item = parse(element.innerHtml);
  dom.Element name = item.getElementsByClassName('giveaway__heading__name')[0];
  List<dom.Element> heading = item.getElementsByClassName('giveaway__heading__thin');
  String? points = heading.isNotEmpty ? heading.last.text : null;
  List<dom.Element> lvl =
      item.getElementsByClassName('giveaway__column--contributor-level');
  List<dom.Element> img = item.getElementsByClassName('giveaway_image_thumbnail');
  String? image = img.isNotEmpty ? img[0].attributes['style'] : '';
  image = image == '' ? '' : image?.substring(21, image.length - 2);
  String entr = item.getElementsByClassName('giveaway__links')[0].children[0].text;
  dom.Node time = item.getElementsByClassName('fa fa-clock-o')[0].parentNode!;
  bool notEnded = time.nodes.length > 3;
  List<dom.Element> usernameElement = item.getElementsByClassName('giveaway__username');
  return GiveawayListModel(
      ago: null,
      creator: usernameElement.isNotEmpty ? usernameElement[0].text : username,
      name: name.text.trim(),
      entries: entr.substring(0, entr.length - 7).trim(),
      image: image == ''
          ? const Icon(Icons.error)
          : CachedNetworkImage(
              fadeInDuration: const Duration(milliseconds: 100),
              filterQuality: FilterQuality.high,
              imageUrl: image!,
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
      href: name.attributes['href'],
      entered:
          element.innerHtml.contains('giveaway__row-inner-wrap is-faded') ? true : false,
      remaining: time.nodes[2].text!,
      copies: points != null
          ? heading.length == 1
              ? null
              : heading[0].text
          : null,
      points: points != null ? int.parse(points.substring(1, points.length - 2)) : null,
      level:
          lvl.isEmpty ? 0 : int.parse(lvl[0].text.substring(6, lvl[0].text.length - 1)),
      inviteOnly: item.getElementsByClassName('giveaway__column--invite-only').isNotEmpty,
      group: item.getElementsByClassName('giveaway__column--group').isNotEmpty,
      whitelist: item.getElementsByClassName('giveaway__column--whitelist').isNotEmpty,
      region:
          item.getElementsByClassName('giveaway__column--region-restricted').isNotEmpty,
      notEnded: notEnded ? time.nodes[3].text!.contains('remaining') : true,
      notStarted: notEnded ? false : time.nodes[1].text!.contains('Begins'));
}
