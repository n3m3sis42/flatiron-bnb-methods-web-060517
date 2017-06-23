class Neighborhood < ActiveRecord::Base
  belongs_to :city
  has_many :listings

  def reservations
    self.listings.map {|listing| listing.reservations}.flatten
  end

  def neighborhood_openings(start_date, end_date)
      conflicts = self.reservations.select {|reservation| reservation.falls_within_date_range(start_date, end_date)}
      openings = self.listings.select {|listing| !listing.has_date_conflict(conflicts)}
  end

  def res_to_listings_ratio
    self.listings.length.zero? ? 0 : self.reservations.count.to_f / self.listings.count.to_f
  end

  def self.highest_ratio_res_to_listings
    neighborhoods_and_ratios = self.all.each_with_object([]) {|neighborhood, neighborhood_array|
      neighborhood_array << {neighborhood => neighborhood.res_to_listings_ratio}}
    neighborhoods_and_ratios.sort_by {|neighborhood_and_ratio| neighborhood_and_ratio.values.first}.last.keys.first
  end

  def self.most_res
    neighborhoods_and_reservations = self.all.each_with_object([]) {|neighborhood, neighborhood_array|
      neighborhood_array << {neighborhood => neighborhood.reservations.count}}
    neighborhoods_and_reservations.sort_by {|neighborhood_and_reservations| neighborhood_and_reservations.values.first}.last.keys.first
  end


end
