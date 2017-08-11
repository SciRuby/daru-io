# Contribution guidelines

First of all, thanks for thinking of contributing to this project. :smile:

Before sending a Pull Request, please make sure that you're assigned the task on a GitHub issue.

- If a relevant issue already exists, discuss on the issue and get it assigned to yourself on GitHub.
- If no relevant issue exists, open a new issue and get it assigned to yourself on GitHub.

Please proceed with a Pull Request only after you're assigned. It'd be sad if your Pull Request (and your hardwork) isn't accepted just because it isn't idealogically compatible.

# Developing the gem

1. Install required dependencies.

    - For the Mongo Importer, install Mongo.
    - For the RData Importer, RData Exporter, RDS Importer or RDS Exporter, install R and set the R_HOME
      variable in your shell configuration:
      ```sh
      export R_HOME=/usr/lib/R # For Unix systems
      export R_HOME=/usr/local/Frameworks/R.framework/Resources # For Mac systems 
      ```
    - For the Redis Importer, install Redis and start the redis server by typing `redis-server` in another
      terminal window, before running the test suites.

    For any issue(s) related to installation steps, kindly refer to the configurations mentioned in the
    `.travis.yml` file.

2. Clone this repository and install all the required gem dependencies.

    ```sh
    git clone https://github.com/athityakumar/daru-io.git
    cd daru-io
    gem install bundler
    bundle install
    ```

3. Checkout to a different git branch (say, `adds-format-importer`).

4. Add any gem dependencies required for the Format Importer to the `:optional` group of the Gemfile.

5. Add code and YARD documentation to `lib/daru/io/importers/format.rb`, consistent with other IO modules.

6. Add tests to `spec/daru/io/importers/format_spec.rb`. Add any `.format` files required for importer in `spec/fixtures/format/` directory.

7. Run the rspec test-suite.
    ```sh
    # Runs test suite for all Importers & Exporters
    bundle exec rspec

    # Runs test-suite only for the newly added Format Importer
    bundle exec rspec spec/daru/io/importers/format_spec.rb
    ```

8. Run the rubocop for static code quality comments.

    ```sh
    # Runs rubocop test for all Importer & Exporters
    bundle exec rubocop

    # Runs rubocop test only for the newly added Format Importer
    bundle exec rubocop lib/daru/io/importers/format.rb spec/daru/io/importers/format_spec.rb
    ```

9. Send a Pull Request back to this repository. :tada:
