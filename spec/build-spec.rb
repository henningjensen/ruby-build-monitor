require 'build'

describe Build do

	it "should return true when status matches" do
		build = Build.new(Status::SUCCESS, "Build successful")
		build.is(Status::SUCCESS).should be_true
	end

	it "should return false when status does not match" do
		build = Build.new(Status::SUCCESS, "Build successful")
		build.is(Status::FAILURE).should be_false
	end

end
