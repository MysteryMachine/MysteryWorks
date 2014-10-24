class ChannelsController < UncachedController
  respond_to :json
  load_and_authorize_resource
  
  def show
    if !current_user.nil? && @channel.find_channel_account(current_user).nil?
      current_user.channel_account_for(@channel) 
    end
    
    render :json => @channel
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