// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:dartbug/server.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';

Future main() async {
  // Find port to listen on from environment variable.
  var port = int.tryParse(Platform.environment['PORT'] ?? '8080');

  var pipeline = const Pipeline();

  final kEntries = Platform.environment.entries
      .where((e) => e.key.startsWith('K_'))
      .map((e) => '${e.key}\t${e.value}')
      .toList();

  InternetAddress listenAddress;

  if (kEntries.isNotEmpty) {
    print('Assuming environment is Cloud Run\n${kEntries.join('\n')}');
    listenAddress = InternetAddress.anyIPv4;
  } else {
    // Only add log middleware if we're not on Cloud Run
    pipeline = pipeline.addMiddleware(logRequests());
    listenAddress = InternetAddress.loopbackIPv4;
  }

  // Serve handler on given port.
  var server = await serve(
    pipeline.addHandler(handler),
    listenAddress,
    port,
  );
  print('Serving at http://${server.address.host}:${server.port}');
}
