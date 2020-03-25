// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';

import 'redirect.dart';

int _infoRequests = 0;
int _redirects = 0;
int _notFound = 0;
int _robotTxt = 0;
final _stopwatch = Stopwatch();

Handler get handler {
  _stopwatch.start();
  return _handler;
}

Response _handler(Request request) {
  _stopwatch.start();

  if (request.requestedUri.pathSegments.length == 1) {
    switch (request.requestedUri.pathSegments.single) {
      case 'robots.txt':
        _robotTxt++;
        return Response.ok(
          r'''
User-agent: *
Disallow: /
''',
        );
      case '\$info':
        _infoRequests++;

        var data = {
          'since boot': _stopwatch.elapsed.toString(),
          'redirects': _redirects,
          'notFounds': _notFound,
          'info': _infoRequests,
          'robot.txt': _robotTxt,
          'Dart version': Platform.version,
          'request headers': SplayTreeMap.of(request.headers),
        };

        return Response.ok(
          const JsonEncoder.withIndent(' ').convert(data),
          headers: {'Content-Type': 'application/json'},
        );
      case 'favicon.ico':
        return Response.ok(
          File('/app/static/favicon.ico').readAsBytesSync(),
          headers: {'Content-Type': 'image/x-icon'},
        );
    }
  }

  var location = findRedirect(request.requestedUri);
  if (location != null) {
    _redirects++;
    return Response.found(location);
  } else {
    _notFound++;
    return Response.notFound("""
I don't support redirecting path '${request.requestedUri.path}'

Check out my source at https://github.com/dart-lang/dartbug.com

Supported routes:
${routes.map((r) => '  $r').join('\n')}
""");
  }
}
