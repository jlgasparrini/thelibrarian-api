class UserSerializer
  def initialize(user)
    @user = user
  end

  def serializable_hash
    {
      data: {
        attributes: {
          id: @user.id,
          email: @user.email,
          role: @user.role,
          created_at: @user.created_at
        }
      }
    }
  end

  # Minimal version for nested responses
  def self.minimal(user)
    {
      id: user.id,
      email: user.email
    }
  end
end
