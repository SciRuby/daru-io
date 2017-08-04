Dir["#{__dir__}/importers/*.rb"].each { |file| require "daru/io#{file.gsub(__dir__, '')}" }
