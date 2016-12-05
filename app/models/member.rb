# encoding: utf-8
# Default a class begins with a number of validations. student_id is special because in the intro website it cannot be empty. However an admin can make it empty
class Member < ActiveRecord::Base
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :address, presence: true
  validates :house_number, presence: true
  validates :postal_code, presence: true
  validates :city, presence: true
  validates :phone_number, presence: true, format: { with: /(^\+[0-9]{2}|^\+[0-9]{2}\(0\)|^\(\+[0-9]{2}\)\(0\)|^00[0-9]{2}|^0)([0-9]{9}$|[0-9\-\s]{10}$)/, multiline: true }
  validates :email, presence: true, uniqueness: { :case_sensitive => false }, format: { with: /[A-Za-z0-9.+-_]+@(?![A-Za-z]*\.?uu\.nl)([A-Za-z0-9.+-_]+\.[A-Za-z.]+)/ }
  validates :gender, presence: true, inclusion: { in: %w(m f)}

  # An attr_accessor is basically a variable attached to the model but not stored in the database
  attr_accessor :require_student_id
  validates :student_id, presence: false, uniqueness: true, :allow_blank => true, format: { with: /\F?\d{6,7}/ }
  validate :valid_student_id

  validates :birth_date, presence: true
  validates :join_date, presence: true

  attr_accessor :tags_names
  fuzzily_searchable :query
  is_impressionable :dependent => :ignore

  # In the model relations are defined (but created in the migration) so that you don't have to do an additional query for for example tags, using these relations rails does the queries for you
  has_many :tags,
    :dependent => :destroy,
    :autosave => true

  accepts_nested_attributes_for :tags,
    :reject_if => :all_blank,
    :allow_destroy => true

  has_many :checkout_cards,
    :dependent => :destroy
  has_one :checkout_balance,
    :dependent => :destroy

  has_many :educations,
    :dependent => :destroy
  has_many :studies,
    :through => :educations

  accepts_nested_attributes_for :educations,
    :reject_if => proc { |attributes| attributes['study_id'].blank? },
    :allow_destroy => true

  has_many :participants,
    :dependent => :destroy
  has_many :activities,
    :through => :participants

  has_many :group_members,
    :dependent => :destroy
  has_many :groups,
    :through => :group_members

  # An attribute can be changed on setting, for example the names are starting with a cap
  def first_name=(first_name)
    write_attribute(:first_name, first_name.downcase.titleize)
  end

  def infix=(infix)
    write_attribute(:infix, infix.downcase)
    write_attribute(:infix, NIL) if infix.blank?
  end

  def last_name=(last_name)
    write_attribute(:last_name, last_name.downcase.titleize)
  end

  # remove nonnumbers and change + to 00
  def phone_number=(phone_number)
    write_attribute(:phone_number, phone_number.sub('+', '00').gsub(/\D/, ''))
  end

  # lowercase on email
  def email=(email)
    write_attribute(:email, email.downcase)
  end

  def address=(address)
    write_attribute(:address, address.strip)
  end

  # remove spaces in postal_code
  def postal_code=(postal_code)
    write_attribute(:postal_code, postal_code.upcase.gsub(' ', ''))
  end

  def student_id=(student_id)
    write_attribute(:student_id, student_id.upcase)
    write_attribute(:student_id, NIL) if student_id.blank?
  end

  def tags_names=(tags)
    Tag.delete_all( :member_id => id, :name => Tag.names.map{ |tag, i| i unless tags.include?(tag) })

    tags.each do |tag|
      next if tag.empty?

      puts Tag.where( :member_id => id, :name => Tag.names[tag] ).first_or_create!
    end
  end

  # Some other function can improve your life a lot, for example the name function
  def name
    return "#{self.first_name} #{self.last_name}" if infix.blank?
    return "#{self.first_name} #{self.infix} #{self.last_name}"
  end

  # create hash for gravatar
  def gravatar
    return Digest::MD5.hexencode(self.email)
  end

  def groups
    groups = Hash.new

    group_members.order( year: :desc ).each do |group_member|
      if groups.has_key?( group_member.group.id )
        groups[ group_member.group.id ][ :years ].push( group_member.year )

        groups[ group_member.group.id ][ :positions ].push( group_member.position => group_member.year ) unless group_member.position.blank? || group_member.group.board?
      end

      groups.merge!( group_member.group.id => { :id => group_member.group.id, :name => group_member.group.name, :years => [ group_member.year ], :positions => [ group_member.position => group_member.year ]} ) unless groups.has_key?( group_member.group.id )
    end

    return groups.values
  end

  # Rails also has hooks you can hook on to the process of saving, updating or deleting. Here the join_date is automatically filled in on creating a new member
  # We also check for a duplicate study, and discard the duplicate if found.
  # (Not doing this would lead to a database constraint violation.)
  before_create do
    self.join_date = Time.new if self.join_date.blank?

    if self.educations.length > 1 and self.educations[0].study_id == self.educations[1].study_id
      self.educations[1].destroy
    end
  end

  # Devise uses e-mails for login, and this is the only redundant value in the database. The e-mail, so if someone chooses the change their e-mail the e-mail should also be changed in the user table if they have a login
  before_update do
    if email_changed?
      credentials = User.find_by_email( Member.find(self.id).email )

      if !credentials.nil?
        credentials.update_attribute('email', self.email)
        credentials.save
      end
    end
  end

  # Functions starting with self are functions on the model not an instance. For example we can now search for members by calling Member.search with a query
  def self.search(query)
    student_id = query.match /^\F?\d{6,7}$/i
    return self.where("student_id like ?", "%#{student_id}%") unless student_id.nil?

    phone_number = query.match /^(?:\+\d{2}|00\d{2}|0)(\d{9})$/
    return self.where("phone_number like ?", "%#{phone_number[1]}") unless phone_number.nil?

    # If query is blank, no need to filter. Default behaviour would be to return Member class, so we override by passing all
    return self.where( :id => ( Education.select( :member_id ).where( 'status = 0' ).map{ |education| education.member_id} + Tag.select( :member_id ).where( :name => Tag.active_by_tag ).map{ | tag | tag.member_id } )) if query.blank?

    records = self.filter( query )
    return records.find_by_fuzzy_query( query ) unless query.blank?
    return records
  end

  # Query for fuzzy search, this string is used for building indexes for searching
  def query
    "#{self.name} #{self.email}"
  end

  def query_changed?
    first_name_changed? || infix_changed? || last_name_changed? || email_changed?
  end

  # Update studies based on studystatus output, the only way to run this function is by the rake task, and it updates the study status of a person, nothing more, nothing less
  def update_studies(studystatus_output)
    result_id, *studies = studystatus_output.split(/; /)
    puts "#{self.student_id} returns empty result;" if result_id.blank?

    if self.student_id != result_id
      logger.error 'Student id received from studystatus is different'
      return
    end

    if studies == 'NOT FOUND'
      puts "#{student_id} not found"
      return
    end

    for study in studies do
      code, year, status, end_date = study.split(/, /)

      if Study.find_by_code(code).nil?
        puts "#{code} is not found as a study in the database"
        next
      end

      education = self.educations.find_by_year_and_study_code(year, code)

      # If not found as informatica, we can try for gametech. This only works if the student filled in GT from the subscribtion
      if education.nil? && code == 'INCA'
        education = self.educations.find_by_year_and_study_code(year, 'GT')
        code = 'GT'
      end

      if education.nil?
        education = Education.new( :member => self, :study => Study.find_by_code(code), :start_date => Date.new(year.to_i, 9, 1))
        puts " + #{code} (#{status})"
      else
        puts " ± #{code} (#{status})"
      end

      if status.eql?('gestopt')
        education.update_attribute('status', 'stopped')
      elsif status.eql?('afgestudeerd')
        education.update_attribute('status', 'graduated')
      elsif status.eql?('actief')
        education.update_attribute('status', 'active')
      else
        next
      end

      # TODO check if student joined this year, has no studies, and study is a bachelor

      education.update_attribute('end_date', Date::parse(end_date.split(' ')[1])) if status != 'actief' && end_date.present? && end_date.split(' ')[1].present?
      education.save
    end

    # remove studies no longer present
    for education in self.educations do
      check = "#{education.study.code} | #{education.start_date.year}"
      check = "INCA | #{education.start_date.year}" if education.study.code == 'GT' # NOTE dirty fix for gametechers

      unless studies.map{ |string| "#{string.split(/, /)[0]} | #{string.split(/, /)[1]}" }.include?( check )
        puts " - #{education.study.code}"
        education.destroy
      end
    end
  end

  def is_underage?
    return !self.is_adult?
  end

  def is_adult?
    return 18.years.ago >= self.birth_date
  end

  # Private function cannot be called from outside this class
  private
  def self.filter( query )
    records = self
    study = query.match /(studie|study):([A-Za-z-]+)/

    unless study.nil?
      query.gsub! /(studie|study):([A-Za-z-]+)/, ''

      code = Study.find_by_code( study[2] )

      # Lookup using full names
      if code.nil?
        study_name = Study.all.map{ |study| { I18n.t(study.code.downcase, scope: 'activerecord.attributes.study.names' ).downcase => study.code.downcase }}.find{ |hash| hash.keys[0] == study[2].downcase.gsub( '-', ' ' ) }
        code = Study.find_by_code( study_name.values[0] ) unless study_name.nil?
      end

      records = Member.none if code.nil? #TODO add active to the selector if status is not in the query
      records = records.where( :id => Education.select( :member_id ).where( 'study_id = ?', code.id )) unless code.nil?

      #for later purposes
      study = code
    end

    tag = query.match /tag:([A-Za-z-]+)/

    unless tag.nil?
      query.gsub! /tag:([A-Za-z-]+)/, ''

      tag_name = Tag.names.map{ |tag| { I18n.t(tag[0], scope: 'activerecord.attributes.tag.names').downcase => tag[1]} }.find{ |hash| hash.keys[0] == tag[1].downcase.gsub( '-', ' ' ) }

      records = Member.none if tag_name.nil?
      records = records.where( :id => Tag.select( :member_id ).where( 'name = ?', tag_name.values[0] )) unless tag_name.nil?
    end

    year = query.match /(year|jaargang):(\d+)/

    unless year.nil?
      query.gsub! /(year|jaargang):(\d+)/, ''
      records = records.where("join_date >= ? AND join_date < ?", Date.to_date( year[2].to_i ), Date.to_date( 1+ year[2].to_i ))
    end

    status = query.match /(status|state):([A-Za-z-]+)/
    query.gsub! /(status|state):([A-Za-z]+)/, ''

    if status.nil? || status[2].downcase == 'actief'
      # if already filtered on study, that particular study should be active
      if code.present?
        records = records.where( :id => ( Education.select( :member_id ).where( 'status = 0 AND study_id = ?', code.id ).map{ |education| education.member_id}))
      else
        records = records.where( :id => ( Education.select( :member_id ).where( 'status = 0' ).map{ |education| education.member_id} + Tag.select( :member_id ).where( :name => Tag.active_by_tag ).map{ | tag | tag.member_id } ))
      end
    elsif status[2].downcase == 'alumni'
      records = records.where.not( :id => Education.select( :member_id ).where( 'status = 0' ).map{ |education| education.member_id })
    elsif status[2].downcase == 'studerend'
      records = records.where( :id => Education.select( :member_id ).where( 'status = 0' ).map{ |education| education.member_id })
    elsif status[2].downcase == 'iedereen'
      records = Member.all
    else
      records = Member.none
    end

    return records
  end

  # Perform an elfproef to verify the student_id
  def valid_student_id
    # on the intro website student_id is required
    errors.add :student_id, I18n.t('activerecord.errors.models.member.attributes.student_id.invalid') if require_student_id && student_id.blank?

    # do not do the elfproef if a foreign student
    return if ( student_id =~ /\F\d{6}/)
    return if student_id.blank?

    numbers = student_id.split("").map(&:to_i).reverse

    sum = 0
    numbers.each_with_index do |digit, i|
      i = i+1
      sum += digit * i
    end

    # Errors are added direclty to the model, so it easy to show in the views. We are using I18n for translating purposes, a lot is still hardcoded dutch, but not the intro website and studies
    errors.add :student_id, I18n.t('activerecord.errors.models.member.attributes.student_id.elfproef') if sum % 11 != 0
  end
end
