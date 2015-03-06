# == Schema Information
#
# Table name: people
#
#  id         :integer          not null, primary key
#  email      :string
#  phone      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Person < ActiveRecord::Base
  has_one :location
  has_one :district, through: :location
  has_one :representative, through: :district
  has_one :target_rep, -> { targeted }, through: :district
  has_one :state, through: :location
  has_many :senators, through: :state
  has_many :calls, class_name: 'Ivr::Call'
  has_many :connections, through: :calls
  has_many :called_legislators, through: :calls

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email, uniqueness: { case_sensitive: false },
                    format: { with: VALID_EMAIL_REGEX },
                    allow_nil: true

  validates :email, presence: true, if: "phone.nil?"
  validates :phone, presence: true, if: "email.nil?"

  before_save :downcase_email
  after_save :update_nation_builder

  alias_method :location_association, :location
  delegate :update_location, :zip_code, :city, :address_1, to: :location

  def location
    location_association || build_location
  end

  def address_required?
    district.blank?
  end

  def legislators
    if district
      district.legislators
    elsif state
      state.senators
    end
  end

  def constituent_of?(legislator)
    legislators.include?(legislator) if legislators
  end

  def next_target
    (target_legislators - called_legislators).first
  end

  def unconvinced_legislators
    if district
      district.unconvinced_legislators
    elsif state
      state.senators.eligible.unconvinced
    else
      []
    end
  end

  def other_targets(count: Ivr::Call::MAXIMUM_CONNECTIONS, excluding: nil)
    num_to_fetch = count - excluding.count
    Legislator.default_targets(excluding: excluding, count: num_to_fetch)
  end

  def target_legislators(json: false, count: Ivr::Call::MAXIMUM_CONNECTIONS)
    locals = unconvinced_legislators
    others = other_targets(count: count, excluding: locals)
    if json
      locals.as_json('local' => true) + others.as_json('local' => false)
    else
      locals + others
    end
  end

  private

  def update_nation_builder
    relevant_fields = changed & ["email" , "phone"]
    if relevant_fields.any?
      NbPersonPushJob.perform_later(self.slice(:email, *relevant_fields))
    end
  end

  def downcase_email
    email && self.email = email.downcase
  end
end
