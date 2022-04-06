// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartbug/redirect.dart';
import 'package:test/test.dart';

void main() {
  test('issue number', () {
    expect(
      findRedirect(Uri.parse('http://dartbug.com/1234')).toString(),
      '$gitHub/$organization/$repository/issues/1234',
    );
    expect(
      findRedirect(Uri.parse('http://dartbug.com/-1234')),
      isNull,
    );
  });

  test('new issue', () {
    expect(
      findRedirect(Uri.parse('http://dartbug.com/new')).toString(),
      '$gitHub/$organization/$repository/issues/new',
    );
    expect(
      findRedirect(Uri.parse('http://dartbug.com/NEW')).toString(),
      '$gitHub/$organization/$repository/issues/new',
    );
  });

  test('assigned issue', () {
    expect(
      findRedirect(Uri.parse('http://dartbug.com/assigned/kevmoo')).toString(),
      '$gitHub/$organization/$repository/issues/assigned/kevmoo',
    );
    expect(
      findRedirect(Uri.parse('http://dartbug.com/assigned/nex3')).toString(),
      '$gitHub/$organization/$repository/issues/assigned/nex3',
    );
    expect(
      findRedirect(Uri.parse('http://dartbug.com/søren')),
      isNull,
    );
  });

  test('list issues', () {
    expect(
      findRedirect(Uri.parse('http://dartbug.com')).toString(),
      '$gitHub/$organization/$repository/issues',
    );
    expect(
      findRedirect(Uri.parse('http://dartbug.com/')).toString(),
      '$gitHub/$organization/$repository/issues',
    );
  });

  test('area', () {
    expect(
      findRedirect(Uri.parse('http://dartbug.com/area/Area-VM')).toString(),
      '$gitHub/$organization/$repository/issues?q=label%3Aarea-Area-VM',
    );
    expect(
      findRedirect(Uri.parse('http://dartbug.com/area/dart2js')).toString(),
      '$gitHub/$organization/$repository/issues?q=label%3Aarea-dart2js',
    );
  });

  group('sdk', () {
    test('triage', () {
      expect(
        findRedirect(Uri.parse('http://dartbug.com/triage')).toString(),
        equalsIgnoringCase('https://dartbug.com/triage/sdk'),
      );
    });

    test('triage/sdk', () {
      expect(
        findRedirect(Uri.parse('https://dartbug.com/triage/sdk')).toString(),
        startsWith(
          'https://github.com/dart-lang/sdk/issues?'
          'q=is%3Aissue+is%3Aopen+-label%3Aarea-analyzer',
        ),
      );
    });
  });

  group('core packages', () {
    test('triage/core', () {
      expect(
        findRedirect(Uri.parse('http://dartbug.com/triage/core')).toString(),
        equalsIgnoringCase('https://dartbug.com/triage/core/issues'),
      );
    });

    test('triage/core/issues', () {
      expect(
        findRedirect(Uri.parse('https://dartbug.com/triage/core/issues'))
            .toString(),
        startsWith(
          'https://github.com/issues?q=is%3Aissue+is%3Aopen+-label%3Abug'
          '+-label%3Aenhancement+created',
        ),
      );
    });

    test('triage/core/prs', () {
      expect(
        findRedirect(Uri.parse('https://dartbug.com/triage/core/prs'))
            .toString(),
        startsWith(
          'https://github.com/issues?q=is%3Apr+is%3Aopen'
          '+review%3Anone+-draft%3Atrue+created',
        ),
      );
    });
  });
}
