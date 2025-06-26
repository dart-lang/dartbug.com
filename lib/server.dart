// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:google_cloud/google_cloud.dart';
import 'package:shelf/shelf.dart';

import 'redirect.dart';

int _infoRequests = 0;
int _redirects = 0;
int _notFound = 0;
int _robotTxt = 0;
final _stopwatch = Stopwatch();
final _agents = SplayTreeMap<String, int>(compareAsciiLowerCase);

Handler get handler {
  _stopwatch.start();
  return _handler;
}

Response _handler(Request request) {
  final agent = request.headers['user-agent'];
  if (agent != null) {
    _agents[agent] = (_agents[agent] ?? 0) + 1;
  }

  if (request.requestedUri.pathSegments.length == 1) {
    switch (request.requestedUri.pathSegments.single) {
      case 'robots.txt':
        _robotTxt++;
        return Response.ok(r'''
User-agent: *
Allow: /
''');
      case '\$info':
        _infoRequests++;

        final data = {
          'since boot': _stopwatch.elapsed.toString(),
          'counts': {
            'redirects': _redirects,
            'notFounds': _notFound,
            'info': _infoRequests,
            'robot.txt': _robotTxt,
          },
          'Dart version': Platform.version,
          'request headers': SplayTreeMap.of(
            request.headers,
            compareAsciiLowerCase,
          ),
          'Environment': SplayTreeMap.of(
            Platform.environment,
            compareAsciiLowerCase,
          ),
          'agents': _agents,
        };

        return Response.ok(
          const JsonEncoder.withIndent(' ').convert(data),
          headers: {'Content-Type': 'application/json'},
        );
      case 'favicon.ico':
        return Response.ok(
          File('static/favicon.ico').readAsBytesSync(),
          headers: {'Content-Type': 'image/x-icon'},
        );
    }
  }

  final location = findRedirect(request.requestedUri);
  if (location != null) {
    _redirects++;
    // Issue a 302 / Found ('Moved temporarily') redirect.
    return Response.found(location);
  } else {
    _notFound++;
    throw BadRequestException(404, """
I don't support redirecting path '${request.requestedUri.path}'

Check out my source at https://github.com/dart-lang/dartbug.com

Supported routes:
${routes.map((r) => '  $r').join('\n')}
""");
  }
}
