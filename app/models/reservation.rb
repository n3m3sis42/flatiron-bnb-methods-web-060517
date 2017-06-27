class Reservation < ActiveRecord::Base
  belongs_to :listing
  belongs_to :guest, :class_name => "User"
  has_one :review
  validates :checkin, :checkout, presence: true
  after_validation :guest_not_host, :listing_available, :checkin_before_checkout, on: [:create, :update]

  def listing_available
    available_at_checkin?
    available_at_checkout?
  end

  def available_at_checkin?
    # puts "Checkin: #{self.checkin}, Checkout: #{self.checkout.class}"
    if self.checkin == nil || self.checkout == nil
      self.errors.add(:checkout, "Need checkout")
    else
      conflicts = self.listing.reservations.map do |reservation|
        if (self.checkin >= reservation.checkin && self.checkin <= reservation.checkout)
          reservation.listing
        else
          nil
        end
      end.compact
      self.errors.add(:checkin, "Date conflicts") if conflicts.length>0
    end
  end

  def available_at_checkout?
    # puts "Checkin: #{self.checkin}, Checkout: #{self.checkout.class}"
    if self.checkin == nil || self.checkout == nil
      self.errors.add(:checkout, "Need checkout")
    else
      conflicts = self.listing.reservations.map do |reservation|
        if (self.checkout >= reservation.checkin && self.checkout <= reservation.checkout)
          reservation.listing
        else
          nil
        end
      end.compact
      self.errors.add(:checkout, "Date conflicts") if conflicts.length>0
    end
  end

  def checkin_before_checkout
    if self.checkin != nil && self.checkout != nil
      if self.checkin >= self.checkout
        self.errors.add(:checkin, "Checkin needs to be before checkout")
      end
    else
      self.errors.add(:checkin, "Checkin or checkout is nil")
    end
  end

  def guest_not_host
    if self.guest_id == self.listing.host_id
      self.errors.add(:guest_id, "You're not allowed to rent your own room.")
    end
  end

  def checkin_within_date_range(start_date, end_date)
    if self.checkin != nil
      self.checkin >= start_date && self.checkin <= end_date
    else
      false
    end
  end

  def checkout_within_date_range(start_date, end_date)
    if self.checkout != nil
      self.checkout >= start_date && self.checkout <= end_date
    else
      false
    end
  end

  def falls_within_date_range(start_date, end_date)
    self.checkin_within_date_range(start_date, end_date) || self.checkout_within_date_range(start_date, end_date)
  end

  def duration
    (self.checkout - self.checkin)
  end

  def total_price
    self.duration * self.listing.price
  end

  def no_checkin_conflicts(start_date, end_date)
    if self.checkin == nil
      return false
      self.errors.add(:checkin, "Invalid checkin")
    elsif self.checkin >= start_date && self.checkin<= end_date
      return false
    else
      return true
    end
  end

  def no_checkout_conflicts(start_date, end_date)
    if self.checkout >= start_date && self.checkout <= end_date
      return false
    else
      return true
    end
  end

  def valid_checkin(start_date, end_date)
    if self.checkin < start_date || self.checkin > end_date
      return true
    else
      return false
    end
  end

  def valid_checkout(start_date, end_date)
    if self.checkout < start_date || self.checkout > end_date
      return true
    else
      return false
    end
  end


end
