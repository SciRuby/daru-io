RSpec::Matchers.define :be_boolean do
  match do |actual|
    [true, false].include?(actual)
  end
end

RSpec::Matchers.define :ordered_data do |expected|
  match do |actual|
    actual = actual.to_a.map { |x| x.data.to_a }
    actual == expected
  end
end
