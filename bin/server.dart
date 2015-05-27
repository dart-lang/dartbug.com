// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:appengine/appengine.dart';

import 'package:dartbug.com/redirect.dart';

main() {
  runAppEngine((HttpRequest request) {
    Uri location = findRedirect(request.uri);
    if (location != null) {
      request.response
        ..redirect(location)
        ..close();
    } else {
      request.response
        ..statusCode = HttpStatus.NOT_FOUND
        ..close();
    }
  });
}
