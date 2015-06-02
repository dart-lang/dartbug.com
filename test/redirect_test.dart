// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:unittest/unittest.dart';

import 'package:dartbug.com/redirect.dart';

main() {
  test('issue number', () {
    expect(findRedirect(Uri.parse('http://dartbug.com/1234')).toString(),
           '$gitHub/$organization/$repository/issues/1234');
    expect(findRedirect(Uri.parse('http://dartbug.com/-1234')),
           isNull);
  });

  test('new issue', () {
    expect(findRedirect(Uri.parse('http://dartbug.com/new')).toString(),
           '$gitHub/$organization/$repository/issues/new');
    expect(findRedirect(Uri.parse('http://dartbug.com/NEW')).toString(),
           '$gitHub/$organization/$repository/issues/new');
  });

  test('user issue', () {
    expect(findRedirect(Uri.parse('http://dartbug.com/user')).toString(),
           '$gitHub/$organization/$repository/issues/created_by/user');
    expect(findRedirect(Uri.parse('http://dartbug.com/søren')),
           isNull);
  });

  test('list issues', () {
    expect(findRedirect(Uri.parse('http://dartbug.com')).toString(),
           '$gitHub/$organization/$repository/issues');
    expect(findRedirect(Uri.parse('http://dartbug.com/')).toString(),
           '$gitHub/$organization/$repository/issues');
  });


  test('area', () {
    expect(
        findRedirect(Uri.parse('http://dartbug.com/area/Area-VM')).toString(),
        '$gitHub/$organization/$repository/labels/Area-VM');
  });
}