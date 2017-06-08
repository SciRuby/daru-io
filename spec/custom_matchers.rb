RSpec::Matchers.define :belong_to do |expected|
  match { |actual| (actual.to_a.uniq - expected.to_a.uniq).empty? }
end

RSpec::Matchers.define :contain_from do |expected|
  match do |actual|
    actual = actual.to_a.map { |x| x.data.to_a }.flatten.uniq
    expected.map!(&:values) unless expected.first.is_a? Array
    expected = expected.flatten.uniq
    (actual - expected).empty?
  end
end
