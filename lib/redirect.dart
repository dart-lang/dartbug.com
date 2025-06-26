// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

// Environment constants
const gitHub = 'https://github.com';
const organization = 'dart-lang';
const repository = 'sdk';
const _languageRepository = 'language';
const _dartBug = 'https://dartbug.com';

// Redirect URIs
const _rootUri = '$gitHub/$organization/$repository';
final _listIssues = Uri.parse('$_rootUri/issues');
final _showIssue = Uri.parse('$_rootUri/issues/');
final _newIssue = Uri.parse('$_rootUri/issues/new');
final _assignedIssues = Uri.parse('$_rootUri/issues/assigned/');
final _openedIssues = Uri.parse('$_rootUri/issues/created_by/');

const _languageRootUri = '$gitHub/$organization/$_languageRepository';
final _languageListIssues = Uri.parse('$_languageRootUri/issues');
final _languageShowIssue = Uri.parse('$_languageRootUri/issues/');
final _languageNewIssue = Uri.parse('$_languageRootUri/issues/new');
final _languageAssignedIssues = Uri.parse('$_languageRootUri/issues/assigned/');
final _languageOpenedIssues = Uri.parse('$_languageRootUri/issues/created_by/');

Iterable<String> get routes => _matchers.keys.map((r) => r.pattern);

final _matchers = <RegExp, Uri Function(Match)>{
  // Operations that also work on language repo.
  RegExp(r'^/(l(?:anguage)?)$'): (_) => _languageListIssues,
  RegExp(r'^/(l(?:anguage)?/)?([0-9]+)$'): _resolveLastChoose(
    _showIssue,
    _languageShowIssue,
  ),
  RegExp(r'^/(l(?:anguage)?/)?new$', caseSensitive: false): (match) =>
      match[1] == null ? _newIssue : _languageNewIssue,
  RegExp(r'^/(l(?:anguage)?/)?assigned/([A-Za-z0-9\-]+)$'): _resolveLastChoose(
    _assignedIssues,
    _languageAssignedIssues,
  ),
  RegExp(r'^/(l(?:anguage)?/)?opened/([A-Za-z0-9\-]+)$'): _resolveLastChoose(
    _openedIssues,
    _languageOpenedIssues,
  ),
  RegExp(r'^/triage/l(?:anguage)?/?$'): (_) =>
      Uri.parse('$_dartBug/triage/language/issues'),
  RegExp(r'^/triage/l(?:anguage)?/issues?$'): (_) =>
      Uri.parse('$gitHub/issues').replace(
        queryParameters: {
          'q': [
            'is:issue',
            'is:open',
            '-label:bug,request,feature,question',
            'created:>$_dateOneMonth',
            'repo:$organization/$_languageRepository',
          ].join(' '),
        },
      ),
  RegExp(r'^/triage/l(?:anguage)?/prs?$'): (_) =>
      Uri.parse('$gitHub/issues').replace(
        queryParameters: {
          'q': [
            'is:pr',
            'is:open',
            'review:none',
            'draft:false',
            'created:>$_dateOneMonth',
            'repo:$organization/$_languageRepository',
          ].join(' '),
        },
      ),

  // SDK repo only.
  RegExp(r'^/area/([A-Za-z0-9\-]+)$'): (match) => _listIssues.replace(
    queryParameters: {
      'q': ['label:area-${match[1]}'].join(' '),
    },
  ),

  // sdk triage
  RegExp(r'^/triage$'): (_) => Uri.parse('$_dartBug/triage/sdk'),
  RegExp(r'^/triage/sdk$', caseSensitive: false): (_) => _listIssues.replace(
    queryParameters: {
      'q': [
        'is:issue',
        'is:open',
        '-label:${_areaLabels.map(_quoteSpaces).join(',')}',
      ].join(' '),
    },
  ),

  // core packages triage
  RegExp(r'^/c(?:ore)?/?$'): (_) => Uri.parse('$gitHub/$organization/core'),
  RegExp(r'^/triage/core$'): (_) => Uri.parse('$_dartBug/triage/core/issues'),
  // Issues opened in the last 30 days not marked as bugs or enhancements.
  RegExp(r'^/triage/core/issues$'): (_) => Uri.parse('$gitHub/issues').replace(
    queryParameters: {
      'q': [
        'is:issue',
        'is:open',
        '-label:bug,enhancement,type-enhancement,documentation',
        'created:>$_dateOneMonth',
        ..._corePackages.map((repo) => 'repo:$repo'),
      ].join(' '),
    },
  ),
  // PRs opened in the last 30 days that haven't been assigned a reviewer and
  // that aren't draft PRs.
  RegExp(r'^/triage/core/prs$'): (_) => Uri.parse('$gitHub/issues').replace(
    queryParameters: {
      'q': [
        'is:pr',
        'is:open',
        'review:none',
        'draft:false',
        'created:>$_dateOneMonth',
        ..._corePackages.map((repo) => 'repo:$repo'),
      ].join(' '),
    },
  ),

  RegExp(r'^/t(?:ools)?/?$'): (_) => Uri.parse('$gitHub$organization/tools'),
  // tools packages triage
  RegExp(r'^/triage/tools$'): (_) => Uri.parse('$_dartBug/triage/tools/issues'),
  // Issues opened in the last 30 days not marked as bugs or enhancements.
  RegExp(r'^/triage/tools/issues$'): (_) => Uri.parse('$gitHub/issues').replace(
    queryParameters: {
      'q': [
        'is:issue',
        'is:open',
        '-label:bug,enhancement,type-enhancement,documentation',
        'created:>$_dateOneMonth',
        ..._toolsPackages.map((repo) => 'repo:$repo'),
      ].join(' '),
    },
  ),
  // PRs opened in the last 30 days that haven't been assigned a reviewer and
  // that aren't draft PRs.
  RegExp(r'^/triage/tools/prs$'): (_) => Uri.parse('$gitHub/issues').replace(
    queryParameters: {
      'q': [
        'is:pr',
        'is:open',
        'review:none',
        'draft:false',
        'created:>$_dateOneMonth',
        ..._toolsPackages.map((repo) => 'repo:$repo'),
      ].join(' '),
    },
  ),
};

/// Resolves one of [base1] or [base2] against the last capture of `match`.
///
/// Chooses [base1] if the first capture (`match[1]`) is `null`,
/// and [base2] otherwise.
/// (The former is an SDK repo base, the latter a language repo base.)
Uri Function(Match) _resolveLastChoose(Uri base1, Uri base2) =>
    (Match match) =>
        ((match[1] == null) ? base1 : base2).resolve(match[match.groupCount]!);

final List<String> _areaLabels = [
  for (var (label as String)
      in jsonDecode(File('static/sdk_labels.json').readAsStringSync()) as List)
    if (label.startsWith('area-') || label.startsWith('legacy-area-')) label,
];

final List<String> _corePackages = _parsePackageInfo(
  File('static/core_packages.csv'),
);
final List<String> _toolsPackages = _parsePackageInfo(
  File('static/tools_packages.csv'),
);

/// Find the redirect for the supplied [requestUri].
///
/// Returns the [Uri] to redirect to or `null` if no redirect is defined.
Uri? findRedirect(Uri requestUri) {
  if (requestUri.pathSegments.isEmpty) {
    return _listIssues;
  }

  for (var entry in _matchers.entries) {
    final match = entry.key.firstMatch(requestUri.path);
    if (match != null) {
      return entry.value(match);
    }
  }

  // No redirect found.
  return null;
}

/// Parse a csv file with package information; return a list of repositories
/// that we're interested in triaging.
List<String> _parsePackageInfo(File file) =>
    file
        .readAsLinesSync()
        .where((line) => line.isNotEmpty && !line.startsWith('#'))
        .map((String line) {
          // "args,dart-lang/args,dart.dev"
          final info = line.split(',');
          return info[1];
        })
        .where((repo) => repo != 'dart-lang/sdk')
        .toSet()
        .toList()
      ..sort();

/// Return the current date, less ~1 month, in '2022-01-15' format.
String get _dateOneMonth {
  final date = DateTime.now().subtract(const Duration(days: 30));
  return '${date.year}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}

String _quoteSpaces(String label) => label.contains(' ') ? '"$label"' : label;
