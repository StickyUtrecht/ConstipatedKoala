class PublicController < ApplicationController
  skip_before_action :authenticate_admin!, only: [:index, :create, :confirm]
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
    @activities = []
    @total = 0
    
    if @member.save
      impressionist(@member, 'nieuwe lid')
      flash[:notice] = 'Je hebt je ingeschreven!'

      if @member.educations.first.study_id > 4
        redirect_to public_path
        return
      end

      # add to activitiess      
      @lidmaatschap = Participant.new( :member => @member, :activity => Activity.find(@@intro['lidmaatschap']))

      if @lidmaatschap.save
        @activities.to_a.push @lidmaatschap.activity.id
        @total += @lidmaatschap.currency      
      else
        logger.error "[ACTIVITY] #{@member.first_name} #{@member.infix} #{@member.last_name} not added to #{@lidmaatschap.activity.name}"
      end
      
      if !params[:activities].nil?      
        if params[:activities].include? 'bbq'
          @bbq = Participant.new( :member => @member, :activity => Activity.find(@@intro['bbq']))

          if @bbq.save
            @activities.to_a.push @bbq.activity.id    
            @total += @bbq.currency      
          else
            logger.error "[ACTIVITY] #{@member.first_name} #{@member.infix} #{@member.last_name} not added to #{@lidmaatschap.activity.name}"        
          end
        end
              
        if params[:activities].include? 'lasergamen'
          @lasergamen = Participant.new( :member => @member, :activity => Activity.find(@@intro['lasergamen']))

          if @lasergamen.save
            @activities.to_a.push @lasergamen.activity.id
            @total += @lasergamen.currency      
          else
            logger.error "[ACTIVITY] #{@member.first_name} #{@member.infix} #{@member.last_name} not added to #{@lidmaatschap.activity.name}"
          end
        end
      end
      
      # pay with iDeal
      if params[:method] == 'IDEAL'
        @transaction = IdealTransaction.new( :activities => @activities.to_a, :member => @member, :description => "Introductie #{@member.first_name} #{@member.infix} #{@member.last_name}", :price => @total, :issuer => params[:bank], :status => 'PENDING', :url => 'http://abc.isaanhetwerk.nl/confirm')

        if @transaction.save
#          redirect_to "https://betalingen.stickyutrecht.nl/?uuid=#{@transaction.uuid}&url=public%2Fconfirm%2F"
          redirect_to "http://betalingen.isaanhetwerk.nl/?id=#{@transaction.id}"
          return
        else
          logger.error "[IDEAL] #{@transaction.id} niet gelukt #{@transaction.status}"
          flash[:notice] = 'Je betaling is niet gelukt!' 
        end
      end
      
      redirect_to public_path
      return
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
  
  # Confirm the payment has been done, the redirect url 
  def confirm
    # check if it is payed
    @transaction = IdealTransaction.find(params[:id])

    if @transaction.status == 'SUCCESS'
      # set activities as payed
      @transaction.activities.each do |activity|
        @participant = Participant.where("member_id = ? AND activity_id = ?", @transaction.member.id, activity)
        
        if @participant.size != 1
	  flash[:notice] = 'Er is iets fout gegaan.'
	  redirect_to public_path
	end

	@participant.first.paid = true
	@participant.first.save
      end

      flash[:notice] = 'Je betaling is ontvangen!'
    else
      flash[:notice] = 'Er is iets fout gegaan.'
    end

    redirect_to public_path
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
                                   
                                   :method,
                                   :bank,
                                   
                                   :activities => [],
                                   educations_attributes: [ :id, :study_id, :start_date, :end_date, :_destroy ])
  end
end
