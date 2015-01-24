require 'spec_helper'

describe CarrierWave::Storage::Azure::File do
  class TestUploader < CarrierWave::Uploader::Base
    storage :azure
  end

  let(:uploader) { TestUploader.new }
  let(:storage)  { CarrierWave::Storage::Azure.new uploader }

  describe '#url' do
    before do
      allow(uploader).to receive(:azure_container).and_return('test')
    end

    subject { CarrierWave::Storage::Azure::File.new(uploader, storage.connection, 'dummy.txt').url }

    context 'with storage_blob_host' do
      before do
        allow(uploader).to receive(:azure_storage_blob_host).and_return('http://example.com')
      end

      it 'should return on asset_host' do
        expect(subject).to eq 'http://example.com/test/dummy.txt'
      end
    end

    context 'with asset_host' do
      before do
        allow(uploader).to receive(:asset_host).and_return('http://example.com')
      end

      it 'should return on asset_host' do
        expect(subject).to eq 'http://example.com/test/dummy.txt'
      end
    end
  end
end
