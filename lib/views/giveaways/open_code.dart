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

import 'package:snag/views/giveaways/giveaway/giveaway.dart';
import 'package:snag/nav/custom_back_appbar.dart';
import 'package:snag/nav/custom_nav.dart';

class OpenCode extends StatelessWidget {
  const OpenCode({super.key});

  @override
  Widget build(BuildContext context) {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    TextEditingController controller = TextEditingController();
    return Scaffold(
        appBar: CustomBackAppBar(name: 'Open Code'),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                  child: const Text(
                      'Enter the 5 character code from the giveway URL to open a giveaway:')),
            ),
            Form(
              key: formKey,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                          autovalidateMode: AutovalidateMode.disabled,
                          validator: (value) {
                            if (value?.length != 5) {
                              return 'Invalid code: 5 characters';
                            }
                            return null;
                          },
                          controller: controller,
                          keyboardType: TextInputType.text,
                          decoration: const InputDecoration(labelText: 'Code'),
                          onFieldSubmitted: ((value) => {
                                if (formKey.currentState!.validate())
                                  customNav(
                                      Giveaway(
                                          href:
                                              '/giveaway/${controller.text}/'),
                                      context)
                              })),
                    ),
                    ElevatedButton(
                        onPressed: () => {
                              if (formKey.currentState!.validate())
                                customNav(
                                    Giveaway(
                                        href: '/giveaway/${controller.text}/'),
                                    context)
                            },
                        child: const Text('Open'))
                  ],
                ),
              ),
            ),
          ],
        ));
  }
}
