RSpec.describe Daru::IO::Importers::Redis do
	let(:connection) { Redis.new {} }
	subject { Daru::IO::Importers::Redis.new(connection, *keys).load }

  after { connection.flushdb }

  context "on array of keys having hashes" do
		before {
			connection.set "10001", { "name" => "Tyrion", "age" => 32 }.to_json
			connection.set "10002", { "name" => "Jamie", "age" => 37 }.to_json
			connection.set "10003", { "name" => "Cersei", "age" => 37 }.to_json
			connection.set "10004", { "name" => "Joffrey", "age" => 19 }.to_json			
		}

  	context "without key options" do
	  	let(:keys) { [] }

	    it { is_expected.to eq(Daru::DataFrame.new([{ "name" => "Tyrion", "age" => 32 }, { "name" => "Jamie", "age" => 37 }, { "name" => "Cersei", "age" => 37 }, { "name" => "Joffrey", "age" => 19 }], index: ["10001", "10002", "10003", "10004"])) }
	  end

	  context "with key options" do
	  	let(:keys) { ["10001","10002"] }

	    it { is_expected.to eq(Daru::DataFrame.new([{ "name" => "Tyrion", "age" => 32 }, { "name" => "Jamie", "age" => 37 }], index: ["10001", "10002"])) }
	  end
	end

  context "on keys having array of hashes" do
		before {
			connection.set "10001", [{ "name" => "Tyrion", "age" => 32 }, { "name" => "Jamie", "age" => 37 }].to_json
			connection.set "10003", [{ "name" => "Cersei", "age" => 37 }, { "name" => "Joffrey", "age" => 19 }].to_json
		}

  	context "without key options" do
	  	let(:keys) { [] }

	    it { is_expected.to eq(Daru::DataFrame.new([{ "name" => "Tyrion", "age" => 32 }, { "name" => "Jamie", "age" => 37 }, { "name" => "Cersei", "age" => 37 }, { "name" => "Joffrey", "age" => 19 }])) }
	  end

	  context "with key options" do
	  	let(:keys) { ["10001"] }

	    it { is_expected.to eq(Daru::DataFrame.new([{ "name" => "Tyrion", "age" => 32 }, { "name" => "Jamie", "age" => 37 }])) }
	  end
	end

  context "on hash keys having arrays" do
		before {
			connection.set "name", ["Tyrion", "Jamie", "Cersei", "Joffrey"]
			connection.set "age", [32, 37, 37, 19]
			connection.set "living", [true, true, true, false]
		}

  	context "without key options" do
	  	let(:keys) { [] }

	    it { is_expected.to eq(Daru::DataFrame.new([{ "name" => "Tyrion", "age" => 32, "living" => true }, { "name" => "Jamie", "age" => 37, "living" => true }, { "name" => "Cersei", "age" => 37, "living" => true }, { "name" => "Joffrey", "age" => 19, "living" => false }])) }
	  end

	  context "with key options" do
	  	let(:keys) { ["name", "age"] }

	    it { is_expected.to eq(Daru::DataFrame.new([{ "name" => "Tyrion", "age" => 32 }, { "name" => "Jamie", "age" => 37 }, { "name" => "Cersei", "age" => 37 }, { "name" => "Joffrey", "age" => 19 }])) }
	  end
	end
end