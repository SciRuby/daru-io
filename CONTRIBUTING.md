# Contribution guidelines

First of all, thanks for thinking of contributing to this project. :smile:

Before sending a Pull Request, please make sure that you're assigned the task on a GitHub issue.

- If a relevant issue already exists, discuss on the issue and get it assigned to yourself on GitHub.
- If no relevant issue exists, open a new issue and get it assigned to yourself on GitHub.

Please proceed with a Pull Request only after you're assigned. It'd be sad if your Pull Request (and your hardwork) isn't accepted just because it isn't idealogically compatible.

# Developing the gem

1. Install the extensions dependencies : Mongo, R and Redis. For any issue related to these, kindly refer to the steps mentioned in the `.travis.yml` file.

2. Install with

    ```sh
    git clone https://github.com/athityakumar/daru-io.git
    cd daru-io
    gem install bundler
    bundle install
    ```

3. Checkout to a different git branch (say, `adds-format-importer`).

4. Add code and YARD documentation to `lib/daru/io/importers/format.rb`, consistent with other IO modules.

5. Add tests to `spec/daru/io/importers/format_spec.rb`. Add any `.format` files required for importer in `spec/fixtures/format/` directory.

6. Run the tests 
    ```sh
    bundle exec rspec
    bundle exec rubocop
    ```

7. Send a Pull Request back to this repository. :tada:
