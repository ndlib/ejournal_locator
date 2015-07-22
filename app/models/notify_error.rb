module NotifyError
  def self.call(exception, args = {})
    if args.present?
      Airbrake.notify(exception, parameters: { args: args })
    else
      Airbrake.notify(exception)
    end
  end
end
