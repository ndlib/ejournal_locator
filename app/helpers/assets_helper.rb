module AssetsHelper
  include HesburghAssets::AssetsHelper

  def application_name
    Rails.configuration.application_name
  end
end
