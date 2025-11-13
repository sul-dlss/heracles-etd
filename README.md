[![CircleCI](https://dl.circleci.com/status-badge/img/gh/sul-dlss/heracles-etd/tree/main.svg?style=svg)](https://dl.circleci.com/status-badge/redirect/gh/sul-dlss/heracles-etd/tree/main)
[![codecov](https://codecov.io/gh/sul-dlss/heracles-etd/graph/badge.svg?token=YX0VEDM3J0)](https://codecov.io/gh/sul-dlss/heracles-etd)

# heracles-etd

`Heracles ETD` is Stanford University's application for submitting and approving electronic theses and dissertations. It is used by students and by staff at both the Office of the Registrar and the Stanford Libraries. 

This application is a successor to [Hydra ETD](https://github.com/sul-dlss-deprecated/hydra_etd), which was retired in September 2025.

Additional documentation is available in the [https://github.com/sul-dlss/heracles-etd/wiki](wiki).

## Data flow

1. First the **Registrar** POSTs to the `EtdsController` to create the Submission record in this app and register the item in SDR.
1. Next, the **student** visits `/submit/{DISSERTATION_ID_OR_DRUID}` to upload their files and enter metadata. This updates the Submission record, including attaching files for the dissertation, supplemental files, and permission files.
1. Once the **student** has completed all requirements from the prior step, the now ready submission is posted back to the Registrar system.
1. Next the **Registrar** hits `EtdsController` (again) when all the readers have weighed in, and again when Registrar updates the ETD status. The Submission record is updated accordingly.
   1. Repeat previous 2 steps and this one until dissertation has both reader and Registrar approval, per Registrar.
1. Once approved by the readers and registrar, the `CreateStubMarcRecordJob` runs to create a stub MARC record and write it to Folio, getting the folio_instance_hrid back from Folio. The folio_instance_hrid is recorded in the Submission record and the SDR item is updated (adding the folio_instance_hrid as a catalog link).
1. Once a day, **catalogers** are sent an email listing the submissions that are ready for cataloging.
1. A **cataloger** catalogs the submission in Folio.
1. Every hour the `CatalogStatusJob` runs to query Folio to determine if uncataloged submissions have been cataloged. If so, it kicks off the `StartAccessionJob`.
1. The `StartAccesionJob`**:
   1. Refreshes the metadata of the SDR item.
   2. Retrieves the SDR item and updates the cocina with access metadata (including embargo) and structural metadata (for the files).
   3. Copies files to the DOR workspace.
   4. Adds administrative and project tags to the SDR item for the ETD project.
   5. Closes the version (which initiates accessioning)
1. The SDR items proceeds with normal accessioning.

## Admin

### Test submission
`/admin/submissions/new_dummy_submission` will create a new submission and redirect to the submitter page (`/submissions/<dissertation id>/edit`).

The "student" for the submission is the current user. There is also a reader created for the current user (`/submissions/<dissertation id>/reader_review`).

## Development

### Requirements

* docker & docker compose
* tmux ([installation instructions](https://github.com/tmux/tmux#installation))
* overmind ([installed via bundler](https://github.com/DarthSim/overmind/tree/master/packaging/rubygems#installation-with-rails))

### Running locally

Spin up the db container and then set up the application and solid-* databases:

```shell
docker compose up -d
bin/setup
```

Then browse to http://localhost:3000/admin to see the running application.

See [overmind documentation](https://github.com/DarthSim/overmind) for how to control processes.

### Debugging locally

1. Add a `debugger` statement in the code.
2. Connect to the process (for example, `bin/overmind connect web`).

### Code Linters

To run all configured linters, run `bin/rake lint`.

To run linters individually, run which ones you need:

* Ruby code: `bin/rubocop` (add `-a` flag to autocorrect violations)
* ERB templates: `bin/erb_lint --lint-all --format compact` (add `-a` flag to autocorrect violations)
* ERB templates: `bin/herb analyze app --no-log-file`
* JavaScript code: `yarn run lint` (add `--fix` flag to autocorrect violations)
* SCSS stylesheets: `yarn run stylelint` (add `--fix` flag to autocorrect violations)

## Production

### Monitoring

The Honeybadger URL for monitoring this application is at https://app.honeybadger.io/projects/55164. Note: this Honeybadger project is used for both the Hydra & Heracles ETD applications.
