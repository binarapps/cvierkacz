class MessagePolicy < ApplicationPolicy
  def edit?
    user_is_author?
  end

  def update?
    user_is_author?
  end

  def destroy?
    user_is_author?
  end

  private

  def user_is_author?
    record.user == user
  end
end
