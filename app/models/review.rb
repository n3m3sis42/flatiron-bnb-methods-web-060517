class Review < ActiveRecord::Base
  belongs_to :reservation
  belongs_to :guest, :class_name => "User"

   validates :rating, :description, :reservation, presence: true
   validate :checkout_happened

  def checkout_happened
    if self.reservation && self.reservation.checkout > Time.now
      self.errors.add(:reservation_id, "This checkout hasn't happened yet!")
    end
  end

end
