class Notifier
<<<<<<< HEAD:notifier.rb
  # Time notification will be displayed before disappearing automatically
  EXPIRATION_IN_SECONDS = 5 
  # GTK standard icons
=======
  EXPIRATION_IN_SECONDS = 5 
  
	# GTK standard icons
>>>>>>> 6f9e6fab062f250bafde8e53537be7166390c516:notifier.rb
  SUCCESS_ICON = "gtk-dialog-info"
  FAILURE_ICON = "gtk-dialog-error"
  WARNING_ICON = "gtk-dialog-warning"

<<<<<<< HEAD:notifier.rb
  def initialize
    @last_notification = nil
  end

  # Send a gnome notification
	# Expects a Build object
  def notify(build)
    if build.is(Status::SUCCESS)
			if @last_notifcation.nil? || @last_notification.is(Status::FAILURE)
      	title = "Build successful"
      	notify_send SUCCESS_ICON, title, build.message
			end
    else
			if build.is(Status::FAILURE)
      	title = "Build failed"
      	notify_send FAILURE_ICON, title, build.message
    	else
      	title = "Build result uknown" 
      	notify_send WARNING_ICON, title, build.message
    	end
		end
		@last_notification = build
  end

  # Convenience method to send an error notification message
  #
  # [stock_icon]   Stock icon name of icon to display
  # [title]        Notification message title
  # [message]      Core message for the notification
=======
	# Expects a Build object
  def notify(build)
    if build.is(Status::SUCCESS) 
      notify_send SUCCESS_ICON, "Build successful", build.message
    elsif build.is(Status::FAILURE)
      notify_send FAILURE_ICON, "Build failed", build.message
    else
      notify_send WARNING_ICON, "Build result unknown", build.message
    end
  end

	# display a notification using libnotify
>>>>>>> 6f9e6fab062f250bafde8e53537be7166390c516:notifier.rb
  def notify_send icon, title, message
    options = "-t #{EXPIRATION_IN_SECONDS * 1000} -i #{icon}"
    system "notify-send #{options} '#{title}' '#{message}'"
  end

end

