class Order < ActiveRecord::Base
  belongs_to :user
  has_one :info, class_name: 'OrderInfo', dependent: :destroy
  has_many :items, class_name: 'OrderItem', dependent: :destroy

  accepts_nested_attributes_for :info

  include Tokenable

  def build_item_cache_from_cart(cart)
    cart.items.each do |cart_item|
      item = self.items.build
      item.product_name = cart_item.title
      item.quantity = cart.find_cart_item(cart_item).quantity
      item.price = cart_item.price
      item.save
    end
  end

  def calculate_total!(cart)
    self.update_column(:total, cart.total_price)
  end

  def set_payment_with!(method)
    self.update_column(:payment_method, method)
  end

  def pay!
    self.update_column(:is_paid, true)
  end

  include AASM

  aasm do
    state :order_placed, initial: true
    state :paid
    state :shipping
    state :shipped
    state :order_cancelled
    state :good_returned


    event :make_payment, after_commit: :pay! do
      transitions from: :order_placed, to: :paid
    end

    event :ship do
      transitions from: :paid,         to: :shipping
    end

    event :deliver do
      transitions from: :shipping,     to: :shipped
    end

    event :return_good do
      transitions from: :shipped,      to: :good_returned
    end

    event :cancell_order do
      transitions from: [:order_placed, :paid], to: :order_cancelled
    end
  end
end
