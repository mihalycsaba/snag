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

import 'package:html/parser.dart';
import 'package:open_settings_plus/open_settings_plus.dart';
import 'package:workmanager/workmanager.dart';

import 'package:snag/common/functions/fetch_body.dart';
import 'package:snag/common/functions/notification_permission.dart';
import 'package:snag/common/functions/res_map_ajax.dart';
import 'package:snag/common/vars/prefs.dart';
import 'package:snag/common/vars/prefs_keys.dart';
import 'package:snag/nav/custom_back_appbar.dart';
import 'package:snag/sg.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});
  static const double paddingHeight = 10.0;
  static bool notificationsDenied =
      prefs.getBool(PrefsKeys.notificationsDenied.key)!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomBackAppBar(name: 'Settings'),
        body: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: 12.0, vertical: paddingHeight),
          child: Column(
            children: [
              notificationsDenied
                  ? Padding(
                      padding:
                          const EdgeInsets.symmetric(vertical: paddingHeight),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                              child: Text(
                                  'You can enable notifications in the settings. Restart the app after.')),
                          _AppSettings(),
                        ],
                      ),
                    )
                  : Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: paddingHeight),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Text(
                                    'You can disable notifications and related background tasks by disabling them in the settings.'),
                              ),
                              _AppSettings(),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: paddingHeight),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Text(
                                    "Disable battery optimization for this app, to keep getting notifications even if you don't use the app for a while. Find this app in the All apps list."),
                              ),
                              GestureDetector(
                                onTap: () => OpenSettingsPlusAndroid()
                                    .ignoreBatteryOptimization(),
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: Icon(Icons.settings),
                                ),
                              )
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: paddingHeight),
                          child: _PointsWidget(),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: paddingHeight),
                          child: _NotificationFrequency(),
                        ),
                      ],
                    ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: paddingHeight),
                child: const Divider(height: 0),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: paddingHeight),
                child: const _SyncWidget(),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: paddingHeight),
                child: const Divider(height: 0),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: paddingHeight - 7.0),
                child: const _ThemeWidget(),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: paddingHeight),
                child: const Divider(height: 0),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: paddingHeight),
                child: const Text(
                    "To enable opening steamgifts.com links in this app, in the app's Open by default menu enable steamgifts.com domains by tapping on + Add links and selecting the two domains."),
              ),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Flexible(
                    child: Text(
                        'You should be able to find these settings in this list:')),
                GestureDetector(
                  onTap: () => OpenSettingsPlusAndroid().manageDefaultApps(),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Icon(Icons.settings),
                  ),
                )
              ])
            ],
          ),
        ));
  }
}

class _AppSettings extends StatelessWidget {
  const _AppSettings();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => OpenSettingsPlusAndroid().appNotification(),
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: Icon(Icons.settings),
      ),
    );
  }
}

class _PointsWidget extends StatefulWidget {
  const _PointsWidget();

  @override
  State<_PointsWidget> createState() => _PointsWidgetState();
}

class _PointsWidgetState extends State<_PointsWidget> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _pointLimit = TextEditingController(
      text: prefs.getInt(PrefsKeys.pointLimit.key).toString());
  bool _equal = true;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Row(
        children: [
          const Text('Notify after points:'),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextFormField(
                textAlign: TextAlign.end,
                controller: _pointLimit,
                keyboardType: TextInputType.number,
                onChanged: (value) => _equal = _changed(
                    value,
                    prefs.getInt(PrefsKeys.pointLimit.key).toString(),
                    _equal,
                    setState),
                maxLines: 1,
                decoration: _customDecoration('points'),
                validator: (value) => _limitValidator(value),
                autovalidateMode: AutovalidateMode.always,
              ),
            ),
          ),
          ElevatedButton(
              onPressed: _equal ? null : _saveLimit, child: const Text('Save'))
        ],
      ),
    );
  }

  void _saveLimit() {
    if (_formKey.currentState!.validate()) {
      prefs.setInt(PrefsKeys.pointLimit.key, int.parse(_pointLimit.text));
      prefs.setBool(PrefsKeys.pointsNotification.key, false);
      notificationPermission();
      _equal = true;
      setState(() {});
    }
  }

  String? _limitValidator(String? value) {
    if (value != null && value.isNotEmpty) {
      int? number = int.tryParse(value);
      if (number != null) {
        if (number < 1 || number > 399) {
          return '1..399';
        }
      } else {
        return 'not integer';
      }
    }
    return null;
  }
}

class _NotificationFrequency extends StatefulWidget {
  const _NotificationFrequency();

  @override
  State<_NotificationFrequency> createState() => _NotificationFrequencyState();
}

class _NotificationFrequencyState extends State<_NotificationFrequency> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _pointLimit =
      TextEditingController(text: prefs.getString(PrefsKeys.frequency.key));
  bool _equal = true;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Row(
        children: [
          const Text('Notification frequency in minutes:'),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextFormField(
                textAlign: TextAlign.end,
                controller: _pointLimit,
                keyboardType: TextInputType.number,
                onChanged: (value) => _equal = _changed(value,
                    prefs.getString(PrefsKeys.frequency.key), _equal, setState),
                maxLines: 1,
                decoration: _customDecoration('minutes'),
                validator: (value) => _frequencyValidator(value),
                autovalidateMode: AutovalidateMode.always,
              ),
            ),
          ),
          ElevatedButton(
              onPressed: _equal ? null : _saveFrequency,
              child: const Text('Save'))
        ],
      ),
    );
  }

  void _saveFrequency() {
    if (_formKey.currentState!.validate()) {
      prefs.setString(PrefsKeys.frequency.key, _pointLimit.text);
      Workmanager().cancelAll();
      notificationPermission();
      _equal = true;
      setState(() {});
    }
  }

  String? _frequencyValidator(String? value) {
    if (value != null && value.isNotEmpty) {
      int? number = int.tryParse(value);
      if (number != null) {
        if (number < 15) {
          return 'minimum 15';
        }
      } else {
        return 'not integer';
      }
    }
    return null;
  }
}

bool _changed(String value, String? frequency, bool equal, Function callback) {
  equal = true;
  if (value != frequency) {
    equal = false;
  }
  callback(() {});
  return equal;
}

InputDecoration _customDecoration(String hintText) {
  return InputDecoration(
    isDense: true,
    border: const UnderlineInputBorder(),
    hintText: hintText,
    hintStyle: TextStyle(fontSize: 12, color: Colors.grey[500]),
  );
}

class _SyncWidget extends StatefulWidget {
  const _SyncWidget();

  @override
  State<_SyncWidget> createState() => _SyncWidgetState();
}

class _SyncWidgetState extends State<_SyncWidget> {
  String _message = 'Loading';
  bool _buttonEnabled = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetch(context);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(_message),
        ElevatedButton(
            onPressed: _buttonEnabled
                ? () async {
                    setState(() {
                      _buttonEnabled = false;
                    });
                    await _sync(context);
                    if (context.mounted) {
                      await _fetch(context);
                    }
                  }
                : null,
            child: const Text('Sync'))
      ],
    );
  }

  Future<void> _sync(BuildContext context) async {
    String body = 'xsrf_token=${prefs.getString(PrefsKeys.xsrf.key)}&do=sync';
    await resMapAjax(body);
  }

  Future<void> _fetch(BuildContext context) async {
    String data = await fetchBody(
        url: 'https://www.steamgifts.com/account/settings/profile');
    _message = parse(data)
        .getElementsByClassName('notification notification')[0]
        .text
        .trim();
    setState(() {
      _buttonEnabled = true;
    });
  }
}

class _ThemeWidget extends StatefulWidget {
  const _ThemeWidget();

  @override
  State<_ThemeWidget> createState() => _ThemeWidgetState();
}

class _ThemeWidgetState extends State<_ThemeWidget> {
  bool _value = prefs.getBool(PrefsKeys.dynamicColor.key)!;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Dynamic theme color'),
        Switch(
          value: _value,
          onChanged: (value) {
            setState(() {
              _value = value;
              SG.of(context)!.changeTheme(_value);
            });
          },
        ),
      ],
    );
  }
}
