class Notifier
  EXPIRATION_IN_SECONDS = 5 
  
	# GTK standard icons
  SUCCESS_ICON = "gtk-dialog-info"
  FAILURE_ICON = "gtk-dialog-error"
  WARNING_ICON = "gtk-dialog-warning"

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
  def notify_send icon, title, message
    options = "-t #{EXPIRATION_IN_SECONDS * 1000} -i #{icon}"
    system "notify-send #{options} '#{title}' '#{message}'"
  end

end

