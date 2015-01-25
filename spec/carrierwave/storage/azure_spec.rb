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
    let(:stored_file) do
      allow(uploader).to receive(:store_path).and_return('test/dummy.png')
      tempfile = Tempfile.new 'test.jpg'
      open(tempfile.path, 'w') do |f|
        f.print '1234567890'
      end
      storage.store! CarrierWave::SanitizedFile.new(
        tempfile:     tempfile,
        filename:     'test.jpg',
        content_type: 'image/png'
      )
    end

    let(:retrieved_file) do
      storage.retrieve! stored_file.path
    end

    it 'should have a path' do
      expect(subject.path).to eq 'test/dummy.png'
    end

    it 'should have a url' do
      url = subject.url
      expect(url).to match /^https?:\/\//
      expect(open(url).read).to eq '1234567890'
    end

    it 'should have a content' do
      expect(subject.read).to eq '1234567890'
    end

    it 'should have a content_type' do
      expect(subject.content_type).to eq 'image/png'
    end

    it 'should have a size' do
      expect(subject.size).to eq 10
    end

    it 'should have a filename' do
      expect(subject.filename).to eq 'dummy.png'
    end

    it 'should have an extension' do
      expect(subject.extension).to eq 'png'
    end

    it 'should be deletable' do
      subject.delete
      expect{open subject.url}.to raise_error OpenURI::HTTPError
    end
  end

  describe '#store!' do
    it_should_behave_like 'an expected return value' do
      subject { stored_file }
    end
  end

  describe '#retrieve' do
    it_should_behave_like 'an expected return value' do
      subject { retrieved_file }
    end
  end
end
