// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:dartbug/server.dart';
import 'package:gcp/gcp.dart';
import 'package:shelf/shelf.dart';

Future<void> main() async {
  String? projectId;
  try {
    projectId = await projectIdFromMetadataServer();
    currentLogger.debug('Running on Google cloud! Project ID: $projectId');
  } on BadConfigurationException {
    // NOOP - not on cloud!
    currentLogger.debug('Not running on Google Cloud.');
  }

  await serveHandler(
    createLoggingMiddleware(projectId: projectId).addHandler(handler),
  );
}
