// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

// Environment constants
const gitHub = 'https://github.com';
const organization = 'dart-lang';
const repository = 'sdk';

// Regular expressions for matching the request URI
final issueRegExp = RegExp(r'^/([0-9]+)$');
final newRegExp = RegExp(r'^/new$', caseSensitive: false);
final assignedRegExp = RegExp(r'^/assigned/([A-Za-z0-9\-]+)$');
final openedRegExp = RegExp(r'^/opened/([A-Za-z0-9\-]+)$');
final areaRegExp = RegExp(r'^/area/([A-Za-z0-9\-]+)$');
final triageRegExp = RegExp(r'^/triage$', caseSensitive: false);

// Redirect URIs
final _rootUri = '$gitHub/$organization/$repository';
final _listIssues = Uri.parse('$_rootUri/issues');
final _showIssue = Uri.parse('$_rootUri/issues/');
final _newIssue = Uri.parse('$_rootUri/issues/new');
final _assignedIssues = Uri.parse('$_rootUri/issues/assigned/');
final _openedIssues = Uri.parse('$_rootUri/issues/created_by/');

String _checkMatch(RegExp re, String path) {
  var match = re.firstMatch(path);
  if (match != null) {
    return match.group(match.groupCount);
  } else {
    return null;
  }
}

List<String> _areaLabelCache;

List<String> get _areaLabels => _areaLabelCache ??= List<String>.from(
    jsonDecode(File('lib/sdk_labels.json').readAsStringSync()) as List)
  ..removeWhere((label) => !label.startsWith('area-'));

/// Find the redirect for the supplied [requestUri].
///
/// Returns the [Uri] to redirect to or `null` if no redirect is defined.
Uri findRedirect(Uri requestUri) {
  var path = requestUri.path;
  String match;

  if (requestUri.pathSegments.isEmpty) {
    return _listIssues;
  }

  match = _checkMatch(issueRegExp, path);
  if (match != null) {
    return _showIssue.resolve(match);
  }

  match = _checkMatch(newRegExp, path);
  if (match != null) {
    return _newIssue;
  }

  match = _checkMatch(assignedRegExp, path);
  if (match != null) {
    return _assignedIssues.resolve(match);
  }

  match = _checkMatch(openedRegExp, path);
  if (match != null) {
    return _openedIssues.resolve(match);
  }

  match = _checkMatch(areaRegExp, path);
  if (match != null) {
    return _listIssues.replace(
      queryParameters: {
        'label': 'area-$match',
      },
    );
  }

  match = _checkMatch(triageRegExp, path);
  if (match != null) {
    return _listIssues.replace(
      queryParameters: {
        'q': [
          'is:issue',
          'is:open',
          ..._areaLabels.map((label) => '-label:$label'),
        ].join(' '),
      },
    );
  }

  // No redirect found.
  return null;
}
