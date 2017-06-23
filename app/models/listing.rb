class Listing < ActiveRecord::Base
  belongs_to :neighborhood
  belongs_to :host, :class_name => "User"
  has_many :reservations
  has_many :reviews, :through => :reservations
  has_many :guests, :class_name => "User", :through => :reservations

  validates :address, presence: true
  validates :listing_type, presence: true
  validates :title, presence: true
  validates :description, presence: true
  validates :price, presence: true
  validates :neighborhood_id, presence: true

  before_save :update_host_status_to_true
  before_destroy :update_host_status_to_false

  def update_host_status_to_true
    self.host.host = true
    self.host.save
  end

  def self.find_all_for_host(host)
    self.all.select {|listing| listing.host == host}
  end

  def update_host_status_to_false
      if self.host.listings.size == 1
        self.host.host = false
        self.host.save
      end
  end

  def get_ratings
    self.reviews.map {|review| review.rating}
  end

  def average_review_rating
    self.get_ratings.inject(&:+).to_f / self.reviews.count
  end

  def has_date_conflict(conflicts)
    conflicts.find {|conflict| conflict.listing == self}
  end


end
