# frozen_string_literal: true

require "omniauth-openid"
require "open-uri"

module OmniAuth
  module Strategies
    class Participa < OmniAuth::Strategies::OpenID
      args [:identifier]

      option :name, :participa
      option :client_options, {}
      option :required, ["email", "fullname", "town"]

      uid do
        raw_info[:id]
      end

      info do
        {
          email: raw_info[:email],
          name: raw_info[:name],
          vote_town: raw_info[:vote_town]
        }
      end

      def raw_info
        @raw_info ||= {
          id: openid_response.identity_url.split("/").last,
          email: message.get_arg("http://openid.net/extensions/sreg/1.1", "email"),
          name: message.get_arg("http://openid.net/extensions/sreg/1.1", "fullname"),
          vote_town: message.get_arg("http://openid.net/extensions/sreg/1.1", "town")
        }
      end

      private

      def message
        @message ||= openid_response.message
      end
    end
  end
end

# Add extra fields to SReg
module OpenID
  module SReg
    DATA_FIELDS.merge!({
      'town' => 'Town',
    })
  end
end