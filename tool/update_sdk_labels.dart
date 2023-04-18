// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

import 'package:github/github.dart';

Future<void> main() async {
  final gitHub = GitHub();

  try {
    final sdkLabelRequest =
        gitHub.issues.listLabels(RepositorySlug('dart-lang', 'sdk'));
    final labelNames = [await for (var label in sdkLabelRequest) label.name];

    File('static/sdk_labels.json').writeAsStringSync(
      '${const JsonEncoder.withIndent(' ').convert(labelNames)}\n',
    );
  } finally {
    gitHub.dispose();
  }
}
