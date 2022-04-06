// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

// ignore_for_file: prefer_expression_function_bodies

// Environment constants
const gitHub = 'https://github.com';
const organization = 'dart-lang';
const repository = 'sdk';
const dartBug = 'https://dartbug.com';

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
  RegExp(r'^/area/([A-Za-z0-9\-]+)$'): (match) {
    return _listIssues.replace(
      queryParameters: {
        'q': [
          'label:area-$match',
        ].join(' '),
      },
    );
  },

  // sdk triage
  RegExp(r'^/triage$'): (_) => Uri.parse('$dartBug/triage/sdk'),
  RegExp(r'^/triage/sdk$', caseSensitive: false): (_) {
    return _listIssues.replace(
      queryParameters: {
        'q': [
          'is:issue',
          'is:open',
          ..._areaLabels.map((label) => '-label:$label'),
        ].join(' '),
      },
    );
  },

  // core packages triage
  RegExp(r'^/triage/core$'): (_) => Uri.parse('$dartBug/triage/core/issues'),
  RegExp(r'^/triage/core/issues$'): (_) {
    return Uri.parse('$gitHub/issues').replace(
      queryParameters: {
        'q': [
          'is:issue',
          'is:open',
          '-label:bug',
          '-label:enhancement',
          'created:>$dateOneMonth',
          ...corePackages.map((repo) => 'repo:$repo'),
        ].join(' '),
      },
    );
  },
  RegExp(r'^/triage/core/prs$'): (_) {
    // TODO: This returns all open PRs; we need to determine what an inbox query
    // looks like for PRs (new PRs? New and 'needs-attention'?).
    return Uri.parse('$gitHub/issues').replace(
      queryParameters: {
        'q': [
          'is:pr',
          'is:open',
          // 'created:>$dateOneMonth',
          // '-label:bug',
          // '-label:enhancement',
          ...corePackages.map((repo) => 'repo:$repo'),
        ].join(' '),
      },
    );
  },

  // tools packages triage
  RegExp(r'^/triage/tools$'): (_) => Uri.parse('$dartBug/triage/tools/issues'),
  RegExp(r'^/triage/tools/issues$'): (_) {
    return Uri.parse('$gitHub/issues').replace(
      queryParameters: {
        'q': [
          'is:issue',
          'is:open',
          '-label:bug',
          '-label:enhancement',
          'created:>$dateOneMonth',
          ...toolsPackages.map((repo) => 'repo:$repo'),
        ].join(' '),
      },
    );
  },
  RegExp(r'^/triage/tools/prs$'): (_) {
    // TODO: This returns all open PRs; we need to determine what an inbox query
    // looks like for PRs (new PRs? New and 'needs-attention'?).
    return Uri.parse('$gitHub/issues').replace(
      queryParameters: {
        'q': [
          'is:pr',
          'is:open',
          // 'created:>$dateOneMonth',
          // '-label:bug',
          // '-label:enhancement',
          ...toolsPackages.map((repo) => 'repo:$repo'),
        ].join(' '),
      },
    );
  },
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
    File('static/sdk_labels.json').readAsStringSync(),
  ) as List,
)..removeWhere((label) => !label.startsWith('area-'));

late final List<String> corePackages =
    parsePackageInfo(File('static/core_packages.csv'));
late final List<String> toolsPackages =
    parsePackageInfo(File('static/tools_packages.csv'));

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

/// Parse a csv file with package information; return a list of repositories
/// that we're interested in triaging.
List<String> parsePackageInfo(File file) {
  return file
      .readAsLinesSync()
      .where((line) => line.isNotEmpty)
      .where((line) => !line.startsWith('#'))
      .map((String line) {
        // "args,dart-lang/args,dart.dev"
        final info = line.split(',');
        return PackageInfo(info[0], info[1]);
      })
      .where((package) => package.repo != 'dart-lang/sdk')
      .map((package) => package.repo)
      .toSet()
      .toList()
    ..sort();
}

class PackageInfo {
  final String name;
  final String repo;

  PackageInfo(this.name, this.repo);
}

/// Return the current date, less ~1 month, in '2022-01-15' format.
String get dateOneMonth {
  final date = DateTime.now().subtract(const Duration(days: 30));
  return '${date.year}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}
