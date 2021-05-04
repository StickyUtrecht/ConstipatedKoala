# This job is used to update a user's email address in mailchimp
class MailchimpUpdateAddressJob < ApplicationJob
  queue_as :default

  def perform(old_address, new_address, user_mailing_status)
    return if ENV['MAILCHIMP_DATACENTER'].blank?

    request = {
      email_address: new_address,
      status_if_new: user_mailing_status
    }

    logger.debug request.inspect

    RestClient.put(
      "https://#{ ENV['MAILCHIMP_DATACENTER'] }.api.mailchimp.com/3.0/lists/#{ ENV['MAILCHIMP_LIST_ID'] }/members/#{ Digest::MD5.hexdigest(old_address.downcase) }",
      request.to_json,
      Authorization: "mailchimp #{ ENV['MAILCHIMP_TOKEN'] }",
      'User-Agent': 'constipated-koala'
    )
  end
end
