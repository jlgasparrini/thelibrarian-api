class DashboardPolicy < ApplicationPolicy
  def show?
    # Both members and librarians can view their respective dashboards
    true
  end
end
