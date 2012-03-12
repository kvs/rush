require 'spec_helper'

describe Rush do
	it "has a shortcut to localhost" do
		Rush.local.should be_an_instance_of Rush::Box
	end

	it "quotes paths"

	it "returns entire library as a String" do
		Rush.library_data.should be_an_instance_of String
		Rush.library_data.size.should > 2000
	end
end
