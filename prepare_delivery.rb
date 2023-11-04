require 'date'
require 'ostruct'

class PrepareDelivery
  TRUCKS = { kamaz: 3000, gazel: 1000 }.freeze

  def initialize(order)
    @order = order
  end

  def perform(destination_address, delivery_date)
    result = { truck: nil, weight: nil, order_number: order.id, address: destination_address, status: :ok }

    validate_delivery_date!(delivery_date)
    destination_address.validate!

    weight = order.total_weight
    result[:truck] = pick_truck(weight)
  rescue ValidationError
    result[:status] = 'error'
  end

  private

  attr_reader :order

  def validate_delivery_date!(delivery_date)
    raise ValidationError, 'Дата доставки уже прошла' if delivery_date < DateTime.now
  end

  def pick_truck(weight)
    truck = TRUCKS.keys.each { |key| key if TRUCKS[key.to_sym] > weight }
    return truck if truck

    raise ValidationError, 'Нет машины'
  end
end

class Order
  def id
    'id'
  end

  def products
    [OpenStruct.new(weight: 20), OpenStruct.new(weight: 40)]
  end

  def total_weight
    products.map(&:weight).sum
  end
end

class Address
  def city
    'Ростов-на-Дону'
  end

  def street
    'ул. Маршала Конюхова'
  end

  def house
    'д. 5'
  end

  def validate!
    return unless city.empty? || street.empty? || house.empty?

    raise ValidationError, 'Нет адреса'
  end
end

class ValidationError < StandardError; end

PrepareDelivery.new(Order.new).perform(Address.new, DateTime.now + 1)
