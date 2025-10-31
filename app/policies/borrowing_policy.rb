class BorrowingPolicy < ApplicationPolicy
  def index?
    # Members can see their own borrowings, librarians can see all
    true
  end

  def show?
    # Users can see their own borrowings, librarians can see all
    user.librarian? || record.user == user
  end

  def create?
    # Only members can create borrowings
    user.member?
  end

  def update?
    # Only librarians can update borrowings (for returns)
    user.librarian?
  end

  def destroy?
    # Only librarians can delete borrowings
    user.librarian?
  end

  def overdue?
    # Same as index - members see their own, librarians see all
    true
  end

  class Scope < Scope
    def resolve
      if user.librarian?
        scope.all
      else
        scope.where(user: user)
      end
    end
  end
end
