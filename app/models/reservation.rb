class Reservation < ActiveRecord::Base
  belongs_to :listing
  belongs_to :guest, :class_name => "User"
  has_one :review

  validates :checkin, presence: true
  validates :checkout, presence: true
  #validate :listing_available,
  #validates :listing_available

  before_validation :guest_not_host
  validate :listing_available
  #validates :checkin, presence: true, if: :listing_available

  def listing_available
    # TODO - this method should check against all listings, not itself!!
    self.checkin.nil? || self.checkout.nil? || !self.listing.has_date_conflict(self.checkin, self.checkout)
    binding.pry
    # conflicts = self.listing.reservations.select {|reservation| reservation.falls_within_date_range(self.checkin, self.checkout)}
    # conflicts.length == 0
    #binding.pry
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
