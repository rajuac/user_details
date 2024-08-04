# frozen_string_literal: true

module Webhook
  class UserNotifier
    attr_accessor :params

    def initialize(params)
      @params = params
    end

    def notify
      webhook = WebhookLog.where(user_id: params[:user_id], event_type: params[:event_type]).first_or_create!
      return unless webhook.retry_count < 4

      begin
        HTTParty.post(webhook_url, body: payload.to_json, headers: {
                        'Content-Type' => 'application/json',
                        'X-Webhook-Signature' => signature
                      })
        webhook.status = 'Success'
      rescue StandardError => e 
        webhook.status = 'Failed'
        webhook.retry_count += 1
        WebhookJobs::UserDetailsNotification.perform_later(params)
      end
      webhook.save
    end

    private

    def webhook_url
      secrets[:webhook][:user_details_url]
    end

    def user
      @user ||= User.find_by(id: params[:user_id])
    end

    def payload
      {
        user_details: user.as_json,
        event_type: params[:event_type],
        event_source: 'UserDetailsService'
      }
    end

    def signature
      OpenSSL::HMAC.hexdigest('SHA256', webhook_secret, payload.to_json)
    end

    def webhook_secret
      secrets[:webhook][:webhook_key]
    end

    def secrets
      @secrets ||= Rails.application.secrets
    end
  end
end
