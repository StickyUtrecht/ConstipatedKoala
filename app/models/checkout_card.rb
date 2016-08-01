class CheckoutCard < ActiveRecord::Base
  validates :uuid, presence: true
  validates :member, presence: true
  validates :checkout_balance, presence: true
#  validates :active

#  is_impressionable

  has_many :checkout_transactions,
    :dependent => :destroy

  belongs_to :member
  belongs_to :checkout_balance

  devise :confirmable

  before_validation(on: :create) do
    self.active = false
    self.email = self.member.email

    #find balance otherwise create a new one
    balance = CheckoutBalance.find_or_create_by!(member: self.member)

    if balance.save
      self.checkout_balance = balance
    else
      return false
    end
  end
end
