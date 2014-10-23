class Member < ActiveRecord::Base
  validates :first_name, presence: true
  #validates :infix
  validates :last_name, presence: true
  validates :address, presence: true
  validates :house_number, presence: true
  validates :postal_code, presence: true
  validates :city, presence: true
  validates :phone_number, presence: true, format: { with: /(^\+[0-9]{2}|^\+[0-9]{2}\(0\)|^\(\+[0-9]{2}\)\(0\)|^00[0-9]{2}|^0)([0-9]{9}$|[0-9\-\s]{10}$)/, multiline: true }
  validates :email, presence: true, format: { with: /\A[A-Za-z0-9.+-_]+@(?![A-Za-z]*\.?uu\.nl)([A-Za-z]+\.[A-Za-z.]+\z)/ }
  validates :gender, presence: true, inclusion: { in: %w(m f)}
  validates :student_id, presence: true, format: { with: /\F?\d{6,7}/ }
  validates :birth_date, presence: true
  validates :join_date, presence: true
  #validates :comments

  attr_accessor :tags_name_ids
  fuzzily_searchable :query
  is_impressionable

  has_many :tags,
    :dependent => :destroy,
    :autosave => true

  accepts_nested_attributes_for :tags,
    :reject_if => :all_blank,
    :allow_destroy => true

  has_many :educations,
    :dependent => :destroy
  has_many :studies,
    :through => :educations

  accepts_nested_attributes_for :educations,
    :reject_if => :all_blank,
    :allow_destroy => true

  has_many :participants,
    :dependent => :destroy
  has_many :activities,
    :through => :participants

  has_many :committeeMembers,
    :dependent => :destroy
  has_many :committees,
    :through => :committeeMembers

  before_create :before_create

  # remove nonnumbers and change + to 00
  def phone_number=(phone_number)
    write_attribute(:phone_number, phone_number.sub('+', '00').gsub(/\D/, ''))
  end

  # remove spaces in postal_code
  def postal_code=(postal_code)
    write_attribute(:postal_code, postal_code.sub(' ', ''))
  end
  
  # return full name
  def name
    if infix.blank?
      return "#{self.first_name} #{self.last_name}"
    end
    
    return "#{self.first_name} #{self.infix} #{self.last_name}"
  end

  # create hash for gravatar
  def gravatar
    Digest::MD5.hexdigest(self.email)
  end

  # set joindate
  def before_create
    self.join_date = Time.new
  end
  
  def self.search(query)
    #Member.where("first_name LIKE ? OR last_name like ? OR student_id like ?", "%#{query}%", "%#{query}%", "%#{query}%")
    Member.find_by_fuzzy_query(query, :limit => 20)
  end
  
  # guery for fuzzy search 
  def query 
    "#{self.first_name} #{self.last_name} #{self.student_id}"
  end
  
  def query_changed?
    first_name_changed? || infix_changed? || last_name_changed? || email_changed? || student_id_changed?
  end
end
