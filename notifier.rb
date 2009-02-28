class GnomeNotifier
  # Time notification will be displayed before disappearing automatically
  EXPIRATION_IN_SECONDS = 2
  # GTK standard icons
  SUCCESS_ICON = "gtk-dialog-info"
  FAILURE_ICON = "gtk-dialog-error"
  WARNING_ICON = "gtk-dialog-warning"

  SUCCESS = 0
  FAILURE = 1
  UNKNOWN = 2

  def initialize
    @last_notification = nil
  end

  # Send a gnome notification
	# Expects a Build object
  def notify(build)
    if build.is(Status::SUCCESS) 
      title = "Build successful"
      notify_send SUCCESS_ICON, title, build.message
    elsif build.is(Status::FAILURE)
      title = "Build failed"
      notify_send FAILURE_ICON, title, build.message
    else
      title = "Build result uknown" 
      notify_send WARNING_ICON, title, build.message
    end
  end

  # Convenience method to send an error notification message
  #
  # [stock_icon]   Stock icon name of icon to display
  # [title]        Notification message title
  # [message]      Core message for the notification
  def notify_send icon, title, message
    options = "-t #{EXPIRATION_IN_SECONDS * 1000} -i #{icon}"
    system "notify-send #{options} '#{title}' '#{message}'"
  end

end

