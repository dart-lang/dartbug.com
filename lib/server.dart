import 'dart:collection';
import 'dart:convert';

import 'package:shelf/shelf.dart';

import 'redirect.dart';

int _infoRequests = 0;
int _redirects = 0;
int _notFound = 0;
final _stopwatch = Stopwatch();

Handler get handler {
  _stopwatch.start();
  return _handler;
}

Response _handler(Request request) {
  _stopwatch.start();

  if (request.requestedUri.pathSegments.length == 1 &&
      request.requestedUri.pathSegments.single == '\$info') {
    _infoRequests++;

    var data = {
      'since boot': _stopwatch.elapsed.toString(),
      'redirects': _redirects,
      'notFounds': _notFound,
      'info': _infoRequests,
      'request headers': SplayTreeMap.of(request.headers),
    };

    return Response.ok(const JsonEncoder.withIndent(' ').convert(data),
        headers: {'Content-Type': 'application/json'});
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
""");
  }
}
