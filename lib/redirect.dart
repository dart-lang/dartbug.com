// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library dartbug.com.redirect;

const String gitHub = 'https://github.com';

const String orginization = 'dart-lang';

// Test with gcloud while issues are not enabled for sdk.
const String repository = 'gcloud';

final RegExp userRegExp = new RegExp(r'[A-Za-z]+');

final Uri showIssue = Uri.parse('$gitHub/$orginization/$repository/issues/');
final Uri newIssue = Uri.parse('$gitHub/$orginization/$repository/issues/new');
final Uri userIssues =
    Uri.parse('$gitHub/$orginization/$repository/issues/created_by/');
final Uri listIssues = Uri.parse('$gitHub/$orginization/$repository/issues');

/// Find the redirect for the supplied [requestUri].
///
/// Returns the [Uri] to redirect to or `null` if no redirect is defined.
Uri findRedirect(Uri requestUri) {
  if (requestUri.pathSegments.length == 1) {
    var segment = requestUri.pathSegments[0];
    var issue = int.parse(segment, onError: (source) => null);
    if (issue != null && issue > 0) {
      return showIssue.resolve('$issue');
    }

    if (segment.toLowerCase() == 'new') {
      return newIssue;
    }

    var userMatch = userRegExp.firstMatch(segment);
    if (userMatch != null &&
        userMatch.start == 0 && userMatch.end == segment.length) {
      return userIssues.resolve(segment);
    }
  } else if (requestUri.pathSegments.length == 0) {
    return listIssues;
  }

  // No redirect found.
  return null;
}
