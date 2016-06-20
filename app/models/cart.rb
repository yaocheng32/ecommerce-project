class Cart < ActiveRecord::Base
  has_many :cart_items
  has_many :items, through: :cart_items, source: :product

  def add_product_to_cart(product)
    self.items << product
  end

  def total_price
    self.cart_items.reduce(0) { |acc, item| acc + item.product.price * item.quantity }
  end

  def clean!
    self.cart_items.destroy_all
  end

  def find_cart_item(product)
    self.cart_items.find_by(product_id: product)
  end
end
