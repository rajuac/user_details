# frozen_string_literal: true

class UserDetailsNotifier
  attr_accessor :params

  def initialize(params)
    @params = params
  end

  def notify
    Webhook::UserNotifier.new(params).notify
  end
end
