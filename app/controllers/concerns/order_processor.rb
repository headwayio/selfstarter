class OrderProcessor
  attr_reader :user, :price, :payment_option_id
  attr_accessor :redirect_url

  def initialize(attrs = {})
    @user = attrs.fetch(:user)
    @callback_url = attrs.fetch(:callback_url)
    @payment_option_id = attrs.fetch(:payment_option_id)
  end

  def process
    price = determine_price

    order =
      Order.prefill!(
        name: Settings.product_name,
        price: price,
        user_id: user.id,
        payment_option: payment_option
      )

    self.redirect_url = process_order(price, order)
  end

  private

  def process_order(price, order)
    processed_order =
      AmazonFlexPay.multi_use_pipeline(
        order.uuid,
        callback_url,
        transaction_amount: price,
        global_amount_limit: price + Settings.charge_limit,
        collect_shipping_address: 'True',
        payment_reason: Settings.payment_description
      )

    processed_order.redirect_url
  end

  def determine_price
    if Settings.use_payment_options
      raise Exception, 'No payment option was selected' if payment_option_id.nil?
      payment_option = PaymentOption.find(payment_option_id)
      payment_option.amount
    else
      Settings.price
    end
  end
end
