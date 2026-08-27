// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';

import 'package:dartbug/server.dart';
import 'package:shelf/shelf.dart';
import 'package:test/test.dart';

void main() {
  test('robots.txt', () async {
    final response = await handler(
      Request('GET', Uri.parse('http://dartbug.com/robots.txt')),
    );
    expect(response.statusCode, 200);
    expect(await response.readAsString(), contains('User-agent: *'));
  });

  test(r'$info', () async {
    final response = await handler(
      Request(
        'GET',
        Uri.parse(r'http://dartbug.com/$info'),
        headers: {'User-Agent': 'test-agent/1.0'},
      ),
    );
    expect(response.statusCode, 200);
    expect(response.headers['content-type'], 'application/json');

    final body =
        jsonDecode(await response.readAsString()) as Map<String, dynamic>;
    expect(body, contains('since boot'));
    expect(body, contains('counts'));
    expect(body, contains('Dart version'));
    expect(body, contains('request headers'));

    expect(body.containsKey('Environment'), isFalse);
    expect(body.containsKey('agents'), isFalse);
  });

  test('valid redirect', () async {
    final response = await handler(
      Request('GET', Uri.parse('http://dartbug.com/1234')),
    );
    expect(response.statusCode, 302);
    expect(
      response.headers['location'],
      'https://github.com/dart-lang/sdk/issues/1234',
    );
  });
}
