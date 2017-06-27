class User < ActiveRecord::Base
  has_many :listings, :foreign_key => 'host_id'
  has_many :reservations, :through => :listings
  has_many :trips, :foreign_key => 'guest_id', :class_name => "Reservation"
  has_many :reviews, :foreign_key => 'guest_id'

  def hosts
   self.reviews.each_with_object([]) do |review, hosts_array|
     hosts_array << review.reservation.listing.host
   end
  end

  def guests
    reservations = self.listings.map do |listing|
      listing.reservations
    end.flatten
    reservations.map do |reservation|
      reservation.guest
    end.flatten
  end

  def host_reviews
    self.listings.map do |listing|
      listing.reviews
    end.flatten
  end

end
