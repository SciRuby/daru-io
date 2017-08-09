# Daru-IO

[![Build Status](https://travis-ci.org/athityakumar/daru-io.svg?branch=master)](https://travis-ci.org/athityakumar/daru-io)
[![Yard Docs](http://img.shields.io/badge/yard-docs-blue.svg)](http://www.rubydoc.info/github/athityakumar/daru-io/master/)
[![Inline docs](http://inch-ci.org/github/athityakumar/daru-io.png)](http://inch-ci.org/github/athityakumar/daru-io)
[![Code Climate](https://codeclimate.com/github/athityakumar/daru-io.png)](https://codeclimate.com/github/athityakumar/daru-io)
[![Stories in Ready](https://badge.waffle.io/athityakumar/daru-io.png?label=ready&title=Ready)](https://waffle.io/athityakumar/daru-io?utm_source=badge)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

A Ruby plugin-gem to [daru gem](https://github.com/SciRuby/daru), that extends support for many Import and
Export methods of `Daru::DataFrame`. This gem is intended to help Data analyzing and Web Developer Rubyists,
by serving as a general purpose conversion library that takes input in one format (say, JSON) and
converts it another format (say, Avro) while making it incredibly easy to analyze the data.

# Table of contents

- [Installation](#installation)
- *[Importers](#importers): [ActiveRecord](#activerecord-importer), [Avro](#avro-importer), [CSV](#csv-importer), [Excel](#excel-importer), [Excelx](#excelx-importer), [HTML](#html-importer), [JSON](#json-importer), [Mongo](#mongo-importer), [Plaintext](#plaintext-importer), [RData](#rdata-importer), [RDS](#rds-importer), [Redis](#redis-importer), [SQL](#sql-importer)*
- *[Exporters](#exporters): [Avro](#avro-exporter), [CSV](#csv-exporter), [Excel](#excel-exporter), [JSON](#json-exporter), [RData](#rdata-exporter), [RDS](#rds-exporter), [SQL](#sql-exporter)*
- [Contributing](#contributing)
- [License](#license)

# Installation

[(Go to Table of Contents)](#table-of-contents)

- If you're working with a Gemfile,

    - Add this line to your application's Gemfile:

    ```ruby
    gem 'daru-io'
    ```

    - And then execute:

    ```sh
    bundle
    ```

- If you're NOT working with a Gemfile, simply install it yourself as:

  ```sh
  gem install daru-io
  ```

- Require `daru-io` gem in your application:

```ruby
require 'daru/io' #! Requires all Importers & Exporters
require 'daru/io/importers' #! Requires all Importers and not Exporters
require 'daru/io/importers/json' #! Requires only JSON Importer
```

*Note - Each IO module has it's own set of dependencies. Have a look at the [Importers](#importers) and [Exporters](#exporters) section for dependency-specific information.*

# Importers

### ActiveRecord Importer

[(Go to Table of Contents)](#table-of-contents)

```ruby
#! Partially require just ActiveRecord Importer
require 'daru/io/importers/active_record'

#! Usage from Daru::IO
Daru::IO::Importers::ActiveRecord.new(args).call

#! Usage from Daru::DataFrame
Daru::DataFrame.from_activerecord(args)
```

- Have a look at [this documentation](http://www.rubydoc.info/github/athityakumar/daru-io/master/Daru/IO/Importers/ActiveRecord) to know more about this Importer.
- Dependency : activerecord gem.

### Avro Importer

[(Go to Table of Contents)](#table-of-contents)

```ruby
#! Partially require just Avro Importer
require 'daru/io/importers/avro'

#! Usage from Daru::IO
Daru::IO::Importers::Avro.new(args).call

#! Usage from Daru::DataFrame
Daru::DataFrame.from_avro(args)
```

- Have a look at [this documentation](http://www.rubydoc.info/github/athityakumar/daru-io/master/Daru/IO/Importers/Avro) to know more about this Importer.
- Dependency : avro gem.

### CSV Importer

[(Go to Table of Contents)](#table-of-contents)

```ruby
#! Partially require just CSV Importer
require 'daru/io/importers/csv'

#! Usage from Daru::IO
Daru::IO::Importers::CSV.new(args).call

#! Usage from Daru::DataFrame
Daru::DataFrame.from_csv(args)
```

- Have a look at [this documentation](http://www.rubydoc.info/github/athityakumar/daru-io/master/Daru/IO/Importers/CSV) to know more about this Importer.
- Dependency : Standard library csv gem.

### Excel Importer

[(Go to Table of Contents)](#table-of-contents)

```ruby
#! Partially require just Excel Importer
require 'daru/io/importers/excel'

#! Usage from Daru::IO
Daru::IO::Importers::Excel.new(args).call

#! Usage from Daru::DataFrame
Daru::DataFrame.from_excel(args)
```

- Have a look at [this documentation](http://www.rubydoc.info/github/athityakumar/daru-io/master/Daru/IO/Importers/Excel) to know more about this Importer.
- Dependency : spreadsheet gem.

### Excelx Importer

[(Go to Table of Contents)](#table-of-contents)

```ruby
#! Partially require just Excel Importer
require 'daru/io/importers/excelx'

#! Usage from Daru::IO
Daru::IO::Importers::Excelx.new(args).call

#! Usage from Daru::DataFrame
require 'daru/io/importers/excel'
Daru::DataFrame.from_excel(args) #! Filename ends with '.xlsx'
```

- Have a look at [this documentation](http://www.rubydoc.info/github/athityakumar/daru-io/master/Daru/IO/Importers/Excelx) to know more about this Importer.
- Dependency : roo gem.

### HTML Importer

[(Go to Table of Contents)](#table-of-contents)

```ruby
#! Partially require just HTML Importer
require 'daru/io/importers/html'

#! Usage from Daru::IO
Daru::IO::Importers::HTML.new(args).call

#! Usage from Daru::DataFrame
Daru::DataFrame.from_html(args)
```

- Have a look at [this documentation](http://www.rubydoc.info/github/athityakumar/daru-io/master/Daru/IO/Importers/HTML) to know more about this Importer.
- Dependency : mechanize gem.

### JSON Importer

[(Go to Table of Contents)](#table-of-contents)

```ruby
#! Partially require just JSON Importer
require 'daru/io/importers/json'

#! Usage from Daru::IO
Daru::IO::Importers::JSON.new(args).call

#! Usage from Daru::DataFrame
Daru::DataFrame.from_json(args)
```

- Have a look at [this documentation](http://www.rubydoc.info/github/athityakumar/daru-io/master/Daru/IO/Importers/JSON) to know more about this Importer.
- Dependency : Standard library json gem, and jsonpath gem.

### Mongo Importer

[(Go to Table of Contents)](#table-of-contents)

*Note : The Mongo gem faces Argument Error : expected Proc Argument issue due to the bug in MRI Ruby 2.4.0 mentioned [here](https://bugs.ruby-lang.org/issues/13107). This seems to have been fixed in Ruby 2.4.1 onwards. Hence, please avoid using this Mongo Importer in Ruby version 2.4.0.*

```ruby
#! Partially require just Mongo Importer
require 'daru/io/importers/mongo'

#! Usage from Daru::IO
Daru::IO::Importers::Mongo.new(args).call

#! Usage from Daru::DataFrame
Daru::DataFrame.from_mongo(args)
```

- Have a look at [this documentation](http://www.rubydoc.info/github/athityakumar/daru-io/master/Daru/IO/Importers/Mongo) to know more about this Importer.
- Dependency : Standard library JSON gem, jsonpath gem, mongo-ruby-driver gem and MongoDB.

### Plaintext Importer

[(Go to Table of Contents)](#table-of-contents)

```ruby
#! Partially require just Plaintext Importer
require 'daru/io/importers/plaintext'

#! Usage from Daru::IO
Daru::IO::Importers::Plaintext.new(args).call

#! Usage from Daru::DataFrame
Daru::DataFrame.from_plaintext(args)
```

- Have a look at [this documentation](http://www.rubydoc.info/github/athityakumar/daru-io/master/Daru/IO/Importers/Plaintext) to know more about this Importer.
- Dependency : None.

### RData Importer

[(Go to Table of Contents)](#table-of-contents)

```ruby
#! Partially require just RData Importer
require 'daru/io/importers/r_data'

#! Usage from Daru::IO
Daru::IO::Importers::RData.new(args).call

#! Usage from Daru::DataFrame
Daru::DataFrame.from_rdata(args)
```

- Have a look at [this documentation](http://www.rubydoc.info/github/athityakumar/daru-io/master/Daru/IO/Importers/RData) to know more about this Importer.
- Dependency : rsruby gem and R.

### RDS Importer

[(Go to Table of Contents)](#table-of-contents)

```ruby
#! Partially require just RDS Importer
require 'daru/io/importers/rds'

#! Usage from Daru::IO
Daru::IO::Importers::RDS.new(args).call

#! Usage from Daru::DataFrame
Daru::DataFrame.from_rds(args)
```

- Have a look at [this documentation](http://www.rubydoc.info/github/athityakumar/daru-io/master/Daru/IO/Importers/RDS) to know more about this Importer.
- Dependency : rsruby gem and R.

### Redis Importer

[(Go to Table of Contents)](#table-of-contents)

```ruby
#! Partially require just Redis Importer
require 'daru/io/importers/redis'

#! Usage from Daru::IO
Daru::IO::Importers::Redis.new(args).call

#! Usage from Daru::DataFrame
Daru::DataFrame.from_redis(args)
```

- Have a look at [this documentation](http://www.rubydoc.info/github/athityakumar/daru-io/master/Daru/IO/Importers/Redis) to know more about this Importer.
- Dependency : Standard library JSON gem, redis gem and a running `redis-server`.

### SQL Importer

[(Go to Table of Contents)](#table-of-contents)

```ruby
#! Partially require just SQL Importer
require 'daru/io/importers/sql'

#! Usage from Daru::IO
Daru::IO::Importers::SQL.new(args).call

#! Usage from Daru::DataFrame
Daru::DataFrame.from_sql(args)
```

- Have a look at [this documentation](http://www.rubydoc.info/github/athityakumar/daru-io/master/Daru/IO/Importers/SQL) to know more about this Importer.
- Dependency : dbd-sqlite3, activerecord, dbi, sqlite3 gems and SQL.

# Exporters

### Avro Exporter

[(Go to Table of Contents)](#table-of-contents)

```ruby
#! Partially require just Avro Exporter
require 'daru/io/exporters/avro'

#! Usage from Daru::IO
Daru::IO::Exporters::Avro.new(df, args).call

#! Usage from Daru::DataFrame
df.to_avro(args)
```

- Have a look at [this documentation](http://www.rubydoc.info/github/athityakumar/daru-io/master/Daru/IO/Exporters/Avro) to know more about this Exporter.
- Dependency : avro gem.

### CSV Exporter

[(Go to Table of Contents)](#table-of-contents)

```ruby
#! Partially require just CSV Exporter
require 'daru/io/exporters/csv'

#! Usage from Daru::IO
Daru::IO::Exporters::CSV.new(df, args).call

#! Usage from Daru::DataFrame
df.to_csv(args)
```

- Have a look at [this documentation](http://www.rubydoc.info/github/athityakumar/daru-io/master/Daru/IO/Exporters/CSV) to know more about this Exporter.
- Dependency : Standard library CSV gem.

### Excel Exporter

[(Go to Table of Contents)](#table-of-contents)

```ruby
#! Partially require just Excel Exporter
require 'daru/io/exporters/excel'

#! Usage from Daru::IO
Daru::IO::Exporters::Excel.new(df, args).call

#! Usage from Daru::DataFrame
df.to_excel(args)
```

- Have a look at [this documentation](http://www.rubydoc.info/github/athityakumar/daru-io/master/Daru/IO/Exporters/Excel) to know more about this Exporter.
- Dependency : spreadsheet gem.

### JSON Exporter

[(Go to Table of Contents)](#table-of-contents)

```ruby
#! Partially require just JSON Exporter
require 'daru/io/exporters/json'

#! Usage from Daru::IO
Daru::IO::Exporters::JSON.new(df, args).call

#! Usage from Daru::DataFrame
df.to_json(args)
```

- Have a look at [this documentation](http://www.rubydoc.info/github/athityakumar/daru-io/master/Daru/IO/Exporters/JSON) to know more about this Exporter.
- Dependency : Standard library JSON gem and jsonpath gem.

### RData Exporter

[(Go to Table of Contents)](#table-of-contents)

```ruby
#! Partially require just RData Exporter
require 'daru/io/exporters/r_data'

#! Usage from Daru::IO
Daru::IO::Exporters::RData.new(args).call
```

- Have a look at [this documentation](http://www.rubydoc.info/github/athityakumar/daru-io/master/Daru/IO/Exporters/RData) to know more about this Exporter.
- Dependency : rsruby gem and R.

### RDS Exporter

[(Go to Table of Contents)](#table-of-contents)

```ruby
#! Partially require just RDS Exporter
require 'daru/io/exporters/rds'

#! Usage from Daru::IO
Daru::IO::Exporters::RDS.new(df, args).call

#! Usage from Daru::DataFrame
df.to_rds(args)
```

- Have a look at [this documentation](http://www.rubydoc.info/github/athityakumar/daru-io/master/Daru/IO/Exporters/RDS) to know more about this Exporter.
- Dependency : rsruby gem and R.

### SQL Exporter

[(Go to Table of Contents)](#table-of-contents)

```ruby
#! Partially require just SQL Exporter
require 'daru/io/exporters/sql'

#! Usage from Daru::IO
Daru::IO::Exporters::SQL.new(df, args).call

#! Usage from Daru::DataFrame
df.to_sql(args)
```

- Have a look at [this documentation](http://www.rubydoc.info/github/athityakumar/daru-io/master/Daru/IO/Exporters/SQL) to know more about this Exporter.
- Dependency : dbd-sqlite3, dbi and sqlite3 gems.

# Contributing

[(Go to Table of Contents)](#table-of-contents)

Contributions are always welcome. Please have a look at the [contribution guidelines](CONTRIBUTING.md) first. :tada:

# License

[(Go to Table of Contents)](#table-of-contents)

The MIT License (MIT) 2017 - [Athitya Kumar](https://github.com/athityakumar/). Please have a look at the [LICENSE.md](LICENSE.md) for more details.
