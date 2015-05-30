class Admins::SettingsController < ApplicationController
  respond_to :json, only: [:destroy]

  def index 
    @advert = Advertisement.new
    @advertisements = Advertisement.all
  end
  
  def advertisement
    @advert = Advertisement.new(advertisement_post_params)   
    
    if @advert.save
      redirect_to apps_radio_path
    else
      @advertisements = Advertisement.all
      render 'radio'
    end
  end
  
  def destroy     
    if params[:id].blank?
      render :status => :bad_request, :json => 'no id given'
    end
      
    advert = Advertisement.find(params[:id])
    advert.destroy
    
    render :status => :no_content, :json => ''
  end
end