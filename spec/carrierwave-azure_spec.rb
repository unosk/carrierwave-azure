require 'spec_helper'

describe CarrierWave::Uploader::Base do
  it 'should define azure as a storage engine' do
    expect(described_class.storage_engines[:azure]).to eq 'CarrierWave::Storage::Azure'
  end

  it 'should define azure options' do
    is_expected.to respond_to(:azure_storage_account_name)
    is_expected.to respond_to(:azure_storage_access_key)
    is_expected.to respond_to(:azure_storage_blob_host)
    is_expected.to respond_to(:azure_container)
  end
end
