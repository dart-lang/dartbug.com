// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:dartbug/server.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';

Future main() async {
  var server = await serve(
      const Pipeline().addMiddleware(logRequests()).addHandler(handler),
      InternetAddress.loopbackIPv4,
      8080);
  print('Listening on ${server.address.address}:${server.port}');
}
