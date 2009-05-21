class Build
<<<<<<< HEAD:build.rb
	attr_reader :status, :message
=======
	attr_reader :message
>>>>>>> 6f9e6fab062f250bafde8e53537be7166390c516:build.rb

	def initialize(status, message)
		@status, @message = status, message
	end

	def is(status)
		@status == status
	end

end
<<<<<<< HEAD:build.rb
=======

>>>>>>> 6f9e6fab062f250bafde8e53537be7166390c516:build.rb
class Status
	SUCCESS=1
	FAILURE=2
	UNKNOWN=3
end
