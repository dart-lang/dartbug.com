Simple redirector to the Dart issue tracker.

    dartbug.com                      --> issues list
    dartbug.com/new                  --> new issue template
    dartbug.com/<number>             --> specific issue
    dartbug.com/opened/<user-id>     --> issues opened by github user <user-id>
    dartbug.com/assigned/<user-id>   --> issues assigned to github user <user-id>
    dartbug.com/area/<area>          --> issues in <area> (i.e., tagged with label 'area-<area>')
    dartbug.com/triage               --> an alias for 'triage/sdk'
    dartbug.com/triage/sdk           --> issues in the Dart SDK without an `area-<area>` label assigned
    dartbug.com/triage/core          --> an alias for 'triage/core/issues'
    dartbug.com/triage/core/issues   --> untriaged issues for the Dart core packages (dart.dev published)
    dartbug.com/triage/core/prs      --> untriaged PRs for the Dart core packages (dart.dev published)
    dartbug.com/triage/tools         --> an alias for 'triage/tools/issues'
    dartbug.com/triage/tools/issues  --> untriaged issues for the Dart tools packages (tools.dart.dev published)
    dartbug.com/triage/tools/prs     --> untriaged PRs for the Dart tools packages (tools.dart.dev published)
    dartbug.com/language             --> issues list for language repo
    dartbug.com/language/new         --> new issue template in language repo
    dartbug.com/language/<nunmber>   --> specific issue in language repo
    dartbug.com/language/opened/<user-id>   --> issues opened by github user <user-id> in language repo
    dartbug.com/language/assigned/<user-id> --> issues assigned to github user <user-id> in language repo
    dartbug.com/l                    --> shorthand for /language

See the [LICENSE](LICENSE) file.

## Continuous deployment from Git using Cloud Build

The `dart-redirector` project is configured to deploy this application on every
push to `main` of [the repository](https://github.com/dart-lang/dartbug.com).

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

