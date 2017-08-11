# coding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'daru/io/version'

Daru::IO::DESCRIPTION = <<MSG.freeze
  Daru-IO is a plugin-gem to Daru gem, which stands for Data Analysis in RUby. Daru-IO extends support for many Import and Export methods of Daru::DataFrame. This gem is intended to help Rubyists who are into Data Analysis or Web Development, by serving as a general purpose conversion library that takes input in one format (say, JSON) and converts it another format (say, Avro) while also making it incredibly easy to getting started on analyzing data with daru.

  While supporting various IO modules, daru-io also provides an easier way of adding more Importers / Exporters by means of monkey-patching.
MSG

Gem::Specification.new do |spec|
  spec.name          = 'daru-io'
  spec.version       = Daru::IO::VERSION
  spec.authors       = ['Athitya Kumar']
  spec.email         = ['athityakumar@gmail.com']
  spec.summary       = 'Daru-IO is a plugin-gem to Daru gem, which stands for Data Analysis in RUby.'
  spec.description   = Daru::IO::DESCRIPTION
  spec.homepage      = 'https://github.com/athityakumar/daru-io'
  spec.license       = 'MIT'
  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'bin'
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'daru', '~> 0.1.5'

  spec.add_development_dependency 'bundler', '~> 1.15'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rspec-its'
  spec.add_development_dependency 'rubocop', '>= 0.40.0'
  spec.add_development_dependency 'rubocop-rspec'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'webmock'
  spec.add_development_dependency 'yard'
  spec.add_development_dependency 'guard-rspec' if RUBY_VERSION >= '2.2.5'
end
