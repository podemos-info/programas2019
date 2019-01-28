# frozen_string_literal: true

require "omniauth-openid"
require "open-uri"

module OmniAuth
  module Strategies
    class Participa < OmniAuth::Strategies::OpenID
      args [:identifier]

      option :name, :participa
      option :client_options, {}
      option :required, %w(email first_name last_name town phone verified)

      uid do
        raw_info[:id]
      end

      info do
        {
          email: raw_info[:email],
          name: raw_info[:name],
          vote_town: raw_info[:vote_town],
          phone: raw_info[:phone],
          verified: raw_info[:verified]
        }
      end

      def raw_info
        @raw_info ||= {
          id: openid_response.identity_url.split("/").last,
          email: message.get_arg("http://openid.net/extensions/sreg/1.1", "email"),
          name: anonymized_name,
          vote_town: message.get_arg("http://openid.net/extensions/sreg/1.1", "town"),
          phone: message.get_arg("http://openid.net/extensions/sreg/1.1", "phone"),
          verified: message.get_arg("http://openid.net/extensions/sreg/1.1", "verified")
        }
      end

      private

      def anonymized_name
        [
          message.get_arg("http://openid.net/extensions/sreg/1.1", "first_name"),
          message.get_arg("http://openid.net/extensions/sreg/1.1", "last_name")[0].upcase + "."
        ].join " "
      end

      def message
        @message ||= openid_response.message
      end
    end
  end
end

# Add extra fields to SReg
module OpenID
  module SReg
    DATA_FIELDS.merge!("town" => "Town", "first_name" => "First Name", "last_name" => "Last name", "phone" => "Phone", "verified" => "Verified")
  end
end
