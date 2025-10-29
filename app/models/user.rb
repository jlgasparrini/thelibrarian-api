class User < ApplicationRecord
  # Soft delete
  acts_as_paranoid

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: JwtDenylist

  # Associations
  has_many :borrowings, dependent: :destroy

  # Role enum: member (default) and librarian
  enum :role, { member: 0, librarian: 1 }

  # Validations
  validates :email, presence: true, uniqueness: { scope: :deleted_at }
  validates :role, presence: true

  # Override Devise's active_for_authentication? to prevent deleted users from logging in
  def active_for_authentication?
    super && !deleted?
  end

  # Provide a custom message for deleted users trying to log in
  def inactive_message
    deleted? ? :deleted_account : super
  end
end
