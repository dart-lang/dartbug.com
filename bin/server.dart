// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:dartbug/server.dart';
import 'package:dartbug/utils.dart';
import 'package:shelf/shelf.dart';

Future<void> main() async {
  var pipeline = const Pipeline();

  if (kEntries.isNotEmpty) {
    print('Assuming environment is Cloud Run\n${kEntries.join('\n')}');
  } else {
    // Only add log middleware if we're not on Cloud Run
    pipeline = pipeline.addMiddleware(logRequests());
  }

  await serveHandler(handler);
}
