[![CircleCI](https://dl.circleci.com/status-badge/img/gh/sul-dlss/heracles-etd/tree/main.svg?style=svg)](https://dl.circleci.com/status-badge/redirect/gh/sul-dlss/heracles-etd/tree/main)
[![codecov](https://codecov.io/gh/sul-dlss/heracles-etd/graph/badge.svg?token=YX0VEDM3J0)](https://codecov.io/gh/sul-dlss/heracles-etd)

# heracles-etd

## Development

### Requirements

* tmux ([installation instructions](https://github.com/tmux/tmux#installation))
* overmind ([installed via bundler](https://github.com/DarthSim/overmind/tree/master/packaging/rubygems#installation-with-rails))

### Running locally

```shell
bin/dev

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
