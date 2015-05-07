require 'aws-sdk'
require 'carrierwave/storage/aws_file'

module CarrierWave
  module Storage
    class AWS < Abstract
      def self.connection_cache
        @connection_cache ||= {}
      end

      def self.clear_connection_cache!
        @connection_cache = {}
      end

      def store!(file)
        AWSFile.new(uploader, connection, uploader.store_path).tap do |aws_file|
          aws_file.store(file)
        end
      end

      def retrieve!(identifier)
        AWSFile.new(uploader, connection, uploader.store_path(identifier))
      end

      def connection
        @connection ||= begin
          self.class.connection_cache[credentials] ||= ::Aws::S3::Client.new(
            region: credentials[:region],
            credentials: Aws::Credentials.new(credentials[:access_key_id], credentials[:secret_access_key])
          )
        end
      end

      def credentials
        [uploader.aws_credentials].compact.first
      end
    end
  end
end
