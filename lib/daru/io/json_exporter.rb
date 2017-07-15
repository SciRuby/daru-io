require 'json'
require 'jsonpath'
require 'daru'
require 'pp'

def deep_merge(source, dest)
  return source if dest.nil?
  return dest if source.nil?

  if source.is_a?(Hash) && dest.kind_of?(Hash)
    source.each do |src_key, src_value|
      dest[src_key] = dest[src_key] ? deep_merge(src_value, dest[src_key]) : src_value
    end
  elsif source.is_a?(Array) && dest.kind_of?(Array)
    dest |= source
  else
    dest = source
  end
  dest
end

path = {name: '$..person..this..is..my..name', age: '$..person..this..is..my..age', sex: '$..gender'}

jsonpaths = path.values.map do |x|
  (JsonPath.new(x).path - %w[$ . ..]).map do |y|
    v = y.gsub("'","").gsub("[","").gsub("]","")
    next v.to_i if v.to_i.to_s == v
    v.to_sym
  end
end

df = Daru::DataFrame.new [{name: 'Jon Snow', age: 18, sex: 'Male'}, {name: 'Rhaegar Targaryen', age: 54, sex: 'Male'}, {name: 'Lyanna Stark', age: 36, sex: 'Female'}], index: [:child, :dad, :mom]

def init_hash_rec(jsonpaths, hash, i, jsonpath_keys, row)
  if jsonpaths.count == 1
    hash[jsonpaths.first] = row[i]
  else
    init_hash_rec(jsonpaths[1..-1], hash[jsonpaths.first], i, jsonpath_keys, row)
  end
  hash
end

def init_hash(jsonpaths, jsonpath_keys, row)
  first, *rest = jsonpaths.map.with_index do |path, i|
    init_hash_rec(path, Hash.new {|h,k| h[k] = Hash.new(&h.default_proc) }, i, jsonpath_keys, row)
  end
  rest.each { |r| first = deep_merge(first, r) }
  first
end

hash = df.map_rows { |r| init_hash(jsonpaths, path.keys, r) }
File.open("x.json", "w") { |file| file.write(JSON.pretty_generate(hash)) }