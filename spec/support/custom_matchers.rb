RSpec::Matchers.define :ordered_data do |expected|
  match do |actual|
    actual = actual.to_a.map { |x| x.data.to_a }
    actual == expected
  end
end
