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

import 'package:provider/provider.dart';

import 'package:snag/provider_models/giveaway_filter_provider.dart';
import 'package:snag/views/giveaways/giveaway/giveaway_filter_dialog.dart';
import 'package:snag/views/giveaways/giveaway/giveaway_filter_model.dart';

class GiveawayFilter extends StatelessWidget {
  const GiveawayFilter({required this.refresh, super.key});
  final Function refresh;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 18, right: 19),
      child: InkWell(
        onTap: () async {
          String filter = context.read<GiveawayFilterProvider>().filter;
          await showDialog(
              context: context, builder: (context) => const GiveawayFilterDialog());
          if (context.mounted) {
            if (filter != context.read<GiveawayFilterProvider>().filter) {
              refresh();
            }
          }
        },
        child: Consumer<GiveawayFilterProvider>(
            builder: (context, user, child) => user.model == GiveawayFilterModel()
                ? const Icon(Icons.filter_alt_off)
                : Icon(Icons.filter_alt, color: Colors.green[400])),
      ),
    );
  }
}
