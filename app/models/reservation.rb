class Reservation < ActiveRecord::Base
  belongs_to :listing
  belongs_to :guest, :class_name => "User"
  has_one :review

  validates :checkin, presence: true
  validates :checkout, presence: true

  before_validation :guest_not_host
  #validates :checkin, if: :listing_available

  def listing_available
    #binding.pry
    conflicts = self.listing.reservations.select {|reservation| reservation.falls_within_date_range(self.checkin, self.checkout)}
    conflicts.length == 0
  end

  def guest_not_host
    self.guest.nil? || self.listing.host_id != self.guest.id
  end

  def checkin_within_date_range(start_date, end_date)
    self.checkin.to_datetime >= start_date.to_datetime && self.checkin.to_datetime <= end_date.to_datetime
  end

  def checkout_within_date_range(start_date, end_date)
    self.checkout.to_datetime >= start_date.to_datetime && self.checkout.to_datetime <= end_date.to_datetime
  end

  def falls_within_date_range(start_date, end_date)
    self.checkin_within_date_range(start_date, end_date) || self.checkout_within_date_range(start_date, end_date)
  end

end
