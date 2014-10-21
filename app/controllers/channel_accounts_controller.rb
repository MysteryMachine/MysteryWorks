class ChannelAccountsController < ApplicationController
  respond_to :json
  load_and_authorize_resource
  
  def show
    render :json => @channel_account
  end
  
  def rest
    if @channel_account.rest
      render :json => @channel_account, :status => 200
    else
      render :json => @channel_account, :status => 403
    end
  end
  
  def donate_blood
    if @channel_account.donate_blood
      render :json => @channel_account, :status => 200
    else
      render :json => @channel_account, :status => 403
    end
  end
  
  def bet
    if @channel_account.bet(params[:amount], params[:enemy_id])
      render :json => @channel_account, :status => 200
    else
      render :json => @channel_account, :status => 403
    end
  end
end