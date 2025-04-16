# Tests

## Coverage

We use [simplecov](https://github.com/simplecov-ruby/simplecov) to check our test suite coverage. To do so, run your test suite with `COVERAGE=true` and then open the `index.html` located in `/coverage/` in a browser. It's always informative to check the coverage of your newly written code before opening a PR.

## System tests

By default, Chrome is run in headless mode. If you want to see what happens in the browser, you can set the environment variable HEADLESS_TEST to false and use a VNC client (on a Mac, use Finder > Go > Connect to server...vnc://0.0.0.0:5900), with password `secret`.

## Parallel tests

To improve the speed of running specs, you can run the specs parallelized.

First, create the databases and load schema with `rails parallel:create parallel:load_schema`.

Run the specs with `rails parallel:spec`.
