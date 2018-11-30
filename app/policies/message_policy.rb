class MessagePolicy < ApplicationPolicy
  def edit?
    record.user == user
  end
end
