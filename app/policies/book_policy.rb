class BookPolicy < ApplicationPolicy
  def index?
    # Both members and librarians can view books
    true
  end

  def show?
    # Both members and librarians can view a book
    true
  end

  def create?
    # Only librarians can create books
    user.librarian?
  end

  def update?
    # Only librarians can update books
    user.librarian?
  end

  def destroy?
    # Only librarians can delete books
    user.librarian?
  end

  class Scope < Scope
    def resolve
      # Everyone can see all books
      scope.all
    end
  end
end
