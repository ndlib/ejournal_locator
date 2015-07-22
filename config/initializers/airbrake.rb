Airbrake.configure do |config|
  config.api_key = '137eff3dfc1930e1aed379e6022d44c2'
  config.host    = 'errbit.library.nd.edu'
  config.port    = 443
  config.secure  = config.port == 443
end
