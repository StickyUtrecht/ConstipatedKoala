class Group < ActiveRecord::Base
  validates :name, presence: true
  validates :category, presence: true

#  validates :comments

  enum category: { board: 1, committee: 2, moot: 3, other: 4 }

  has_many :activities, :foreign_key => :organized_by

  has_many :group_members,
    :dependent => :destroy
  has_many :members,
    :through => :group_members
    
  is_impressionable

  def years
    #TODO remove years without members
    ( self.created_at.study_year .. Date.today.study_year ).map{ |year| ["#{year}-#{year +1}", year] }.reverse
  end

  def positions
    return [ 'chairman', 'secretary', 'treasurer', 'internal', 'external', 'education' ] if self.board?
    return ([ 'chairman', 'treasurer', 'board' ] + ENV['ADDITIONAL_COMMITTEE_POSITIONS'].to_a + group_members.select( :position ).order(  :position ).uniq.map { |member| member.position }).compact.uniq if self.committee?
    return [ 'chairman', 'treasurer' ]
  end

  def members( year = NIL )
    year = year.nil? ? Date.today.study_year : year.to_i

    self.group_members.where( :year => year ).sort do |a,b|
      if positions.index( a.position ).nil? && positions.index( b.position ).nil?
        a.name <=> b.name
      elsif positions.index( b.position ).nil?
        -1
      elsif positions.index( a.position ).nil?
        1
      elsif positions.index( a.position ) == positions.index( b.position )
        a.name <=> b.name
      else
        positions.index( a.position ) <=> positions.index( b.position )
      end
    end
  end

  def self.has_members
    self.joins( :group_members ).select( '`groups`.*, COUNT( `groups`.`id` ) as members' ).group( '`groups`.`id`' ).having( 'members > 0' )
  end
end
