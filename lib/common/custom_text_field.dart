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

InputDecoration _customDecoration(String hintText) {
  return InputDecoration(
    isDense: true,
    border: const UnderlineInputBorder(),
    hintText: hintText,
    hintStyle: TextStyle(fontSize: 12, color: Colors.grey[500]),
  );
}

class CustomTextFormField extends StatelessWidget {
  const CustomTextFormField(
      {required this.hintText,
      required this.controller,
      required this.validator,
      required this.type,
      this.compareController,
      this.minNumber,
      this.maxNumber,
      this.textCapitalization = TextCapitalization.none,
      super.key});

  final String hintText;
  final TextEditingController controller;
  final Function validator;
  final TextInputType type;
  final TextEditingController? compareController;
  final int? minNumber;
  final int? maxNumber;
  final TextCapitalization textCapitalization;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: TextFormField(
        autovalidateMode: AutovalidateMode.always,
        validator: (value) => minNumber != null
            ? validator(value, compareController, minNumber, maxNumber)
            : compareController != null
                ? validator(value, compareController)
                : validator(value),
        controller: controller,
        keyboardType: type,
        textCapitalization: textCapitalization,
        maxLines: 1,
        textAlign: TextAlign.center,
        decoration: _customDecoration(hintText),
      ),
    );
  }
}

String? textValidator(String? value) {
  return null;
}
