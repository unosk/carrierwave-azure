require 'carrierwave'
require 'carrierwave/azure/version'
require 'carrierwave/storage/azure'

class CarrierWave::Uploader::Base
  add_config :azure_credentials
  add_config :azure_host
  add_config :azure_container

  configure do |config|
    config.storage_engines[:azure] = 'CarrierWave::Storage::Azure'
  end
end
