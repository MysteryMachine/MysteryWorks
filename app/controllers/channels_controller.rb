class ChannelsController < ApplicationController
  respond_to :json
  load_and_authorize_resource :except => [:create, :show]
  authorize_resource :only => [:create, :show]
  
  def create
    if current_user.request_channel
      render :json => current_user.channel, :status => 200
    else
      render :nothing => true , :status => 400
    end
  end
  
  def show
    @user = User.where(:name => params[:name]).first
    @channel = @user ? @user.channel : nil
    
    if @channel
      # If the user exists and does not have a channel
      if !current_user.nil? && @channel.find_channel_account(current_user).nil?
        current_user.channel_account_for(@channel) 
      end
      
      render :json => @channel
    else
      render :nothing => true, :status => 400
    end
  end
  
  def set_inactive
    if @channel.set_inactive
      render :json => @channel, :status => 200
    else
      render :json => @channel, :status => 403
    end
  end
  
  def open_betting
    if @channel.open_betting
      render :json => @channel, :status => 200
    else
      render :json => @channel, :status => 403
    end
  end
  
  def close_betting
    if @channel.close_betting
      render :json => @channel, :status => 200
    else
      render :json => @channel, :status => 403
    end
  end
  
  def complete_betting
    if @channel.complete_betting(params[:enemy_id])
      render :json => @channel, :status => 200
    else
      render :json => @channel, :status => 403
    end
  end
end