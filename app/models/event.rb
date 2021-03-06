class Event < ApplicationRecord
  belongs_to :sport
  belongs_to :host, class_name: "User"

  include PgSearch
  pg_search_scope :search_full_text,
    against: [ :address ],
    associated_against: {
      sport: [ :name ]
    },
    using: {
      tsearch: { prefix: true },
    },
    order_within_rank: "events.updated_at DESC"

  has_many :reviews, dependent: :destroy
  has_many :bookings, dependent: :destroy

  monetize :price_cents

  validates :date, presence: true
  validates :max_players, presence: true

  def nice_date
    date.strftime("%b %d, %Y") if date
  end

  geocoded_by :address
  after_validation :geocode, if: :will_save_change_to_address?

  def spots_left
      max_players - bookings.where(status: "approved").count
  end

  def is_user_registered?(user)
    !bookings.where(user_id: user.id).blank?
  end

  def booking_pending?(user)
    bookings.exists?(user_id: user.id, status: "pending")
  end

  def booking_approved?(user)
    bookings.exists?(user_id: user.id, status: "approved")
  end

  def booking_rejected?(user)
    bookings.exists?(user_id: user.id, status: "rejected")
  end

  # def conversation_with(user)
  #   if Conversation.between(@event.host.id, current_user.id).present?
  #     @conversation = Conversation.between(@event.host.id, current_user.id).first
  #   else
  #    @conversation = Conversation.create!(recipient_id: @event.host.id, sender_id: current_user.id)
  #   end
  # end
end
