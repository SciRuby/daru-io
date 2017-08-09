# coding: utf-8

# rubocop:disable Layout/IndentHeredoc

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'daru/io/version'

Gem::Specification.new do |spec| # rubocop:disable Metrics/BlockLength
  spec.name          = 'daru-io'
  spec.version       = Daru::IO::VERSION
  spec.authors       = ['Athitya Kumar']
  spec.email         = ['athityakumar@gmail.com']
  spec.summary       = 'Daru-IO is a plugin-gem to Daru gem, which stands for Data Analysis in RUby.'
  spec.description   = 'Daru-IO is a plugin-gem to Daru gem, which stands for Data Analysis in RUby. '\
                       'Daru-IO extends support for many Import and Export methods of `Daru::DataFrame`. '\
                       'This gem is intended to help Data analyzing and Web Developer Rubyists, by serving '\
                       'as a general purpose conversion library that takes input in one format (say, JSON) '\
                       'and converts it another format (say, Avro) while making it incredibly easy to '\
                       'analyze the data.'
  spec.homepage      = 'https://github.com/athityakumar/daru-io'
  spec.license       = 'MIT'
  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'bin'
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.post_install_message = <<-EOF

*************************************************
|        Thank you for installing daru-io!      |
|                                               |
|                      //                       |
|                     //                        |
|                    ||                         |
|                    ||                         |
|                    ||                         |
|                oOOOOOOOOOo                    |
|               ,         Oo                    |
|              //|         |                    |
|              \\\\|         |                    |
|                | --- .-. |                    |
|                |  |  | | |                    |
|                | _|_ ._. |                    |
|                `---------`                    |
|                                               |
|  Hope you love using daru-io! Also, consider  |
|  using daru-view for various visualizations   |
|  such as Tables and Charts plotting. Read     |
|  the README for interesting use cases and     |
|  examples.                                    |
|                                               |
|  Cheers!                                      |
|  SciRuby Team                                 |
*************************************************

EOF

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
