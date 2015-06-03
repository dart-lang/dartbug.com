// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library dartbug.com.redirect;

const String gitHub = 'https://github.com';

const String organization = 'dart-lang';

// Test with gcloud while issues are not enabled for sdk.
const String repository = 'sdk';

final RegExp issueRegExp = new RegExp(r'^/([0-9]+)$');
final RegExp newRegExp = new RegExp(r'^/new$', caseSensitive: false);
final RegExp userRegExp = new RegExp(r'^/([A-Za-z]+)$');
final RegExp areaRegExp = new RegExp(r'^/area/([A-Za-z\-]+)$');

final Uri showIssue = Uri.parse('$gitHub/$organization/$repository/issues/');
final Uri newIssue = Uri.parse('$gitHub/$organization/$repository/issues/new');
final Uri userIssues =
    Uri.parse('$gitHub/$organization/$repository/issues/created_by/');
final Uri areaIssues = Uri.parse('$gitHub/$organization/$repository/labels/');
final Uri listIssues = Uri.parse('$gitHub/$organization/$repository/issues');

String checkMatch(  RegExp re, String path) {
  var match = re.firstMatch(path);
  if (match != null) {
    return match.group(match.groupCount);
  } else {
    return null;
  }
}

/// Find the redirect for the supplied [requestUri].
///
/// Returns the [Uri] to redirect to or `null` if no redirect is defined.
Uri findRedirect(Uri requestUri) {
  var path = requestUri.path;
  var match;

  if (requestUri.pathSegments.length == 0) {
    return listIssues;
  }

  match = checkMatch(issueRegExp, path);
  if (match != null) {
    return showIssue.resolve(match);
  }

  match = checkMatch(newRegExp, path);
  if (match != null) {
    return newIssue;
  }

  match = checkMatch(userRegExp, path);
  if (match != null) {
    return userIssues.resolve(match);
  }

  match = checkMatch(areaRegExp, path);
  if (match != null) {
    return areaIssues.resolve(match);
  }

  // No redirect found.
  return null;
}
