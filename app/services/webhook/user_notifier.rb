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
        HTTParty.post(webhook_url, body: build_body)
        webhook.status = 'Success'
      rescue StandardError
        webhook.status = 'Failed'
        webhook.retry_count += 1
        WebhookJobs::UserDetailsNotification.perform_later(params)
      end
      webhook.save
    end

    private

    def webhook_url
      'https://webhook-test.com/ab02b15badf450f8fd60e58396bb4322'
    end

    def user
      @user ||= User.find_by(id: params[:user_id])
    end

    def build_body
      {
        user_details: user.as_json,
        event_type: params[:event_type],
        event_source: 'UserDetailsService'
      }
    end
  end
end
