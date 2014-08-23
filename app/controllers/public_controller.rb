class PublicController < ApplicationController
  skip_before_action :authenticate_admin!, only: [:index, :create]
  layout nil
  
  @@intro = {
    'lidmaatschap' => 1,
    'lasergamen' => 2,
    'bbq' => 3,
  }
  
  def index
    @member = Member.new
    @member.educations.build( :id => '-1' )
    @member.educations.build( :id => '-2' )
  end

  def create
    @member = Member.new(public_post_params)
    
    if @member.save
      flash[:notice] = 'Je hebt je ingeschreven!'
      
      @lidmaatschap = Participant.new( :member => @member, :activity => Activity.find(@@intro['lidmaatschap']))
      if !@lidmaatschap.save
        logger.error "#{@member.first_name} #{@member.infix} #{@member.last_name} not added to #{@lidmaatschap.activity.name}"
      end
      
      if !params[:activities].nil?      
        if params[:activities].include? 'bbq'
          @bbq = Participant.new( :member => @member, :activity => Activity.find(@@intro['bbq']))
          if !@bbq.save
            logger.error "#{@member.first_name} #{@member.infix} #{@member.last_name} not added to #{@lidmaatschap.activity.name}"        
          end
        end
              
        if params[:activities].include? 'lasergamen'
          @lasergamen = Participant.new( :member => @member, :activity => Activity.find(@@intro['lasergamen']))
          if !@lasergamen.save
            logger.error "#{@member.first_name} #{@member.infix} #{@member.last_name} not added to #{@lidmaatschap.activity.name}"
          end
        end
      end
      
      #betaingen aanmaken indien iDeal
      if params[:method] == 'IDEAL'
        logger.debug(params[:bank])
      end
      
      impressionist(@member, 'nieuwe lid')
      
      redirect_to public_path
    else
      if @member.educations.length < 1
        @member.educations.build( :id => '-1' )
      end
      
      if @member.educations.length < 2
        @member.educations.build( :id => '-2' )
      end
    
      render 'index'
    end
  end
  
  # Create a iDeal payment and redirect to the bank
  def payment
    #check if hash is correct
  
  end
  
  # Confirm the payment has been done, the redirect url 
  def confirm
    
  end
  
  private
  def public_post_params
    params.require(:member).permit(:first_name,
                                   :infix,
                                   :last_name,
                                   :address,
                                   :house_number,
                                   :postal_code,
                                   :city,
                                   :phone_number,
                                   :email,
                                   :gender,
                                   :student_id,
                                   :birth_date,
                                   :join_date,
                                   :activities => [],
                                   educations_attributes: [ :id, :study_id, :start_date, :end_date, :_destroy ])
  end
end
