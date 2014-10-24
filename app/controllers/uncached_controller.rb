class UncachedController < ApplicationController
  private 
  def cors_set_access_control_headers
    super
    headers['Cache-Control']= 'no-cache, private'
  end

  def cors_preflight_check
    super
    headers['Cache-Control']= 'no-cache, private'
  end
end