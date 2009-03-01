require 'notifier'

describe Notifier do

	it "should send success notification when build was successful" do
		build_message = "EXAMPLE-TRUNK built successfully in 3 minutes"
		notifier = Notifier.new
		notifier.should_receive(:notify_send).with(Notifier::SUCCESS_ICON, "Build successful", build_message)
		notifier.notify(Build.new(Status::SUCCESS, build_message))
	end

	it "should send failure notification when build faild" do
		build_message = "EXAMPLE-TRUNK build failed"
		notifier = Notifier.new
		notifier.should_receive(:notify_send).with(Notifier::FAILURE_ICON, "Build failed", build_message)
		notifier.notify(Build.new(Status::FAILURE, build_message))
	end

	it "should send warning notification when uknown build status" do
		build_message = "EXAMPLE-TRUNK was not built due to an error"
		notifier = Notifier.new
		notifier.should_receive(:notify_send).with(Notifier::WARNING_ICON, "Build result unknown", build_message)
		notifier.notify(Build.new(Status::UNKNOWN, build_message))
	end

end
