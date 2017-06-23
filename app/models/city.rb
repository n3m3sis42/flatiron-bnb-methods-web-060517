class City < ActiveRecord::Base
  has_many :neighborhoods
  has_many :listings, :through => :neighborhoods

  def reservations
    self.listings.map {|listing| listing.reservations}.flatten
  end

  def city_openings(start_date, end_date)
    conflicts = self.reservations.select {|reservation| reservation.falls_within_date_range(start_date, end_date)}
    openings = self.listings.select {|listing| !listing.has_date_conflict(conflicts)}
  end

  def res_to_listings_ratio
    self.listings.length.zero? ? 0 : self.reservations.count.to_f / self.listings.count.to_f
  end

  def self.highest_ratio_res_to_listings
    cities_and_ratios = self.all.each_with_object([]) {|city, city_array|
      city_array << {city => city.res_to_listings_ratio}}
    cities_and_ratios.sort_by {|city_and_ratio| city_and_ratio.values.first}.last.keys.first
  end

  def self.most_res
    cities_and_reservations = self.all.each_with_object([]) {|city, city_array|
      city_array << {city => city.reservations.count}}
    cities_and_reservations.sort_by {|city_and_reservations| city_and_reservations.values.first}.last.keys.first
  end


end
