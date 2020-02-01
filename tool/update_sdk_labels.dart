// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

import 'package:github/github.dart';

Future main() async {
  final gitHub = GitHub();

  try {
    final labels = await gitHub.issues
        .listLabels(RepositorySlug('dart-lang', 'sdk'))
        .toList();

    final labelValues = labels.map((label) => label.name).toList();

    File('lib/sdk_labels.json').writeAsStringSync(
        const JsonEncoder.withIndent(' ').convert(labelValues));
  } finally {
    gitHub.dispose();
  }
}
