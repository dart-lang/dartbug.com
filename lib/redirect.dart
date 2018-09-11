// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Environment constants
const String gitHub = 'https://github.com';
const String organization = 'dart-lang';
const String repository = 'sdk';

// Regular expressions for matching the request URI
final RegExp issueRegExp = new RegExp(r'^/([0-9]+)$');
final RegExp newRegExp = new RegExp(r'^/new$', caseSensitive: false);
final RegExp assignedRegExp = new RegExp(r'^/assigned/([A-Za-z\-]+)$');
final RegExp openedRegExp = new RegExp(r'^/opened/([A-Za-z\-]+)$');
final RegExp areaRegExp = new RegExp(r'^/area/([A-Za-z\-]+)$');

// Redirect URIs
final String rootUri = '$gitHub/$organization/$repository';
final Uri listIssues = Uri.parse('$rootUri/issues');
final Uri showIssue = Uri.parse('$rootUri/issues/');
final Uri newIssue = Uri.parse('$rootUri/issues/new');
final Uri assignedIssues = Uri.parse('$rootUri/issues/assigned/');
final Uri openedIssues = Uri.parse('$rootUri/issues/created_by/');

String checkMatch(RegExp re, String path) {
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
  String match;

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

  match = checkMatch(assignedRegExp, path);
  if (match != null) {
    return assignedIssues.resolve(match);
  }

  match = checkMatch(openedRegExp, path);
  if (match != null) {
    return openedIssues.resolve(match);
  }

  match = checkMatch(areaRegExp, path);
  if (match != null) {
    return listIssues.replace(queryParameters: {'label': 'area-$match'});
  }

  // No redirect found.
  return null;
}
