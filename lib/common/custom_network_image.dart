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

class CustomNetworkImage extends StatelessWidget {
  const CustomNetworkImage(
      {required this.image,
      this.width,
      this.height,
      this.alignment,
      this.fit,
      super.key});

  final ImageProvider image;
  final double? width;
  final double? height;
  final AlignmentGeometry? alignment;
  final BoxFit? fit;

  @override
  Widget build(BuildContext context) {
    return Image(
        alignment: alignment ?? Alignment.center,
        fit: fit,
        width: width,
        height: height,
        image: image,
        errorBuilder: (context, error, stackTrace) =>
            SizedBox(width: width, child: const Icon(Icons.error)));
  }
}
