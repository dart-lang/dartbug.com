// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library dartbug.com.redirect;

const String gitHub = 'https://github.com';

const String orginization = 'dart-lang';

// Test with gcloud while issues are not enabled for sdk.
const String repository = 'gcloud';


final Uri showIssue = Uri.parse('$gitHub/$orginization/$repository/issues/');
final Uri newIssue = Uri.parse('$gitHub/$orginization/$repository/issues/new');
final Uri listIssues = Uri.parse('$gitHub/$orginization/$repository/issues');

/// Find the redirect for the supplied [requestUri].
///
/// Returns the [Uri] to redirect to or `null` if no redirect is defined.
Uri findRedirect(Uri requestUri) {
  if (requestUri.pathSegments.length == 1) {
    var issue = int.parse(requestUri.pathSegments[0],
                          onError: (source) => null);
    if (issue != null && issue > 0) {
      return showIssue.resolve('$issue');
    }

    if (requestUri.pathSegments[0] == 'new') {
      return newIssue;
    }
  } else if (requestUri.pathSegments.length == 0) {
    return listIssues;
  }

  // No redirect found.
  return null;
}
