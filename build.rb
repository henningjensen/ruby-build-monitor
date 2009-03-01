class Build
	attr_reader :message

	def initialize(status, message)
		@status, @message = status, message
	end

	def is(status)
		@status == status
	end

end

class Status
	SUCCESS=1
	FAILURE=2
	UNKNOWN=3
end
