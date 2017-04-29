class SeedSavingStatus < ApplicationRecord
  extend Enumerize

  enumerize :status, in: {
                         none: 0,
                         doing: 1,
                         done: 2,
                         error: 3
                     }, predicates: true

  has_many :model_saving_statuses, dependent: :destroy

  def update_seed_saving_status!
    if model_saving_statuses.all?{ |r| r.status.done? }
      self.status = :done
    elsif model_saving_statuses.any?{ |r| r.status.error? }
      self.status = :error
    end

    self.save!
  end
end
