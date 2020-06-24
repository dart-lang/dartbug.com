// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

String fixPath(String targetPath) => [
      if (kEntries.isNotEmpty) '/app/',
      targetPath,
    ].join('/');

final kEntries = Platform.environment.entries
    .where((e) => e.key.startsWith('K_'))
    .map((e) => '${e.key}\t${e.value}')
    .toList();
