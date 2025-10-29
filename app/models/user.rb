class User < ApplicationRecord
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
  validates :email, presence: true, uniqueness: true
  validates :role, presence: true
end
