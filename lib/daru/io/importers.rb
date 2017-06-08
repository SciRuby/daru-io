Dir['lib/daru/io/importers/*.rb'].each { |file| require file.gsub('lib/','') }
