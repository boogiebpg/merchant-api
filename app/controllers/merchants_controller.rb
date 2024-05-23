# frozen_string_literal: true

class MerchantsController < ApplicationController
  before_action :merchant, except: %i[index new create]

  def index
    @merchants = User::Merchant.all
  end

  def show; end

  def new; end

  def edit; end

  def update
    if merchant.update(merchant_params)
      redirect_to root_path, notice: 'Updated Successfully!'
    else
      flash.now.alert = merchant.errors.full_messages
      render :edit
    end
  end

  def create
    @new_merchant = User::Merchant.new(merchant_params)
    if @new_merchant.save
      redirect_to root_path, notice: 'Created Successfully!'
    else
      flash.alert = @new_merchant.errors.full_messages
      redirect_back(fallback_location: merchants_path)
    end
  end

  def destroy
    merchant.destroy
    redirect_to root_path
  end

  private

  def merchant_params
    params.require(:user_merchant).permit(:name, :email, :password, :description)
  end

  def merchant
    @merchant ||= User::Merchant.find(params[:id])
  end
end
