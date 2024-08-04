# frozen_string_literal: true

module WebhookJobs
  class UserDetailsNotification < ActiveJob::Base
    queue_as :default

    def perform(params)
      Webhook::UserNotifier.new(params).notify
    end
  end
end
