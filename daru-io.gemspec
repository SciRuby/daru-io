lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'daru/io/version'

Daru::IO::DESCRIPTION = <<MSG.freeze
  Daru-IO is a plugin-gem to Daru gem, which stands for Data Analysis in RUby. Daru-IO extends support for many Import and Export methods of Daru::DataFrame. This gem is intended to help Rubyists who are into Data Analysis or Web Development, by serving as a general purpose conversion library,  while also making it incredibly easy to getting started on analyzing data with daru.
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
  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'bin'
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'daru', '~> 0.2.0'

  spec.add_development_dependency 'bundler', '~> 1.15'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'redcarpet'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rspec-its'
  spec.add_development_dependency 'rubocop', '>= 0.40.0'
  spec.add_development_dependency 'rubocop-rspec'
  spec.add_development_dependency 'rubygems-tasks'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'webmock'
  spec.add_development_dependency 'yard'

  spec.add_development_dependency 'guard-rspec' if RUBY_VERSION >= '2.2.5'
end
