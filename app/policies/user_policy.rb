class UserPolicy < ApplicationPolicy
  def show?
    # Users can view their own profile
    user == record
  end

  def update?
    # Users can update their own profile
    user == record
  end

  def destroy?
    # Only librarians can delete users
    user.librarian?
  end

  def index?
    # Only librarians can list all users
    user.librarian?
  end

  class Scope < Scope
    def resolve
      if user.librarian?
        scope.all
      else
        scope.where(id: user.id)
      end
    end
  end
end
