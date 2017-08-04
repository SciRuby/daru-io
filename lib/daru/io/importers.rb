%w[active_record csv excel excelx html json mongo plaintext r_data rds redis sql].each do |importer|
  require "daru/io/importers/#{importer}"
end
