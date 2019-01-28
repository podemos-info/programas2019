# frozen_string_literal: true

load Decidim::Core::Engine.root.join("app/controllers/decidim/devise/omniauth_registrations_controller.rb")

module Decidim
  module Devise
    # This controller customizes the behaviour of Devise::Omniauthable.
    OmniauthRegistrationsController.class_eval do
      skip_before_action :verify_authenticity_token, only: :participa

      after_action do
        Decidim::Verifications::AuthorizeUser.call(handler) if valid_user?
      end

      private

      def valid_user?
        if phone.blank?
          error = :missing_phone
        elsif !verified?
          error = :not_verified
        end

        if error
          flash.delete(:notice)
          flash[:error] = I18n.t("participa.errors.#{error}")
          sign_out current_user
          return false
        end

        true
      end

      def handler
        @handler ||= Decidim::AuthorizationHandler.handler_for("participa_authorization_handler", user: current_user, participa_id: participa_id, vote_town: vote_town)
      end

      def participa_id
        @participa_id ||= oauth_data[:uid].to_i
      end

      def vote_town
        @vote_town ||= oauth_data.dig(:info, :vote_town)
      end

      def phone
        @phone ||= oauth_data.dig(:info, :phone)
      end

      def verified?
        return @verified if defined? @verified

        @verified = oauth_data.dig(:info, :verified) == "true"
      end
    end
  end
end
