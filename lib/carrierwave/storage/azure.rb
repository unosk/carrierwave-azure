require 'azure'

module CarrierWave
  module Storage
    class Azure < Abstract
      def store!(file)
        azure_file = CarrierWave::Storage::Azure::File.new(uploader, connection, uploader.store_path)
        azure_file.store!(file)
        azure_file
      end

      def retrieve!(identifer)
        CarrierWave::Storage::Azure::File.new(uploader, connection, uploader.store_path(identifer))
      end

      def connection
        @connection ||= begin
          uploader.azure_credentials.map do |key, val|
            ::Azure.config.send("#{key}=", val)
          end unless uploader.azure_credentials.nil?

	  unless uploader.azure_host.nil?
            ::Azure.config.storage_blob_host = uploader.azure_host
            ::Azure.config.storage_table_host= uploader.azure_host
            ::Azure.config.storage_queue_host= uploader.azure_host
          end 
          ::Azure::BlobService.new
        end
      end

      class File
        attr_reader :path

        def initialize(uploader, connection, path)
          @uploader = uploader
          @connection = connection
          @path = path
        end

        def store!(file)
          @content = file.read
          @content_type = file.content_type
          @connection.create_block_blob @uploader.azure_container, @path, @content, content_type: @content_type
          true
        end

        def url(options = {})
          path = ::File.join @uploader.azure_container, @path
          if @uploader.azure_host
            "#{@uploader.azure_host}/#{path}"
          else
            @connection.generate_uri(path).to_s
          end
        end

        def read
          content
        end

        def content_type
          @content_type = blob.properties[:content_type] if @content_type.nil? && !blob.nil?
          @content_type
        end

        def content_type=(new_content_type)
          @content_type = new_content_type
        end

        def exitst?
          blob.nil?
        end

        def size
          blob.properties[:content_length] unless blob.nil?
        end

        def filename
          URI.decode(url).gsub(/.*\/(.*?$)/, '\1')
        end

        def extension
          @path.split('.').last
        end

        def delete
          begin
            @connection.delete_blob @uploader.azure_container, @path
            true
          rescue ::Azure::Core::Http::HTTPError
            false
          end
        end

        private

        def blob
          load_content if @blob.nil?
          @blob
        end

        def content
          load_content if @content.nil?
          @content
        end

        def load_content
          @blob, @content = begin
            @connection.get_blob @uploader.azure_container, @path
          rescue ::Azure::Core::Http::HTTPError
          end
        end
      end
    end
  end
end
