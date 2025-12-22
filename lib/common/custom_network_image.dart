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

class CustomNetworkImage extends StatefulWidget {
  const CustomNetworkImage(
      {required this.url,
      required this.resize,
      this.width,
      this.height,
      this.alignment,
      this.fit,
      super.key});

  final String url;
  final bool resize;
  final double? width;
  final double? height;
  final AlignmentGeometry? alignment;
  final BoxFit? fit;

  @override
  State<CustomNetworkImage> createState() => _CustomNetworkImageState();
}

class _CustomNetworkImageState extends State<CustomNetworkImage> {
  late final NetworkImage networkImage;

  @override
  void initState() {
    super.initState();
    networkImage = NetworkImage(widget.url);
  }

  @override
  Widget build(BuildContext context) {
    return Image(
        alignment: widget.alignment ?? Alignment.center,
        fit: widget.fit,
        width: widget.width,
        height: widget.height,
        image: widget.resize
            ? ResizeImage(networkImage, width: widget.width?.toInt())
            : networkImage,
        errorBuilder: (context, error, stackTrace) => const Icon(Icons.error));
  }
}
