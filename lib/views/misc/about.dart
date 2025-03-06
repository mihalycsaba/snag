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

import 'package:flutter_svg/flutter_svg.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:vector_graphics/vector_graphics.dart';

import 'package:snag/common/functions/url_launcher.dart';
import 'package:snag/nav/custom_back_appbar.dart';
import 'package:snag/nav/custom_nav.dart';
import 'package:snag/views/misc/licenses.dart';
import 'package:snag/views/misc/user.dart';

class About extends StatefulWidget {
  const About({super.key});

  @override
  State<About> createState() => _AboutState();
}

class _AboutState extends State<About> with TickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(seconds: 4),
    vsync: this,
  );
  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    curve: Curves.elasticOut,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomBackAppBar(name: 'About'),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            RotationTransition(
              turns: _animation,
              child: GestureDetector(
                onTap: () => _controller
                    .forward()
                    .whenCompleteOrCancel(_controller.reset),
                child: SizedBox(
                    width: 290,
                    height: 290,
                    child:
                        SvgPicture(AssetBytesLoader('assets/snag_fg.svg.vec'))),
              ),
            ),
            SizedBox(height: 40),
            FutureBuilder(
              future: PackageInfo.fromPlatform(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return Text(
                      '${snapshot.data?.appName} version: ${snapshot.data?.version}',
                      style: TextStyle(fontSize: 16));
                } else {
                  return Container();
                }
              },
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Created by ', style: TextStyle(fontSize: 16)),
                  GestureDetector(
                    onTap: () => customNav(User(name: 'GoatPimp'), context),
                    child: Text('GoatPimp',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        )),
                  )
                ],
              ),
            ),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text('Powered by ', style: TextStyle(fontSize: 16)),
              GestureDetector(
                onTap: () => urlLauncher('https://flutter.dev/'),
                child: Text('Flutter 🩵',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.lightBlueAccent)),
              )
            ]),
            SizedBox(height: 40),
            TextButton(
                onPressed: () =>
                    urlLauncher('https://github.com/mihalycsaba/snag'),
                child: Text('Source code', style: TextStyle(fontSize: 18))),
            TextButton(
                onPressed: () =>
                    urlLauncher('https://github.com/mihalycsaba/snag/issues'),
                child: Text('Report an issue', style: TextStyle(fontSize: 18))),
            TextButton(
                onPressed: () => customNav(Licenses(), context),
                child: Text('Open source licenses',
                    style: TextStyle(fontSize: 18))),
            SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text.rich(TextSpan(
                    text: 'Huge thanks to ',
                    style: TextStyle(fontSize: 16),
                    children: [
                      TextSpan(
                          text: 'cg',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      TextSpan(
                          text: ' for creating ',
                          style: TextStyle(fontSize: 16)),
                    ])),
                GestureDetector(
                  onTap: () => urlLauncher('https://steamgifts.com/'),
                  child: Text('steamgifts.com',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      )),
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text.rich(
                    TextSpan(
                        text: 'Please consider supporting them on ',
                        style: TextStyle(
                          fontSize: 16,
                        )),
                  ),
                  GestureDetector(
                    onTap: () =>
                        urlLauncher('https://www.patreon.com/steamgifts'),
                    child: Text('Patreon',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange)),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
