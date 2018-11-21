#:nodoc:
class Advertisement < ApplicationRecord
  validates :name, presence: true

  has_one_attached :poster
  validate :content_type

  def url
    poster.representation(resize: '1553x1080^') if poster.attached?
  end

  private

  def content_type
    errors.add(:poster, I18n.t('activerecord.errors.unsupported_content_type', :type => poster.content_type.to_s, :allowed => 'application/pdf image/jpeg image/png')) unless poster.attached? && poster.content_type.in?(['application/pdf', 'image/jpeg', 'image/png'])
  end
end
