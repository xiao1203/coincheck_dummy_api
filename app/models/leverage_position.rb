class LeveragePosition < ApplicationRecord
  belongs_to :user, dependent: :destroy
end
