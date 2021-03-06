Simple redirector to the Dart issue tracker.

    dartbug.com                      --> issues list
    dartbug.com/new                  --> new issue template
    dartbug.com/<number>             --> specific issue
    dartbug.com/opened/<user-id>     --> issues opened by github user <user-id>
    dartbug.com/assigned/<user-id>   --> issues assigned to github user <user-id>
    dartbug.com/area/<area>          --> issues in <area> (i.e., tagged with label 'area-<area>')
    dartbug.com/triage               --> issues in the Dart SDK without an `area-<area>` label assigned

See the [LICENSE](LICENSE) file.

## Continuous deployment from Git using Cloud Build

The `dart-redirector` project is configured to deploy this application on every
push to `master` of [the repository](https://github.com/dart-lang/dartbug.com).

See
[the documentation](https://cloud.google.com/run/docs/continuous-deployment-with-cloud-build)
for details.

## Manual Deploy

Following instructions at https://cloud.google.com/run/docs/quickstarts/build-and-deploy:

1. ### Build the container

    ```console
    $ gcloud builds submit --project dart-redirector --tag gcr.io/dart-redirector/app
    ```

1. ### Deploy

    ```console
    $ gcloud run deploy app --project dart-redirector --image gcr.io/dart-redirector/app --platform managed --max-instances=1 --timeout=10s
    ```

## To update SDK Triage areas

```console
$ dart tool/update_sdk_labels.dart
```
