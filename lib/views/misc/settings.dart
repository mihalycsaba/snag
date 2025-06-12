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

import 'dart:collection';

import 'package:flutter/material.dart';

import 'package:html/parser.dart';
import 'package:open_settings_plus/open_settings_plus.dart';
import 'package:provider/provider.dart';

import 'package:snag/background_task.dart';
import 'package:snag/common/functions/fetch_body.dart';
import 'package:snag/common/functions/res_map_ajax.dart';
import 'package:snag/common/vars/prefs.dart';
import 'package:snag/nav/custom_back_appbar.dart';
import 'package:snag/provider_models/theme_provider.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});
  static const double paddingHeight = 11.0;
  static bool notificationsDenied = prefs.getBool(PrefsKeys.notificationsDenied.key)!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: const CustomBackAppBar(name: 'Settings'),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: paddingHeight),
          child: ListView(
            children: [
              Consumer<ThemeProvider>(
                builder: (context, theme, child) => Text('Notifications',
                    style: TextStyle(
                        fontSize: 22.0 + theme.fontSize, fontWeight: FontWeight.bold)),
              ),
              notificationsDenied
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: paddingHeight),
                      child: Row(
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
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: paddingHeight),
                          child: Row(
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
                          padding: const EdgeInsets.symmetric(vertical: paddingHeight),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Flexible(
                                child: Text(
                                    "Disable battery optimization for this app, to keep getting notifications even if you don't use the app for a while. Find this app in the All apps list."),
                              ),
                              GestureDetector(
                                onTap: () => const OpenSettingsPlusAndroid()
                                    .ignoreBatteryOptimization(),
                                child: const Padding(
                                  padding: EdgeInsets.only(left: 8.0),
                                  child: Icon(Icons.settings),
                                ),
                              )
                            ],
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: paddingHeight),
                          child: _IntervalWidget(),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: paddingHeight),
                          child: _PointsWidget(),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: paddingHeight),
                          child: _NotificationFrequency(),
                        ),
                      ],
                    ),
              Consumer<ThemeProvider>(
                builder: (context, theme, child) => Text('Sync',
                    style: TextStyle(
                        fontSize: 22.0 + theme.fontSize, fontWeight: FontWeight.bold)),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: paddingHeight),
                child: _SyncWidget(),
              ),
              Consumer<ThemeProvider>(
                builder: (context, theme, child) => Text('Appearance',
                    style: TextStyle(
                        fontSize: 22.0 + theme.fontSize, fontWeight: FontWeight.bold)),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: paddingHeight - 7.0),
                child: _ThemeWidget(),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: paddingHeight),
                child: _FontSizeWidget(),
              ),
              Consumer<ThemeProvider>(
                builder: (context, theme, child) => Text('Deep links',
                    style: TextStyle(
                        fontSize: 22.0 + theme.fontSize, fontWeight: FontWeight.bold)),
              ),
              Padding(
                  padding: const EdgeInsets.symmetric(vertical: paddingHeight),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Flexible(
                        child: Text.rich(TextSpan(
                            text:
                                "To enable opening steamgifts.com links in this app, in the app's ",
                            children: [
                              TextSpan(
                                  text: "Open by default ",
                                  style: TextStyle(fontWeight: FontWeight.bold)),
                              TextSpan(
                                  text:
                                      "menu enable the steamgifts.com domains by tapping on "),
                              TextSpan(
                                text: "+ Add links ",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              TextSpan(text: "and selecting the two domains.")
                            ])),
                      ),
                      GestureDetector(
                        onTap: () => const OpenSettingsPlusAndroid().applicationDetails(),
                        child: const Padding(
                          padding: EdgeInsets.only(left: 8.0),
                          child: Icon(Icons.settings),
                        ),
                      )
                    ],
                  ))
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
      onTap: () => const OpenSettingsPlusAndroid().appNotification(),
      child: const Padding(
        padding: EdgeInsets.only(left: 8.0),
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
  final TextEditingController _pointLimit =
      TextEditingController(text: prefs.getInt(PrefsKeys.pointLimit.key).toString());
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
                onChanged: (value) => _equal = _changed(value,
                    prefs.getInt(PrefsKeys.pointLimit.key).toString(), _equal, setState),
                maxLines: 1,
                decoration: InputDecoration(
                  isDense: true,
                  border: const UnderlineInputBorder(),
                  hintText: 'points',
                  hintStyle: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
                validator: (value) => _limitValidator(value),
                autovalidateMode: AutovalidateMode.always,
              ),
            ),
          ),
          ElevatedButton(onPressed: _equal ? null : _saveLimit, child: const Text('Save'))
        ],
      ),
    );
  }

  void _saveLimit() {
    if (_formKey.currentState!.validate()) {
      prefs.setInt(PrefsKeys.pointLimit.key, int.parse(_pointLimit.text));
      prefs.setBool(PrefsKeys.pointsNotification.key, false);
      backgroundTask();
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

  bool _changed(String value, String? frequency, bool equal, Function callback) {
    equal = true;
    if (value != frequency) {
      equal = false;
    }
    callback(() {});
    return equal;
  }
}

class _CustomSlider extends StatelessWidget {
  const _CustomSlider(
      {required this.currentValue,
      required this.text,
      required this.values,
      required this.onChanged,
      required this.onChangedEnd});

  final double currentValue;
  final String text;
  final List values;
  final ValueChanged<double> onChanged;
  final ValueChanged<double> onChangedEnd;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('$text ${values[currentValue.toInt() - 1].text}'),
        Slider(
          padding: const EdgeInsets.all(16),
          value: currentValue,
          min: 1,
          max: values.length.toDouble(),
          divisions: values.length - 1,
          onChanged: onChanged,
          onChangeEnd: onChangedEnd,
        )
      ],
    );
  }
}

enum _Frequency {
  fifteenM('15 minutes', 15),
  thirtyM('30 minutes', 30),
  fourtyfiveM('45 minutes', 45),
  oneH('1 hour', 60),
  oneHthirtyM('1 hour 30 minutes', 90),
  twoH('2 hours', 120),
  threeH('3 hours', 180),
  fourH('4 hours', 240),
  fiveH('5 hours', 300),
  sixH('6 hours', 360),
  sevenH('7 hours', 420),
  eightH('8 hours', 480),
  nineH('9 hours', 540),
  tenH('10 hours', 600),
  elevenH('11 hours', 660),
  twelveH('12 hours', 720),
  oneD('1 day', 1440),
  twoD('2 days', 2880),
  threeD('3 days', 4320),
  fourD('4 days', 5760),
  fiveD('5 days', 7200),
  sixD('6 days', 8640),
  sevenD('7 days', 10080);

  final String text;
  final int minutes;

  const _Frequency(this.text, this.minutes);
}

class _NotificationFrequency extends StatefulWidget {
  const _NotificationFrequency();

  @override
  State<_NotificationFrequency> createState() => _NotificationFrequencyState();
}

class _NotificationFrequencyState extends State<_NotificationFrequency> {
  double _currentValue = 1;

  @override
  void initState() {
    final int savedValue = prefs.getInt(PrefsKeys.backgroundFrequency.key)!;
    for (int i = 0; i < _Frequency.values.length; i++) {
      //Todo: change to equal in a later version
      if (savedValue <= _Frequency.values[i].minutes) {
        _currentValue = i + 1;
        break;
      }
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _CustomSlider(
        currentValue: _currentValue,
        text: 'Notification frequency:',
        values: _Frequency.values,
        onChanged: (double value) {
          setState(() {
            _currentValue = value.ceilToDouble();
          });
        },
        onChangedEnd: (double value) {
          _currentValue = value.ceilToDouble();
          prefs.setInt(PrefsKeys.backgroundFrequency.key,
              _Frequency.values[_currentValue.toInt() - 1].minutes);
          backgroundTask();
        });
  }
}

enum _Size {
  minusOne('-1', -1),
  zero('0', 0),
  one('+1', 1),
  two('+2', 2),
  three('+3', 3),
  four('+4', 4);

  final String text;
  final int size;

  const _Size(this.text, this.size);
}

class _FontSizeWidget extends StatefulWidget {
  const _FontSizeWidget();

  @override
  State<_FontSizeWidget> createState() => _FontSizeWidgetState();
}

class _FontSizeWidgetState extends State<_FontSizeWidget> {
  double _currentValue = 1;

  @override
  void initState() {
    final int savedValue = prefs.getInt(PrefsKeys.fontSize.key)!;
    for (int i = 0; i < _Size.values.length; i++) {
      if (savedValue == _Size.values[i].size) {
        _currentValue = i + 1;
        break;
      }
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _CustomSlider(
        currentValue: _currentValue,
        text: 'Increase font size by',
        values: _Size.values,
        onChanged: (double value) {
          setState(() {
            _currentValue = value.ceilToDouble();
          });
        },
        onChangedEnd: (double value) {
          _currentValue = value.ceilToDouble();
          int size = _Size.values[_currentValue.toInt() - 1].size;
          prefs.setInt(PrefsKeys.fontSize.key, size);
          context.read<ThemeProvider>().updateFontSize(size);
        });
  }
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
    String data =
        await fetchBody(url: 'https://www.steamgifts.com/account/settings/profile');
    _message =
        parse(data).getElementsByClassName('notification notification')[0].text.trim();
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
              context.read<ThemeProvider>().updateDynamic(_value);
            });
          },
        ),
      ],
    );
  }
}

typedef _MenuEntry = DropdownMenuEntry<_Hours>;

enum _Hours {
  zero('00:00', 0),
  one('01:00', 1),
  two('02:00', 2),
  three('03:00', 3),
  four('04:00', 4),
  five('05:00', 5),
  six('06:00', 6),
  seven('07:00', 7),
  eight('08:00', 8),
  nine('09:00', 9),
  ten('10:00', 10),
  eleven('11:00', 11),
  twelve('12:00', 12),
  thirteen('13:00', 13),
  fourteen('14:00', 14),
  fifteen('15:00', 15),
  sixteen('16:00', 16),
  seventeen('17:00', 17),
  eighteen('18:00', 18),
  nineteen('19:00', 19),
  twenty('20:00', 20),
  twentyone('21:00', 21),
  twentytwo('22:00', 22),
  twentythree('23:00', 23);

  final String name;
  final int hour;
  const _Hours(this.name, this.hour);

  static final List<_MenuEntry> labels = UnmodifiableListView<_MenuEntry>(values
      .map<_MenuEntry>((_Hours entry) => _MenuEntry(value: entry, label: entry.name)));
}

class _IntervalWidget extends StatelessWidget {
  const _IntervalWidget();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 12.0),
          child: Text('Only get notifications between:'),
        ),
        Row(
          children: [
            _CustomDropdownMenu(
                label: 'too late',
                prefsKey: PrefsKeys.intervalStart.key,
                condition: _intervalEnd),
            const Text(' and '),
            _CustomDropdownMenu(
                label: 'too early',
                prefsKey: PrefsKeys.intervalEnd.key,
                condition: _intervalStart),
            const Text(' hours'),
          ],
        )
      ],
    );
  }

  bool _intervalStart(int hour) => prefs.getInt(PrefsKeys.intervalStart.key)! >= hour;

  bool _intervalEnd(int hour) => prefs.getInt(PrefsKeys.intervalEnd.key)! <= hour;
}

class _CustomDropdownMenu extends StatefulWidget {
  const _CustomDropdownMenu(
      {required this.label, required this.prefsKey, required this.condition});

  final String label;
  final String prefsKey;
  final Function condition;

  @override
  State<_CustomDropdownMenu> createState() => __CustomDropdownMenuState();
}

class __CustomDropdownMenuState extends State<_CustomDropdownMenu> {
  String _label = '';
  bool _error = false;
  @override
  Widget build(BuildContext context) {
    return DropdownMenu<_Hours>(
        label: Text(_label, style: const TextStyle(color: Colors.red)),
        inputDecorationTheme: _error
            ? const InputDecorationTheme(
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.red,
                  ),
                ),
              )
            : null,
        width: 130,
        menuHeight: 400,
        initialSelection: _Hours.values[prefs.getInt(widget.prefsKey)!],
        dropdownMenuEntries: _Hours.labels,
        onSelected: (_Hours? entry) {
          if (widget.condition(entry!.hour)) {
            setState(() {
              _label = widget.label;
              _error = true;
            });
          } else {
            prefs.setInt(widget.prefsKey, entry.hour);
            backgroundTask();
            setState(() {
              _label = '';
              _error = false;
            });
          }
        });
  }
}
