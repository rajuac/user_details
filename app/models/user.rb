# frozen_string_literal: true

class User < ApplicationRecord
  validates_presence_of :name, :email, :mobile
  validates_uniqueness_of :email
  validates_uniqueness_of :mobile
end
