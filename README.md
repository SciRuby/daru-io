# Daru-IO

[![Build Status](https://travis-ci.org/athityakumar/daru-io.svg?branch=master)](https://travis-ci.org/athityakumar/daru-io)
[![Yard Docs](http://img.shields.io/badge/yard-docs-blue.svg)](http://www.rubydoc.info/github/athityakumar/daru-io/master/)
[![Inline docs](http://inch-ci.org/github/athityakumar/daru-io.png)](http://inch-ci.org/github/athityakumar/daru-io)
[![Code Climate](https://codeclimate.com/github/athityakumar/daru-io.png)](https://codeclimate.com/github/athityakumar/daru-io)
[![Stories in Ready](https://badge.waffle.io/athityakumar/daru-io.png?label=ready&title=Ready)](https://waffle.io/athityakumar/daru-io?utm_source=badge)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

A Ruby plugin-gem to [daru gem](https://github.com/SciRuby/daru), that extends support for many Import and
Export methods of **Daru::DataFrame**. This gem is intended to help Rubyists who are into Data Analysis or Web
Development, by serving as a general purpose conversion library that takes input in one format (say, JSON) and
converts it another format (say, Avro) while also making it incredibly easy to getting started on
analyzing data with daru.

While supporting various IO modules, daru-io also provides an easier way of adding more Importers / Exporters. **It's strongly recommended to have a look at ['Creating your own IO modules' section](#creating-your-own-io-modules), if you're interested in creating new Importers / Exporters.**

# Table of contents

- [Installation](#installation)
- *[Importers](#importers): [ActiveRecord](#activerecord-importer), [Avro](#avro-importer), [CSV](#csv-importer), [Excel](#excel-importer), [Excelx](#excelx-importer), [HTML](#html-importer), [JSON](#json-importer), [Mongo](#mongo-importer), [Plaintext](#plaintext-importer), [RData](#rdata-importer), [RDS](#rds-importer), [Redis](#redis-importer), [SQL](#sql-importer)*
- *[Exporters](#exporters): [Avro](#avro-exporter), [CSV](#csv-exporter), [Excel](#excel-exporter), [JSON](#json-exporter), [RData](#rdata-exporter), [RDS](#rds-exporter), [SQL](#sql-exporter)*
- [Creating your own IO modules](#creating-your-own-io-modules)
- [Contributing](#contributing)
- [License](#license)

# Installation

[(Go to Table of Contents)](#table-of-contents)

- If you're working with a Gemfile,

    - Add this line to your application's Gemfile:

        ```ruby
        gem 'daru-io'
        ```

    - And then execute on your terminal:

        ```sh
        bundle
        ```

- If you're NOT working with a Gemfile, simply install it yourself by executing on your terminal:

    ```sh
    gem install daru-io
    ```

- Require `daru-io` gem in your application:

    ```ruby
    require 'daru/io' #! Requires all Importers & Exporters
    require 'daru/io/importers' #! Requires all Importers and no Exporters
    require 'daru/io/importers/json' #! Requires only JSON Importer
    ```

**Note: Each IO module has it's own set of dependencies. Have a look at the [Importers](#importers) and [Exporters](#exporters) section for dependency-specific information.**

# Importers

The **Daru::IO** Importers are intended to return a **Daru::DataFrame** from the given arguments. Generally,
all Importers can be called in two ways - from **Daru::IO** or **Daru::DataFrame**.

```ruby
#! Partially requires Format Importer
require 'daru/io/importers/format'

#! Usage from Daru::IO
df = Daru::IO::Importers::Format.new(args).call

#! Usage from Daru::DataFrame
df = Daru::DataFrame.from_format(args)
```

**Note: Please have a look at the respective Importer Doc links below, for having a look at arguments and examples.**

### ActiveRecord Importer

[(Go to Table of Contents)](#table-of-contents)

Imports a **Daru::DataFrame** from an **ActiveRecord** connection.

- **Docs**: [rubydoc.info](http://www.rubydoc.info/github/athityakumar/daru-io/master/Daru/IO/Importers/ActiveRecord)
- **Gem Dependencies**: `activerecord` gem
- **Other Dependencies**: Install database server(s) such as SQL / Postgresql / etc.
- **Usage**:
    ```ruby
    #! Partially require just ActiveRecord Importer
    require 'daru/io/importers/active_record'

    #! Usage from Daru::IO
    df = Daru::IO::Importers::ActiveRecord.new(activerecord_relation, :field_1, :field_2).call

    #! Usage from Daru::DataFrame
    df = Daru::DataFrame.from_activerecord(activerecord_relation, :field_1, :field_2)
    ```

### Avro Importer

[(Go to Table of Contents)](#table-of-contents)

Imports a **Daru::DataFrame** from an **.avro** file.

- **Docs**: [rubydoc.info](http://www.rubydoc.info/github/athityakumar/daru-io/master/Daru/IO/Importers/Avro)
- **Gem Dependencies**: `avro` and `snappy` gems
- **Usage**:
    ```ruby
    #! Partially require just Avro Importer
    require 'daru/io/importers/avro'

    #! Usage from Daru::IO
    df = Daru::IO::Importers::Avro.new('path/to/file.avro').call

    #! Usage from Daru::DataFrame
    df = Daru::DataFrame.from_avro('path/to/file.avro')
    ```

### CSV Importer

[(Go to Table of Contents)](#table-of-contents)

Imports a **Daru::DataFrame** from a **.csv** or **.csv.gz** file.

- **Docs**: [rubydoc.info](http://www.rubydoc.info/github/athityakumar/daru-io/master/Daru/IO/Importers/CSV)
- **Usage**:
    ```ruby
    #! Partially require just CSV Importer
    require 'daru/io/importers/csv'

    #! Usage from Daru::IO
    df1 = Daru::IO::Importers::CSV.new('path/to/file.csv', skiprows: 10, col_sep: ' ').call
    df2 = Daru::IO::Importers::CSV.new('path/to/file.csv.gz', skiprows: 10, compression: :gzip).call

    #! Usage from Daru::DataFrame
    df1 = Daru::DataFrame.from_csv('path/to/file.csv', skiprows: 10, col_sep: ' ')
    df2 = Daru::DataFrame.from_csv('path/to/file.csv.gz', skiprows: 10, compression: :gzip)
    ```

### Excel Importer

[(Go to Table of Contents)](#table-of-contents)

Imports a **Daru::DataFrame** from a **.xls** file.

- **Docs**: [rubydoc.info](http://www.rubydoc.info/github/athityakumar/daru-io/master/Daru/IO/Importers/Excel)
- **Gem Dependencies**: `spreadsheet` gem
- **Usage**:
    ```ruby
    #! Partially require just Excel Importer
    require 'daru/io/importers/excel'

    #! Usage from Daru::IO
    df = Daru::IO::Importers::Excel.new('path/to/file.xls', worksheet_id: 1).call

    #! Usage from Daru::DataFrame
    df = Daru::DataFrame.from_excel('path/to/file.xls', worksheet_id: 1)
    ```

### Excelx Importer

[(Go to Table of Contents)](#table-of-contents)

Imports a **Daru::DataFrame** from a **.xlsx** file.

- **Docs**: [rubydoc.info](http://www.rubydoc.info/github/athityakumar/daru-io/master/Daru/IO/Importers/Excelx)
- **Gem Dependencies**: `roo` gem
- **Usage**:
    ```ruby
    #! Partially require just Excel Importer
    require 'daru/io/importers/excelx'

    #! Usage from Daru::IO
    df = Daru::IO::Importers::Excelx.new('path/to/file.xlsx', sheet: 2, skiprows: 10, skipcols: 2).call

    #! Usage from Daru::DataFrame
    require 'daru/io/importers/excel'
    df = Daru::DataFrame.from_excel('path/to/file.xlsx', sheet: 2, skiprows: 10, skipcols: 2)
    ```

### HTML Importer

[(Go to Table of Contents)](#table-of-contents)

**Note: This module works only for static tables on a HTML page, and won't work in cases where the table is being loaded into the HTML table by inline Javascript. This is how the Mechanize gem works, and the HTML Importer also follows suit.**

Imports an **Array** of **Daru::DataFrame**s from a **.html** file or website.

- **Docs**: [rubydoc.info](http://www.rubydoc.info/github/athityakumar/daru-io/master/Daru/IO/Importers/HTML)
- **Gem Dependencies**: `mechanize` gem
- **Usage**:
    ```ruby
    #! Partially require just HTML Importer
    require 'daru/io/importers/html'

    #! Usage from Daru::IO
    df1 = Daru::IO::Importers::HTML.new('https://some/url/with/tables', match: 'market', name: 'Shares analysis').call
    df2 = Daru::IO::Importers::HTML.new('path/to/file.html', match: 'market', name: 'Shares analysis').call

    #! Usage from Daru::DataFrame
    df1 = Daru::DataFrame.from_html('https://some/url/with/tables', match: 'market', name: 'Shares analysis')
    df2 = Daru::DataFrame.from_html('path/to/file.html', match: 'market', name: 'Shares analysis')
    ```

### JSON Importer

[(Go to Table of Contents)](#table-of-contents)

Imports a **Daru::DataFrame** from a **.json** file / response.

- **Docs**: [rubydoc.info](http://www.rubydoc.info/github/athityakumar/daru-io/master/Daru/IO/Importers/JSON)
- **Gem Dependencies**: `jsonpath` gem
- **Usage**:
    ```ruby
    #! Partially require just JSON Importer
    require 'daru/io/importers/json'

    #! Usage from Daru::IO
    df1 = Daru::IO::Importers::JSON.new('https://path/to/json/response', index: '$..time', col1: '$..name', col2: '$..age').call
    df2 = Daru::IO::Importers::JSON.new('path/to/file.json', index: '$..time', col1: '$..name', col2: '$..age').call

    #! Usage from Daru::DataFrame
    df1 = Daru::DataFrame.from_json('https://path/to/json/response', index: '$..time', col1: '$..name', col2: '$..age')
    df2 = Daru::DataFrame.from_json('path/to/file.json', index: '$..time', col1: '$..name', col2: '$..age')
    ```

### Mongo Importer

[(Go to Table of Contents)](#table-of-contents)

**Note: The Mongo gem faces Argument Error : expected Proc Argument issue due to the bug in MRI Ruby 2.4.0 mentioned [here](https://bugs.ruby-lang.org/issues/13107). This seems to have been fixed in Ruby 2.4.1 onwards. Hence, please avoid using this Mongo Importer in Ruby version 2.4.0.**

Imports a **Daru::DataFrame** from a Mongo collection.

- **Docs**: [rubydoc.info](http://www.rubydoc.info/github/athityakumar/daru-io/master/Daru/IO/Importers/Mongo)
- **Gem Dependencies**: `jsonpath` and `mongo` gems
- **Other Dependencies**: Install MongoDB
- **Usage**:
    ```ruby
    #! Partially require just Mongo Importer
    require 'daru/io/importers/mongo'

    #! Usage from Daru::IO
    df = Daru::IO::Importers::Mongo.new('mongodb://127.0.0.1:27017/test', 'cars').call

    #! Usage from Daru::DataFrame
    df = Daru::DataFrame.from_mongo('mongodb://127.0.0.1:27017/test', 'cars')
    ```

### Plaintext Importer

[(Go to Table of Contents)](#table-of-contents)

Imports a **Daru::DataFrame** from a **.dat** plaintext file (space separated table of simple strings and numbers). For a sample format of the plaintext file, have a look at the example [bank2.dat](https://github.com/athityakumar/daru-io/blob/master/spec/fixtures/plaintext/bank2.dat) file.

- **Docs**: [rubydoc.info](http://www.rubydoc.info/github/athityakumar/daru-io/master/Daru/IO/Importers/Plaintext)
- **Usage**:
    ```ruby
    #! Partially require just Plaintext Importer
    require 'daru/io/importers/plaintext'

    #! Usage from Daru::IO
    df = Daru::IO::Importers::Plaintext.new('path/to/file.dat', [:col1, :col2, :col3]).call

    #! Usage from Daru::DataFrame
    df = Daru::DataFrame.from_plaintext('path/to/file.dat', [:col1, :col2, :col3])
    ```

### RData Importer

[(Go to Table of Contents)](#table-of-contents)

Imports a **Daru::DataFrame** from a variable in **.rdata** file.

- **Docs**: [rubydoc.info](http://www.rubydoc.info/github/athityakumar/daru-io/master/Daru/IO/Importers/RData)
- **Gem Dependencies**: `rsruby` gem
- **Other Dependencies**: Install R and set `R_HOME` variable as given in the [Contribution Guidelines](CONTRIBUTING.md)
- **Usage**:
    ```ruby
    #! Partially require just RData Importer
    require 'daru/io/importers/r_data'

    #! Usage from Daru::IO
    df = Daru::IO::Importers::RData.new('path/to/file.RData', 'ACS3').call

    #! Usage from Daru::DataFrame
    df = Daru::DataFrame.from_rdata('path/to/file.RData', 'ACS3')
    ```

### RDS Importer

[(Go to Table of Contents)](#table-of-contents)

Imports a **Daru::DataFrame** from a **.rds** file.

- **Docs**: [rubydoc.info](http://www.rubydoc.info/github/athityakumar/daru-io/master/Daru/IO/Importers/RDS)
- **Gem Dependencies**: `rsruby` gem
- **Other Dependencies**: Install R and set `R_HOME` variable as given in the [Contribution Guidelines](CONTRIBUTING.md)
- **Usage**:
    ```ruby
    #! Partially require just RDS Importer
    require 'daru/io/importers/rds'

    #! Usage from Daru::IO
    df = Daru::IO::Importers::RDS.new('path/to/file.rds').call

    #! Usage from Daru::DataFrame
    df = Daru::DataFrame.from_rds('path/to/file.rds')
    ```

### Redis Importer

[(Go to Table of Contents)](#table-of-contents)

Imports a **Daru::DataFrame** from **Redis** key(s).

- **Docs**: [rubydoc.info](http://www.rubydoc.info/github/athityakumar/daru-io/master/Daru/IO/Importers/Redis)
- **Gem Dependencies**: `redis` gem
- **Other Dependencies**: Install Redis, and run an instance of `redis-server`
- **Usage**:
    ```ruby
    #! Partially require just Redis Importer
    require 'daru/io/importers/redis'

    #! Usage from Daru::IO
    df = Daru::IO::Importers::Redis.new({url: 'redis://:password@host:port/db'}, match: 'time:1*', count: 1000).call

    #! Usage from Daru::DataFrame
    df = Daru::DataFrame.from_redis({url: 'redis://:password@host:port/db'}, match: 'time:1*', count: 1000)
    ```

### SQL Importer

[(Go to Table of Contents)](#table-of-contents)

Imports a **Daru::DataFrame** from a **sqlite.db** file / **DBI** connection.

- **Docs**: [rubydoc.info](http://www.rubydoc.info/github/athityakumar/daru-io/master/Daru/IO/Importers/SQL)
- **Gem Dependencies**: `dbd-sqlite3`, `activerecord`, `dbi` and `sqlite3` gems
- **Usage**:
    ```ruby
    #! Partially require just SQL Importer
    require 'daru/io/importers/sql'

    #! Usage from Daru::IO
    df1 = Daru::IO::Importers::SQL.new('path/to/file.sqlite', 'SELECT * FROM test').call
    df2 = Daru::IO::Importers::SQL.new(dbi_connection, 'SELECT * FROM test').call

    #! Usage from Daru::DataFrame
    df1 = Daru::DataFrame.from_sql('path/to/file.sqlite', 'SELECT * FROM test')
    df2 = Daru::DataFrame.from_sql(dbi_connection, 'SELECT * FROM test')
    ```

# Exporters

The **Daru::IO** Exporters are intended to 'migrate' a **Daru::DataFrame** into a file, or database. All Exporters can be called in two ways - from **Daru::IO** or **Daru::DataFrame**.

```ruby
#! Partially requires Format Exporter
require 'daru/io/exporters/format'

#! Usage from Daru::IO
Daru::IO::Exporters::Format.new(df, args).call

#! Usage from Daru::DataFrame
df.to_format(args)
```

**Note: Please have a look at the respective Exporter Doc links below, for having a look at arguments and examples.**

### Avro Exporter

[(Go to Table of Contents)](#table-of-contents)

Exports a **Daru::DataFrame** into a **.avro** file.

- **Docs**: [rubydoc.info](http://www.rubydoc.info/github/athityakumar/daru-io/master/Daru/IO/Exporters/Avro)
- **Gem Dependencies**: `avro` gem
- **Usage**:
    ```ruby
    #! Partially require just Avro Exporter
    require 'daru/io/exporters/avro'

    avro_schema = {
      'type' => 'record',
      'name' => 'Example',
      'fields' => [
        {'name' => 'col_1', 'type' => 'string'},
        {'name' => 'col_2', 'type' => 'int'},
        {'name' => 'col_3', 'type'=> 'boolean'}
      ]
    }

    #! Usage from Daru::IO
    Daru::IO::Exporters::Avro.new(df, 'path/to/file.avro', avro_schema).call

    #! Usage from Daru::DataFrame
    df.to_avro('path/to/file.avro', avro_schema)
    ```

### CSV Exporter

[(Go to Table of Contents)](#table-of-contents)

Exports a **Daru::DataFrame** into a **.csv** or **.csv.gz** file.

- **Docs**: [rubydoc.info](http://www.rubydoc.info/github/athityakumar/daru-io/master/Daru/IO/Exporters/CSV)
- **Usage**:
    ```ruby
    #! Partially require just CSV Exporter
    require 'daru/io/exporters/csv'

    #! Usage from Daru::IO
    Daru::IO::Exporters::CSV.new(df, 'path/to/file.csv', converters: :numeric, convert_comma: true).call
    Daru::IO::Exporters::CSV.new(df, 'path/to/file.csv.gz', converters: :numeric, compression: :gzip, convert_comma: true).call

    #! Usage from Daru::DataFrame
    df.to_csv('path/to/file.csv', converters: :numeric, convert_comma: true)
    df.to_csv('path/to/file.csv.gz', converters: :numeric, compression: :gzip, convert_comma: true)
    ```

### Excel Exporter

[(Go to Table of Contents)](#table-of-contents)

Exports a **Daru::DataFrame** into a **.xls** file.

- **Docs**: [rubydoc.info](http://www.rubydoc.info/github/athityakumar/daru-io/master/Daru/IO/Exporters/Excel)
- **Gem Dependencies**: `spreadsheet` gem
- **Usage**:
    ```ruby
    #! Partially require just Excel Exporter
    require 'daru/io/exporters/excel'

    #! Usage from Daru::IO
    Daru::IO::Exporters::Excel.new(df, 'path/to/file.xls', header: {color: :red, weight: :bold}, data: {color: :blue }, index: false).call

    #! Usage from Daru::DataFrame
    df.to_excel('path/to/file.xls', header: {color: :red, weight: :bold}, data: {color: :blue }, index: false)
    ```

### JSON Exporter

[(Go to Table of Contents)](#table-of-contents)

Exports a **Daru::DataFrame** into a **.json** file.

- **Docs**: [rubydoc.info](http://www.rubydoc.info/github/athityakumar/daru-io/master/Daru/IO/Exporters/JSON)
- **Gem Dependencies**: `jsonpath` gem
- **Usage**:
    ```ruby
    #! Partially require just JSON Exporter
    require 'daru/io/exporters/json'

    #! Usage from Daru::IO
    Daru::IO::Exporters::JSON.new(df, 'path/to/file.json', orient: :records, pretty: true, name: '$.person.name', age: '$.person.age').call

    #! Usage from Daru::DataFrame
    df.to_json('path/to/file.json', orient: :records, pretty: true, name: '$.person.name', age: '$.person.age')
    ```

### RData Exporter

[(Go to Table of Contents)](#table-of-contents)

Exports multiple **Daru::DataFrame**s into a **.rdata** file.

- **Docs**: [rubydoc.info](http://www.rubydoc.info/github/athityakumar/daru-io/master/Daru/IO/Exporters/RData)
- **Gem Dependencies**: `rsruby` gem
- **Other Dependencies**: Install R and set `R_HOME` variable as given in the [Contribution Guidelines](CONTRIBUTING.md)
- **Usage**:
    ```ruby
    #! Partially require just RData Exporter
    require 'daru/io/exporters/r_data'

    #! Usage from Daru::IO
    Daru::IO::Exporters::RData.new('path/to/file.RData', 'first.df': df1, 'second.df': df2).call
    ```

### RDS Exporter

[(Go to Table of Contents)](#table-of-contents)

Exports a **Daru::DataFrame** into a **.rds** file.

- **Docs**: [rubydoc.info](http://www.rubydoc.info/github/athityakumar/daru-io/master/Daru/IO/Exporters/RDS)
- **Gem Dependencies**: `rsruby` gem
- **Other Dependencies**: Install R and set `R_HOME` variable as given in the [Contribution Guidelines](CONTRIBUTING.md)
- **Usage**:
    ```ruby
    #! Partially require just RDS Exporter
    require 'daru/io/exporters/rds'

    #! Usage from Daru::IO
    Daru::IO::Exporters::RDS.new(df, 'path/to/file.rds', 'sample.dataframe').call

    #! Usage from Daru::DataFrame
    df.to_rds('path/to/file.rds', 'sample.dataframe')
    ```

### SQL Exporter

[(Go to Table of Contents)](#table-of-contents)

Exports a **Daru::DataFrame** into a database (SQL) table through DBI connection.

- **Docs**: [rubydoc.info](http://www.rubydoc.info/github/athityakumar/daru-io/master/Daru/IO/Exporters/SQL)
- **Gem Dependencies**: `dbd-sqlite3`, `dbi` and `sqlite3` gems
- **Other Dependencies**: Install SQL database server
- **Usage**:
    ```ruby
    #! Partially require just SQL Exporter
    require 'daru/io/exporters/sql'

    #! Usage from Daru::IO
    Daru::IO::Exporters::SQL.new(df, DBI.connect('DBI:Mysql:database:localhost', 'user', 'password'), 'cars_table').call

    #! Usage from Daru::DataFrame
    df.to_sql(DBI.connect('DBI:Mysql:database:localhost', 'user', 'password'), 'cars_table')
    ```

# Creating your own IO modules

**Daru-IO** currently supports various Import / Export methods, as it can be seen from the above list. But the list is NEVER complete - there may always be specific use-case format(s) that you need very badly, but might not fit the needs of majority of the community. In such a case, don't worry - you can always tweak (aka monkey-patch) daru-io in your application. The architecture of `daru-io` provides a neater way of monkey-patching into **Daru::DataFrame** to support your unique use-case.

 - **Adding new IO modules to Daru-IO**

    Say, your unique use-case is of YAML IO Modules. Here's how you can proceed with tweaking -

    ```ruby
    #! YAML Importer

    require 'daru/io'

    class Daru::IO::Importers::YAML < Daru::IO::Importers::Base
      Daru::DataFrame.register_io_module :from_yaml, self

      def initialize(path)
        @path = path
      end

      def call
        #! Your code to read the YAML file
        #! and return a Daru::DataFrame
      end
    end

    df = Daru::DataFrame.from_yaml('path/to/file.yaml') 
    # or,
    df = Daru::IO::Importers::YAML.new('path/to/file.yaml').call
    ```

    ```ruby
    #! YAML Exporter

    require 'daru/io'

    class Daru::IO::Exporters::YAML < Daru::IO::Exporters::Base
      Daru::DataFrame.register_io_module :to_yaml, self

      def initialize(dataframe, path)
        super(dataframe) #! Have a look at documentation of Daru::IO::Exporters::Base#initialize
        @path = path
      end

      def call
        #! Your code to write the YAML file
        #! with the data in the @dataframe
      end
    end

    df = Daru::DataFrame.new(x: [1,2], y: [3,4])

    df.to_yaml('dataframe.yml')
    # or,
    Daru::IO::Exporters::YAML.new(df, 'dataframe.yml')
    ```

- **Adding new IO modules to custom modules**

    Behaviour of existing IO modules can also be reused according to your needs, similar to the above example. For example, if the CSV Importer has to be tweaked with a faster processing gem, simply follow an approach similar to this -

    ```ruby
    class CustomNamespace::Importers::CSV < Daru::IO::Importers::CSV
      Daru::DataFrame.register_io_module :custom_csv, self

      #! Your CSV Importer code here
    end
    ```

**Note: The new module can be made to inherit from another module (like `Importers::JSON`) rather than `Importers::Base`, depending on use-case (say, parse a complexly nested API response with JsonPaths).**

# Contributing

[(Go to Table of Contents)](#table-of-contents)

Contributions are always welcome. But, please have a look at the [contribution guidelines](CONTRIBUTING.md) first before contributing. :tada:

# License

[(Go to Table of Contents)](#table-of-contents)

The MIT License (MIT) 2017 - [Athitya Kumar](https://github.com/athityakumar/) and [Ruby Science Foundation](https://github.com/SciRuby/). Please have a look at the [LICENSE.md](LICENSE.md) for more details.
