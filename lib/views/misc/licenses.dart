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

import 'package:snag/common/card_theme.dart';
import 'package:snag/common/functions/url_launcher.dart';
import 'package:snag/nav/custom_back_appbar.dart';
import 'package:snag/views/misc/oss_licenses.dart';

class Licenses extends StatelessWidget {
  const Licenses({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: const CustomBackAppBar(name: 'Open source licenses'),
        body: ListView.builder(
            itemCount: allDependencies.length,
            itemBuilder: (BuildContext context, int index) => Padding(
                  padding: const EdgeInsets.only(
                      left: 4.0, right: 4.0, top: 10.0, bottom: 10.0),
                  child: Card(
                      surfaceTintColor: CustomCardTheme.surfaceTintColor,
                      elevation: CustomCardTheme.elevation - 1,
                      child: Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 15),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.ideographic,
                                  children: [
                                    Flexible(
                                      child: Text(allDependencies[index].name,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold, fontSize: 18)),
                                    ),
                                    const Text('  version: '),
                                    Text(allDependencies[index].version),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Text(allDependencies[index].description),
                              ),
                              allDependencies[index].repository != null
                                  ? Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('Repository: '),
                                        Flexible(
                                          child: GestureDetector(
                                            onTap: () => urlLauncher(
                                              allDependencies[index].repository!,
                                            ),
                                            child: Text(
                                              allDependencies[index].repository!,
                                              style: const TextStyle(color: Colors.blue),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  : Container(),
                              allDependencies[index].homepage != null
                                  ? Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('Homepage: '),
                                        Flexible(
                                          child: GestureDetector(
                                            onTap: () => urlLauncher(
                                              allDependencies[index].homepage!,
                                            ),
                                            child: Text(allDependencies[index].homepage!,
                                                style:
                                                    const TextStyle(color: Colors.blue)),
                                          ),
                                        ),
                                      ],
                                    )
                                  : Container(),
                              Padding(
                                padding: const EdgeInsets.only(top: 10.0),
                                child: Card(
                                    elevation: 0.1,
                                    surfaceTintColor: const Color.fromARGB(255, 0, 0, 0),
                                    child: Padding(
                                      padding: const EdgeInsets.all(6.0),
                                      child: Text(allDependencies[index].license!),
                                    )),
                              )
                            ]),
                      )),
                )));
  }
}
