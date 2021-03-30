// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

import 'utils.dart';

// Environment constants
const gitHub = 'https://github.com';
const organization = 'dart-lang';
const repository = 'sdk';

// Redirect URIs
const _rootUri = '$gitHub/$organization/$repository';
final _listIssues = Uri.parse('$_rootUri/issues');
final _showIssue = Uri.parse('$_rootUri/issues/');
final _newIssue = Uri.parse('$_rootUri/issues/new');
final _assignedIssues = Uri.parse('$_rootUri/issues/assigned/');
final _openedIssues = Uri.parse('$_rootUri/issues/created_by/');

Iterable<String> get routes => _matchers.keys.map((r) => r.pattern);

final _matchers = <RegExp, Uri Function(String)>{
  RegExp(r'^/([0-9]+)$'): _showIssue.resolve,
  RegExp(r'^/new$', caseSensitive: false): (_) => _newIssue,
  RegExp(r'^/assigned/([A-Za-z0-9\-]+)$'): _assignedIssues.resolve,
  RegExp(r'^/opened/([A-Za-z0-9\-]+)$'): _openedIssues.resolve,
  RegExp(r'^/area/([A-Za-z0-9\-]+)$'): (match) => _listIssues.replace(
        queryParameters: {
          'q': [
            'label:area-$match',
          ].join(' '),
        },
      ),
  RegExp(r'^/triage$', caseSensitive: false): (_) => _listIssues.replace(
        queryParameters: {
          'q': [
            'is:issue',
            'is:open',
            ..._areaLabels.map((label) => '-label:$label'),
          ].join(' '),
        },
      )
};

String? _checkMatch(RegExp re, String path) {
  final match = re.firstMatch(path);
  if (match != null) {
    return match.group(match.groupCount)!;
  } else {
    return null;
  }
}

late final List<String> _areaLabels = List<String>.from(
  jsonDecode(
    File(fixPath('lib/sdk_labels.json')).readAsStringSync(),
  ) as List,
)..removeWhere((label) => !label.startsWith('area-'));

/// Find the redirect for the supplied [requestUri].
///
/// Returns the [Uri] to redirect to or `null` if no redirect is defined.
Uri? findRedirect(Uri requestUri) {
  if (requestUri.pathSegments.isEmpty) {
    return _listIssues;
  }

  for (var entry in _matchers.entries) {
    final match = _checkMatch(entry.key, requestUri.path);
    if (match != null) {
      return entry.value(match);
    }
  }

  // No redirect found.
  return null;
}
