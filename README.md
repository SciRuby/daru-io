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

While supporting various IO modules, daru-io also provides an easier way of adding more Importers / Exporters
by means of monkey-patching. **It's strongly recommended to have a look at [this section](#tweaking-io-modules), if you're interested in tweaking and creating custom Importers / Exporters.**

# Table of contents

- [Installation](#installation)
- *[Importers](#importers): [ActiveRecord](#activerecord-importer), [Avro](#avro-importer), [CSV](#csv-importer), [Excel](#excel-importer), [Excelx](#excelx-importer), [HTML](#html-importer), [JSON](#json-importer), [Mongo](#mongo-importer), [Plaintext](#plaintext-importer), [RData](#rdata-importer), [RDS](#rds-importer), [Redis](#redis-importer), [SQL](#sql-importer)*
- *[Exporters](#exporters): [Avro](#avro-exporter), [CSV](#csv-exporter), [Excel](#excel-exporter), [JSON](#json-exporter), [RData](#rdata-exporter), [RDS](#rds-exporter), [SQL](#sql-exporter)*
- [Tweaking](#tweaking-io-modules)
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
Daru::IO::Importers::Format.new(args).call

#! Usage from Daru::DataFrame
Daru::DataFrame.from_format(args)
```

**Note: Please have a look at the respective Importer Doc links below, for having a look at arguments and examples.**

### ActiveRecord Importer

[(Go to Table of Contents)](#table-of-contents)

Imports a **Daru::DataFrame** from an **ActiveRecord** connection.

- **Docs**: [rubydoc.info](http://www.rubydoc.info/github/athityakumar/daru-io/master/Daru/IO/Importers/ActiveRecord)
- **Gem Dependencies**: `activerecord` gem
- **Other Dependencies**: None
- **Usage**:
    ```ruby
    #! Partially require just ActiveRecord Importer
    require 'daru/io/importers/active_record'

    #! Usage from Daru::IO
    Daru::IO::Importers::ActiveRecord.new(args).call

    #! Usage from Daru::DataFrame
    Daru::DataFrame.from_activerecord(args)
    ```

### Avro Importer

[(Go to Table of Contents)](#table-of-contents)

Imports a **Daru::DataFrame** from an **.avro** file.

- **Docs**: [rubydoc.info](http://www.rubydoc.info/github/athityakumar/daru-io/master/Daru/IO/Importers/Avro)
- **Gem Dependencies**: `avro` and `snappy` gems
- **Other Dependencies**: None
- **Usage**:
    ```ruby
    #! Partially require just Avro Importer
    require 'daru/io/importers/avro'

    #! Usage from Daru::IO
    Daru::IO::Importers::Avro.new(args).call

    #! Usage from Daru::DataFrame
    Daru::DataFrame.from_avro(args)
    ```

### CSV Importer

[(Go to Table of Contents)](#table-of-contents)

Imports a **Daru::DataFrame** from a **.csv** or **.csv.gz** file.

- **Docs**: [rubydoc.info](http://www.rubydoc.info/github/athityakumar/daru-io/master/Daru/IO/Importers/CSV)
- **Gem Dependencies**: Standard library `csv`, `open-uri` and `zlib` gems
- **Other Dependencies**: None
- **Usage**:
    ```ruby
    #! Partially require just CSV Importer
    require 'daru/io/importers/csv'

    #! Usage from Daru::IO
    Daru::IO::Importers::CSV.new(args).call

    #! Usage from Daru::DataFrame
    Daru::DataFrame.from_csv(args)
    ```

### Excel Importer

[(Go to Table of Contents)](#table-of-contents)

Imports a **Daru::DataFrame** from a **.xls** file.

- **Docs**: [rubydoc.info](http://www.rubydoc.info/github/athityakumar/daru-io/master/Daru/IO/Importers/Excel)
- **Gem Dependencies**: `spreadsheet` gem
- **Other Dependencies**: None
- **Usage**:
    ```ruby
    #! Partially require just Excel Importer
    require 'daru/io/importers/excel'

    #! Usage from Daru::IO
    Daru::IO::Importers::Excel.new(args).call

    #! Usage from Daru::DataFrame
    Daru::DataFrame.from_excel(args)
    ```

### Excelx Importer

[(Go to Table of Contents)](#table-of-contents)

Imports a **Daru::DataFrame** from a **.xlsx** file.

- **Docs**: [rubydoc.info](http://www.rubydoc.info/github/athityakumar/daru-io/master/Daru/IO/Importers/Excelx)
- **Gem Dependencies**: `roo` gem
- **Other Dependencies**: None
- **Usage**:
    ```ruby
    #! Partially require just Excel Importer
    require 'daru/io/importers/excelx'

    #! Usage from Daru::IO
    Daru::IO::Importers::Excelx.new(args).call

    #! Usage from Daru::DataFrame
    require 'daru/io/importers/excel'
    Daru::DataFrame.from_excel(args) #! Filename ends with '.xlsx'
    ```

### HTML Importer

[(Go to Table of Contents)](#table-of-contents)

Imports an **Array** of **Daru::DataFrame**s from a **.html** file or website.

- **Docs**: [rubydoc.info](http://www.rubydoc.info/github/athityakumar/daru-io/master/Daru/IO/Importers/HTML)
- **Gem Dependencies**: `mechanize` gem
- **Other Dependencies**: None
- **Usage**:
    ```ruby
    #! Partially require just HTML Importer
    require 'daru/io/importers/html'

    #! Usage from Daru::IO
    Daru::IO::Importers::HTML.new(args).call

    #! Usage from Daru::DataFrame
    Daru::DataFrame.from_html(args)
    ```

### JSON Importer

[(Go to Table of Contents)](#table-of-contents)

Imports a **Daru::DataFrame** from a **.json** file / response.

- **Docs**: [rubydoc.info](http://www.rubydoc.info/github/athityakumar/daru-io/master/Daru/IO/Importers/JSON)
- **Gem Dependencies**: Standard library `json` gem and `jsonpath` gem
- **Other Dependencies**: None
- **Usage**:
    ```ruby
    #! Partially require just JSON Importer
    require 'daru/io/importers/json'

    #! Usage from Daru::IO
    Daru::IO::Importers::JSON.new(args).call

    #! Usage from Daru::DataFrame
    Daru::DataFrame.from_json(args)
    ```

### Mongo Importer

[(Go to Table of Contents)](#table-of-contents)

**Note: The Mongo gem faces Argument Error : expected Proc Argument issue due to the bug in MRI Ruby 2.4.0 mentioned [here](https://bugs.ruby-lang.org/issues/13107). This seems to have been fixed in Ruby 2.4.1 onwards. Hence, please avoid using this Mongo Importer in Ruby version 2.4.0.**

Imports a **Daru::DataFrame** from a Mongo collection.

- **Docs**: [rubydoc.info](http://www.rubydoc.info/github/athityakumar/daru-io/master/Daru/IO/Importers/Mongo)
- **Gem Dependencies**: Standard library `json` gem, `jsonpath` and `mongo` gems
- **Other Dependencies**: Mongo
- **Usage**:
    ```ruby
    #! Partially require just Mongo Importer
    require 'daru/io/importers/mongo'

    #! Usage from Daru::IO
    Daru::IO::Importers::Mongo.new(args).call

    #! Usage from Daru::DataFrame
    Daru::DataFrame.from_mongo(args)
    ```

### Plaintext Importer

[(Go to Table of Contents)](#table-of-contents)

Imports a **Daru::DataFrame** from a **.dat** plaintext file.

- **Docs**: [rubydoc.info](http://www.rubydoc.info/github/athityakumar/daru-io/master/Daru/IO/Importers/Plaintext)
- **Gem Dependencies**: None
- **Other Dependencies**: None
- **Usage**:
    ```ruby
    #! Partially require just Plaintext Importer
    require 'daru/io/importers/plaintext'

    #! Usage from Daru::IO
    Daru::IO::Importers::Plaintext.new(args).call

    #! Usage from Daru::DataFrame
    Daru::DataFrame.from_plaintext(args)
    ```

### RData Importer

[(Go to Table of Contents)](#table-of-contents)

Imports a **Daru::DataFrame** from a variable in **.rdata** file.

- **Docs**: [rubydoc.info](http://www.rubydoc.info/github/athityakumar/daru-io/master/Daru/IO/Importers/RData)
- **Gem Dependencies**: `rsruby` gem
- **Other Dependencies**: R and setting of `R_HOME` variable
- **Usage**:
    ```ruby
    #! Partially require just RData Importer
    require 'daru/io/importers/r_data'

    #! Usage from Daru::IO
    Daru::IO::Importers::RData.new(args).call

    #! Usage from Daru::DataFrame
    Daru::DataFrame.from_rdata(args)
    ```

### RDS Importer

[(Go to Table of Contents)](#table-of-contents)

Imports a **Daru::DataFrame** from a **.rds** file.

- **Docs**: [rubydoc.info](http://www.rubydoc.info/github/athityakumar/daru-io/master/Daru/IO/Importers/RDS)
- **Gem Dependencies**: `rsruby` gem
- **Other Dependencies**: R and setting of `R_HOME` variable
- **Usage**:
    ```ruby
    #! Partially require just RDS Importer
    require 'daru/io/importers/rds'

    #! Usage from Daru::IO
    Daru::IO::Importers::RDS.new(args).call

    #! Usage from Daru::DataFrame
    Daru::DataFrame.from_rds(args)
    ```

### Redis Importer

[(Go to Table of Contents)](#table-of-contents)

Imports a **Daru::DataFrame** from **Redis** key(s).

- **Docs**: [rubydoc.info](http://www.rubydoc.info/github/athityakumar/daru-io/master/Daru/IO/Importers/Redis)
- **Gem Dependencies**: Standard library `json` gem, and `redis` gem
- **Other Dependencies**: Redis, and a running instance of `redis-server`
- **Usage**:
    ```ruby
    #! Partially require just Redis Importer
    require 'daru/io/importers/redis'

    #! Usage from Daru::IO
    Daru::IO::Importers::Redis.new(args).call

    #! Usage from Daru::DataFrame
    Daru::DataFrame.from_redis(args)
    ```

### SQL Importer

[(Go to Table of Contents)](#table-of-contents)

Imports a **Daru::DataFrame** from a **sqlite.db** file / **DBI** connection.

- **Docs**: [rubydoc.info](http://www.rubydoc.info/github/athityakumar/daru-io/master/Daru/IO/Importers/SQL)
- **Gem Dependencies**: `dbd-sqlite3`, `activerecord`, `dbi` and `sqlite3` gems
- **Other Dependencies**: SQL
- **Usage**:
    ```ruby
    #! Partially require just SQL Importer
    require 'daru/io/importers/sql'

    #! Usage from Daru::IO
    Daru::IO::Importers::SQL.new(args).call

    #! Usage from Daru::DataFrame
    Daru::DataFrame.from_sql(args)
    ```

# Exporters

The **Daru::IO** Exporters are intended to 'migrate' a **Daru::DataFrame** into a file, or database. All
Exporters can be called in two ways - from **Daru::IO** or **Daru::DataFrame**.

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
- **Other Dependencies**: None
- **Usage**:
    ```ruby
    #! Partially require just Avro Exporter
    require 'daru/io/exporters/avro'

    #! Usage from Daru::IO
    Daru::IO::Exporters::Avro.new(df, args).call

    #! Usage from Daru::DataFrame
    df.to_avro(args)
    ```

### CSV Exporter

[(Go to Table of Contents)](#table-of-contents)

Exports a **Daru::DataFrame** into a **.csv** or **.csv.gz** file.

- **Docs**: [rubydoc.info](http://www.rubydoc.info/github/athityakumar/daru-io/master/Daru/IO/Exporters/CSV)
- **Gem Dependencies**: Standard library `csv` and `zlib` gems
- **Other Dependencies**: None
- **Usage**:
    ```ruby
    #! Partially require just CSV Exporter
    require 'daru/io/exporters/csv'

    #! Usage from Daru::IO
    Daru::IO::Exporters::CSV.new(df, args).call

    #! Usage from Daru::DataFrame
    df.to_csv(args)
    ```

### Excel Exporter

[(Go to Table of Contents)](#table-of-contents)

Exports a **Daru::DataFrame** into a **.xls** file.

- **Docs**: [rubydoc.info](http://www.rubydoc.info/github/athityakumar/daru-io/master/Daru/IO/Exporters/Excel)
- **Gem Dependencies**: `spreadsheet` gem
- **Other Dependencies**: None
- **Usage**:
    ```ruby
    #! Partially require just Excel Exporter
    require 'daru/io/exporters/excel'

    #! Usage from Daru::IO
    Daru::IO::Exporters::Excel.new(df, args).call

    #! Usage from Daru::DataFrame
    df.to_excel(args)
    ```

### JSON Exporter

[(Go to Table of Contents)](#table-of-contents)

Exports a **Daru::DataFrame** into a **.json** file.

- **Docs**: [rubydoc.info](http://www.rubydoc.info/github/athityakumar/daru-io/master/Daru/IO/Exporters/JSON)
- **Gem Dependencies**: Standard library `json` gem and `jsonpath` gem
- **Other Dependencies**: None
- **Usage**:
    ```ruby
    #! Partially require just JSON Exporter
    require 'daru/io/exporters/json'

    #! Usage from Daru::IO
    Daru::IO::Exporters::JSON.new(df, args).call

    #! Usage from Daru::DataFrame
    df.to_json(args)
    ```

### RData Exporter

[(Go to Table of Contents)](#table-of-contents)

Exports multiple **Daru::DataFrame**s into a **.rdata** file.

- **Docs**: [rubydoc.info](http://www.rubydoc.info/github/athityakumar/daru-io/master/Daru/IO/Exporters/RData)
- **Gem Dependencies**: `rsruby` gem
- **Other Dependencies**: R and setting of `R_HOME` variable
- **Usage**:
    ```ruby
    #! Partially require just RData Exporter
    require 'daru/io/exporters/r_data'

    #! Usage from Daru::IO
    Daru::IO::Exporters::RData.new(args).call
    ```

### RDS Exporter

[(Go to Table of Contents)](#table-of-contents)

Exports a **Daru::DataFrame** into a **.rds** file.

- **Docs**: [rubydoc.info](http://www.rubydoc.info/github/athityakumar/daru-io/master/Daru/IO/Exporters/RDS)
- **Gem Dependencies**: `rsruby` gem
- **Other Dependencies**: R and setting of `R_HOME` variable
- **Usage**:
    ```ruby
    #! Partially require just RDS Exporter
    require 'daru/io/exporters/rds'

    #! Usage from Daru::IO
    Daru::IO::Exporters::RDS.new(df, args).call

    #! Usage from Daru::DataFrame
    df.to_rds(args)
    ```

### SQL Exporter

[(Go to Table of Contents)](#table-of-contents)

Exports a **Daru::DataFrame** into an SQL table.

- **Docs**: [rubydoc.info](http://www.rubydoc.info/github/athityakumar/daru-io/master/Daru/IO/Exporters/SQL)
- **Gem Dependencies**: `dbd-sqlite3`, `dbi` and `sqlite3` gems
- **Other Dependencies**: SQL
- **Usage**:
    ```ruby
    #! Partially require just SQL Exporter
    require 'daru/io/exporters/sql'

    #! Usage from Daru::IO
    Daru::IO::Exporters::SQL.new(df, args).call

    #! Usage from Daru::DataFrame
    df.to_sql(args)
    ```

# Tweaking IO modules

**Daru-IO** currently supports various Import / Export methods, as it can be seen from the above list. But the
list is NEVER complete - there may always be specific use-case format(s) that you need very badly, but
might not fit the needs of majority of the community. In such a case, don't worry - you can always tweak
(aka monkey-patch) daru-io in your application. The architecture of `daru-io` provides a neater way of
monkey-patching into **Daru::DataFrame** to support your unique use-case.

 - **Adding new IO modules**

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

    df = Daru::DataFrame.from_yaml('filename.yaml') 
    # or,
    df = Daru::IO::Importers::YAML.new('filename.yaml').call
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

- **Modify existing IO modules**

    Behaviour of existing IO modules can also be changed according to your needs, similar to the above example.
    For example, if the CSV Importer has to be tweaked with a faster processing gem, simply replace the above
    (psuedo)code with `class Daru::IO::Importers::CSV`.

**Note: The tweaked module can also be made to inherit from another module (like `Importers::JSON`) rather than `Importers::Base`, depending on use-case (say, parse a complexly nested API response with JsonPaths).**

# Contributing

[(Go to Table of Contents)](#table-of-contents)

Contributions are always welcome. But, please have a look at the [contribution guidelines](CONTRIBUTING.md) first before contributing. :tada:

# License

[(Go to Table of Contents)](#table-of-contents)

The MIT License (MIT) 2017 - [Athitya Kumar](https://github.com/athityakumar/). Please have a look at the [LICENSE.md](LICENSE.md) for more details.
