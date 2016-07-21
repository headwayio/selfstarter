class PreorderController < ApplicationController
  skip_before_action :verify_authenticity_token, only: :ipn

  def index
  end

  def checkout
  end

  def prefill
    @user = User.find_or_create_by(email: params[:email])

    callback_url = "#{request.scheme}://#{request.host}#{port}/preorder/postfill"

    processed_order =
      OrderProcessor.new(
        user: @user,
        callback_url: callback_url,
        payment_option_id: params['payment_option']
      ).process

    redirect_to processed_order.redirect_url
  end

  def postfill
    @order = Order.postfill!(params) unless params[:callerReference].blank?
    # "A" means the user cancelled the preorder before clicking "Confirm" on Amazon Payments.
    if params['status'] != 'A' && @order.present?
      redirect_to action: :share, uuid: @order.uuid
    else
      redirect_to root_url
    end
  end

  def share
    @order = Order.find_by(uuid: params[:uuid])
  end

  def ipn
  end
end
