// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:appengine/appengine.dart';
import 'package:dartbug/redirect.dart';

void main() {
  runAppEngine((HttpRequest request) {
    var location = findRedirect(request.uri);
    if (location != null) {
      request.response
        ..redirect(location)
        ..close();
    } else {
      request.response
        ..statusCode = HttpStatus.notFound
        ..close();
    }
  });
}
