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

import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';

import 'package:snag/common/custom_text_field.dart';
import 'package:snag/common/simple_filter_model.dart';
import 'package:snag/provider_models/discussion_filter_provider.dart';
import 'package:snag/views/discussions/discussion_model.dart';

class DiscussionFilter extends StatelessWidget {
  const DiscussionFilter({required this.pagingController, super.key});
  final PagingController<int, DiscussionModel> pagingController;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 18, right: 19),
      child: InkWell(
        onTap: () async {
          String filter = context.read<DiscussionFilterProvider>().filter;
          await showDialog(
              context: context,
              builder: (context) {
                return const _DiscussionFilterDialog();
              });
          if (context.mounted) {
            if (filter != context.read<DiscussionFilterProvider>().filter) {
              pagingController.refresh();
            }
          }
        },
        child: Consumer<DiscussionFilterProvider>(
            builder: (context, user, child) => user.model == SimpleFilterModel()
                ? const Icon(Icons.filter_alt_off)
                : Icon(
                    Icons.filter_alt,
                    color: Colors.green[400],
                  )),
      ),
    );
  }
}

class _DiscussionFilterDialog extends StatefulWidget {
  const _DiscussionFilterDialog();

  @override
  State<_DiscussionFilterDialog> createState() =>
      _DiscussionFilterDialogState();
}

class _DiscussionFilterDialogState extends State<_DiscussionFilterDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final double _height = 48;
  late TextEditingController _search;

  @override
  void initState() {
    _search = TextEditingController(
        text: context.read<DiscussionFilterProvider>().model.search);
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
                CustomTextField(
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
                context
                    .read<DiscussionFilterProvider>()
                    .updateModel(SimpleFilterModel());
                context.read<DiscussionFilterProvider>().updateFilter('');
                Navigator.of(context).pop();
              }),
          TextButton(
              child: const Text('Apply'),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  String filter = '';
                  if (_search.text != '') {
                    filter = '$filter&q=${_search.text.trim()}';
                  }
                  context.read<DiscussionFilterProvider>().updateModel(
                      SimpleFilterModel(search: _search.text.trim()));
                  context.read<DiscussionFilterProvider>().updateFilter(filter);

                  Navigator.of(context).pop();
                }
              })
        ]);
  }
}
