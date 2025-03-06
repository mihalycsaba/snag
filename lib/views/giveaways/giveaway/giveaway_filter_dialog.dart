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

import 'package:snag/common/custom_text_field.dart';
import 'package:snag/provider_models/giveaway_filter_provider.dart';
import 'package:snag/views/giveaways/giveaway/giveaway_filter_model.dart';

class GiveawayFilterDialog extends StatefulWidget {
  const GiveawayFilterDialog({super.key});

  @override
  State<GiveawayFilterDialog> createState() => _GiveawayFilterDialogState();
}

class _GiveawayFilterDialogState extends State<GiveawayFilterDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final double _height = 48;
  final double _width = 50;
  late TextEditingController _search;
  late TextEditingController _minLevel;
  late TextEditingController _maxLevel;
  late TextEditingController _minEntries;
  late TextEditingController _maxEntries;
  late TextEditingController _minPoints;
  late TextEditingController _maxPoints;
  late TextEditingController _minCopies;
  late TextEditingController _maxCopies;
  late bool _hideEntered;
  late bool _onlyRegionRestricted;

  @override
  void initState() {
    _search = TextEditingController(
        text: context.read<GiveawayFilterProvider>().model.search);
    _minLevel = TextEditingController(
        text: context.read<GiveawayFilterProvider>().model.minLevel);
    _maxLevel = TextEditingController(
        text: context.read<GiveawayFilterProvider>().model.maxLevel);
    _minEntries = TextEditingController(
        text: context.read<GiveawayFilterProvider>().model.minEntries);
    _maxEntries = TextEditingController(
        text: context.read<GiveawayFilterProvider>().model.maxEntries);
    _minPoints = TextEditingController(
        text: context.read<GiveawayFilterProvider>().model.minPoints);
    _maxPoints = TextEditingController(
        text: context.read<GiveawayFilterProvider>().model.maxPoints);
    _minCopies = TextEditingController(
        text: context.read<GiveawayFilterProvider>().model.minCopies);
    _maxCopies = TextEditingController(
        text: context.read<GiveawayFilterProvider>().model.maxCopies);
    _hideEntered = context.read<GiveawayFilterProvider>().model.hideEntered;
    _onlyRegionRestricted =
        context.read<GiveawayFilterProvider>().model.onlyRegionRestricted;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: _height,
                  child: Row(
                    children: [
                      SizedBox(width: _width, child: const Text('Search')),
                      CustomTextField(
                          hintText: 'Search',
                          controller: _search,
                          validator: textValidator,
                          type: TextInputType.text),
                    ],
                  ),
                ),
                _FilterRow(
                  name: 'Level',
                  minController: _minLevel,
                  maxController: _maxLevel,
                  minValidator: minLimitValidator,
                  maxValidator: maxLimitValidator,
                  minNumber: 0,
                  maxNumber: 10,
                  height: _height,
                  width: _width,
                ),
                _FilterRow(
                  name: 'Entries',
                  minController: _minEntries,
                  maxController: _maxEntries,
                  minValidator: minValidator,
                  maxValidator: maxValidator,
                  height: _height,
                  width: _width,
                ),
                _FilterRow(
                  name: 'Points',
                  minController: _minPoints,
                  maxController: _maxPoints,
                  minValidator: minLimitValidator,
                  maxValidator: maxLimitValidator,
                  minNumber: 0,
                  maxNumber: 50,
                  height: _height,
                  width: _width,
                ),
                _FilterRow(
                  name: 'Copies',
                  minController: _minCopies,
                  maxController: _maxCopies,
                  minValidator: minValidator,
                  maxValidator: maxValidator,
                  height: _height,
                  width: _width,
                ),
                ChexkBoxRow(
                    text: 'Only region restricted giveaways',
                    isChecked: _onlyRegionRestricted,
                    onTap: () {
                      setState(() {
                        _onlyRegionRestricted = !_onlyRegionRestricted;
                      });
                    })
                //Todo:add remaining filters from sg
                //checkBoxRow('Hide entered giveaways'),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Clear'),
            onPressed: () {
              context
                  .read<GiveawayFilterProvider>()
                  .updateModel(GiveawayFilterModel());
              context.read<GiveawayFilterProvider>().updateFilter('');
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text('Apply'),
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                String filter = '';
                if (_search.text != '') {
                  filter = '$filter&q=${_search.text.trim()}';
                }
                if (_minLevel.text != '') {
                  filter = '$filter&level_min=${_minLevel.text}';
                }
                if (_maxLevel.text != '') {
                  filter = '$filter&level_max=${_maxLevel.text}';
                }
                if (_minEntries.text != '') {
                  filter = '$filter&entry_min=${_minEntries.text}';
                }
                if (_maxEntries.text != '') {
                  filter = '$filter&entry_max=${_maxEntries.text}';
                }
                if (_minPoints.text != '') {
                  filter = '$filter&point_min=${_minPoints.text}';
                }
                if (_maxPoints.text != '') {
                  filter = '$filter&point_max=${_maxPoints.text}';
                }
                if (_minCopies.text != '') {
                  filter = '$filter&copy_min=${_minCopies.text}';
                }
                if (_maxCopies.text != '') {
                  filter = '$filter&copy_max=${_maxCopies.text}';
                }
                if (_onlyRegionRestricted) {
                  filter = '$filter&region_restricted=true';
                }
                context.read<GiveawayFilterProvider>().updateModel(
                    GiveawayFilterModel(
                        search: _search.text.trim(),
                        minLevel: _minLevel.text,
                        maxLevel: _maxLevel.text,
                        minEntries: _minEntries.text,
                        maxEntries: _maxEntries.text,
                        minPoints: _minPoints.text,
                        maxPoints: _maxPoints.text,
                        minCopies: _minCopies.text,
                        maxCopies: _maxCopies.text,
                        hideEntered: _hideEntered,
                        onlyRegionRestricted: _onlyRegionRestricted));
                context.read<GiveawayFilterProvider>().updateFilter(filter);
                Navigator.of(context).pop();
              }
            },
          )
        ]);
  }

  String? minValidator(String? value, TextEditingController maxController) {
    if (value != null && value.isNotEmpty) {
      int? number = int.tryParse(value);
      if (number != null) {
        int maxNumber = maxCalc(maxController, number);
        if (number > maxNumber) {
          return '> max';
        }
      } else {
        return 'not integer';
      }
    }
    return null;
  }

  String? maxValidator(String? value, TextEditingController minController) {
    if (value != null && value.isNotEmpty) {
      int? number = int.tryParse(value);
      if (number != null) {
        return null;
      } else {
        return 'not integer';
      }
    }
    return null;
  }

  String? minLimitValidator(String? value, TextEditingController maxLimit,
      int minNumber, int maxNumber) {
    if (value != null && value.isNotEmpty) {
      int? number = int.tryParse(value);
      if (number != null) {
        if (number < minNumber || number > maxNumber) {
          return '$minNumber..$maxNumber';
        } else {
          int maxNumber = maxCalc(maxLimit, number);
          if (number > maxNumber) {
            return '> max';
          }
        }
      } else {
        return '$minNumber..$maxNumber';
      }
    }
    return null;
  }

  String? maxLimitValidator(String? value, TextEditingController minLimit,
      int minNumber, int maxNumber) {
    if (value != null && value.isNotEmpty) {
      int? number = int.tryParse(value);
      if (number != null) {
        if (number < minNumber || number > maxNumber) {
          return '$minNumber..$maxNumber';
        }
      } else {
        return '$minNumber..$maxNumber';
      }
    }
    return null;
  }

  int maxCalc(TextEditingController maxController, int number) {
    return maxController.text.isNotEmpty
        ? int.parse(maxController.text)
        : number + 1;
  }
}

class ChexkBoxRow extends StatelessWidget {
  const ChexkBoxRow(
      {this.height,
      required this.text,
      required this.isChecked,
      required this.onTap,
      super.key});
  final double? height;
  final String text;
  final bool isChecked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: height,
        child: Row(children: [
          Checkbox(
            value: isChecked,
            onChanged: (bool? value) => onTap(),
          ),
          Text(text)
        ]));
  }
}

class _FilterRow extends StatelessWidget {
  const _FilterRow({
    required this.name,
    required this.minController,
    required this.maxController,
    required this.minValidator,
    required this.maxValidator,
    required this.height,
    required this.width,
    this.minNumber,
    this.maxNumber,
  });
  final String name;
  final TextEditingController minController;
  final TextEditingController maxController;
  final Function minValidator;
  final Function maxValidator;

  final double height;
  final double width;
  final int? minNumber;
  final int? maxNumber;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Row(
        children: [
          SizedBox(width: width, child: Text(name)),
          CustomTextField(
              hintText: 'min',
              controller: minController,
              validator: minValidator,
              type: TextInputType.number,
              compareController: maxController,
              minNumber: minNumber,
              maxNumber: maxNumber),
          const SizedBox(width: 8),
          CustomTextField(
              hintText: 'max',
              controller: maxController,
              validator: maxValidator,
              type: TextInputType.number,
              compareController: minController,
              minNumber: minNumber,
              maxNumber: maxNumber),
        ],
      ),
    );
  }
}
