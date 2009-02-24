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
  # [status] array with build info: identifier,buildstate,summary,url
  def notify(status)
    message = "<a href=\"" + status[3] + "\">" + status[2] + "</a>"
    if status[1] =~ /Success/ 
      if @last_notification != SUCCESS 
        @last_notification = SUCCESS
        title = "Build success: #{status[0]}"
        notify_send SUCCESS_ICON, title, message
      end
    elsif status[1] =~ /Failed/
      @last_notification = FAILURE
      title = "Build failure: #{status[0]}"
      notify_send FAILURE_ICON, title, message
    else
      @last_notification = UNKNOWN
      title = title + " unknown build state"
      notify_send WARNING_ICON, title, message
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

