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

import 'package:snag/common/custom_network_image.dart';
import 'package:snag/views/giveaways/giveaway/giveaway_theme.dart';

class LeadingImage extends StatelessWidget {
  const LeadingImage({required this.image, super.key});

  final String image;

  @override
  Widget build(BuildContext context) {
    return image == ''
        ? const SizedBox(
            width: CustomListTileTheme.leadingWidth, child: Icon(Icons.error))
        : CustomNetworkImage(
            resize: true,
            width: CustomListTileTheme.leadingWidth,
            url: image,
          );
  }
}
