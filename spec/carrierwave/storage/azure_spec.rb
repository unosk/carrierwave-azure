require 'spec_helper'
require 'tempfile'
require 'open-uri'

describe CarrierWave::Storage::Azure do
  class TestUploader < CarrierWave::Uploader::Base
    storage :azure
  end

  let(:uploader) { TestUploader.new }
  let(:storage)  { CarrierWave::Storage::Azure.new uploader }

  shared_examples_for 'an expected return value' do
    it 'should have a path' do
      expect(@azure_file.path).to eq expect_path
    end

    it 'should have a url' do
      url = @azure_file.url
      expect(url).to match /^https?:\/\//
      expect(open(url).read).to eq expect_content
    end

    it 'should have a content' do
      expect(@azure_file.read).to eq expect_content
    end

    it 'should have a content_type' do
      expect(@azure_file.content_type).to eq expect_content_type
    end

    it 'should have a size' do
      expect(@azure_file.size).to eq expect_size
    end

    it 'should have a filename' do
      expect(@azure_file.filename).to eq expect_filename
    end

    it 'should have an extension' do
      expect(@azure_file.extension).to eq expect_extension
    end

    it 'should be deletable' do
      @azure_file.delete
      expect{open @azure_file.url}.to raise_error OpenURI::HTTPError
    end
  end

  describe '#store!' do
    before do
      allow(uploader).to receive(:store_path).and_return('test/dummy1.png')
      tempfile = Tempfile.new 'test.jpg'
      open(tempfile.path, 'w') do |f|
        f.print '1234567890'
      end
      @azure_file = storage.store! CarrierWave::SanitizedFile.new(
        tempfile:     tempfile,
        filename:     'test.jpg',
        content_type: 'image/png'
      )
    end

    it_should_behave_like 'an expected return value' do
      let(:expect_path)         { 'test/dummy1.png' }
      let(:expect_content)      { '1234567890' }
      let(:expect_content_type) { 'image/png' }
      let(:expect_size)         { 10 }
      let(:expect_filename)     { 'dummy1.png' }
      let(:expect_extension)    { 'png' }
    end
  end

  describe '#retrieve' do
    before do
      allow(uploader).to receive(:store_path).and_return('test/dummy2.png')
      storage.connection.create_block_blob(
        uploader.azure_container,
        'test/dummy2.png',
        '0123456789ABCDEF',
        content_type: 'text/plain'
      )
      @azure_file = storage.retrieve! 'test/dummy2.png'
    end

    it_should_behave_like 'an expected return value' do
      let(:expect_path)         { 'test/dummy2.png' }
      let(:expect_content_type) { 'text/plain' }
      let(:expect_content)      { "0123456789ABCDEF" }
      let(:expect_size)         { 16 }
      let(:expect_filename)     { 'dummy2.png' }
      let(:expect_extension)    { 'png' }
    end
  end
end
