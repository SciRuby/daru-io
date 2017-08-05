Dir["#{__dir__}/exporters/*.rb"].each { |file| require "daru/io#{file.gsub(__dir__, '')}" }
