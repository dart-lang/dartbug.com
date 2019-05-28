Simple redirector to the Dart issue tracker.

    http://dartbug.com                      --> issues list
    http://dartbug.com/new                  --> new issue template
    http://dartbug.com/<number>             --> specific issue
    http://dartbug.com/opened/<user-id>     --> issues opened by github user <user-id>
    http://dartbug.com/assigned/<user-id>   --> issues assigned to github user <user-id>
    http://dartbug.com/area/<area>          --> issues in <area> (i.e., tagged with label 'area-<area>')
    http://dartbug.com/triage               --> issues in the Dart SDK without an `area-<area>` label assigned

See the LICENSE file.

## To Deploy

Following instructions at https://cloud.google.com/run/docs/quickstarts/build-and-deploy

### Build the container

```console
$ gcloud builds submit --project dart-redirector --tag gcr.io/dart-redirector/app
```

### Deploy

```console
$ gcloud beta run deploy --project dart-redirector --image gcr.io/dart-redirector/app
```

## To update SDK Triage areas

```console
$ dart tool/update_sdk_labels.dart
```
