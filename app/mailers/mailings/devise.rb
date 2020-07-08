#:nodoc:
module Mailings
  #:nodoc:
  class Devise < ApplicationMailer
    include ::Devise::Controllers::UrlHelpers

    def confirmation_instructions(record, token, _opts = {})
      puts confirmation_url(record, confirmation_token: token) if Rails.env.development?
      return if ENV['MAILGUN_TOKEN'].blank?

      html = render_to_string :locals => {
        name: record.credentials.name,
        confirmation_url: confirmation_url(record, confirmation_token: token),
        subject: "#{ I18n.t('association_name') } | #{ I18n.t('mailings.devise.confirmation_instructions.confirm_email') }"
      }

      text = <<~PLAINTEXT
        #{ I18n.t('mailings.greeting') } #{ record.credentials.name },

        #{ I18n.t('mailings.devise.confirmation_instructions.link_instructions', confirm_link: confirmation_url(record, confirmation_token: token)) }

        #{ I18n.t('mailings.best_regards') }

        #{ I18n.t('mailings.signature') }
      PLAINTEXT

      return mail(record.unconfirmed_email ||= record.email, nil, I18n.t('mailings.devise.confirmation_instructions.activate_account'), html, text)
    end

    def activation_instructions(record, token, _opts = {})
      url = new_member_confirmation_url(confirmation_token: token)
      puts url if Rails.env.development?
      return if ENV['MAILGUN_TOKEN'].blank?

      html = render_to_string :locals => {
        name: record.credentials.first_name,
        activation_url: url,
        subject: "#{ I18n.t('mailings.devise.activation_instructions.welcome') } | #{ I18n.t('mailings.devise.confirmation_instructions.activate_account') }"
      }

      text = <<~MARKDOWN
        #{ I18n.t('mailings.greeting') } #{ record.credentials.first_name },

        ## #{ I18n.t('mailings.devise.activation_instructions.welcome') }

        #{ I18n.t('mailings.devise.activation_instructions.reception_justification') }

        #{ I18n.t('mailings.devise.activation_instructions.about_sticky') }

        #{ I18n.t('mailings.devise.activation_instructions.activity_updates_html',
                  facebook_group_link_start: '<a href="https://www.facebook.com/groups/814759978565158">'.html_safe,
                  facebook_page_link_start: '<a href="https://www.facebook.com/stickyutrecht">'.html_safe,
                  sticky_site_link_start: '<a href="https://svsticky.nl">'.html_safe,
                  link_end: '</a>'.html_safe) }

        ## #{ I18n.t('mailings.devise.activation_instructions.corner_stones.education.name') }
        #{ I18n.t('mailings.devise.activation_instructions.corner_stones.education.description_html',
                  books_page_link_start: '<a href="https://svsticky.nl/boeken">'.html_safe,
                  link_end: '</a>'.html_safe) }

        ## #{ I18n.t('mailings.devise.activation_instructions.corner_stones.business.name') }
        #{ I18n.t('mailings.devise.activation_instructions.corner_stones.business.description_html',
                  job_offer_page_link_start: '<a href="https://svsticky.nl/partners/vacatures">'.html_safe,
                  link_end: '</a>'.html_safe) }

        ## #{ I18n.t('mailings.devise.activation_instructions.corner_stones.sociability.name') }
        #{ I18n.t('mailings.devise.activation_instructions.corner_stones.sociability.description') }

        ## #{ I18n.t('mailings.devise.activation_instructions.and_now', url: url) }
        #{ I18n.t('mailings.devise.activation_instructions.wrap_up', url: url) }

        #{ I18n.t('mailings.devise.activation_instructions.account_activation_link', url: url) }

        #{ I18n.t('mailings.devise.activation_instructions.see_you_soon') }

        #{ I18n.t('mailings.signature') }
      MARKDOWN

      return mail(record.email, nil, "#{ I18n.t('mailings.devise.activation_instructions.welcome') } | #{ I18n.t('mailings.devise.confirmation_instructions.activate_account') }", html, text)
    end

    def reset_password_instructions(record, token, _opts = {})
      puts edit_password_url(record, reset_password_token: token) if Rails.env.development?
      return if ENV['MAILGUN_TOKEN'].blank?

      html = render_to_string :locals => {
        name: record.credentials.name,
        reset_url: edit_password_url(record, reset_password_token: token),
        subject: "#{ I18n.t('association_name') } | #{ I18n.t('mailings.devise.reset_passwords_instructions.reset_password') }"
      }

      text = <<~PLAINTEXT
        #{ I18n.t('mailings.greeting') } #{ record.credentials.name },

        #{ I18n.t('mailings.devise.reset_passwords_instructions.notification') }
        #{ I18n.t('mailings.devise.reset_passwords_instructions.link_instructions', reset_password: edit_password_url(record, reset_password_token: token)) }

        #{ I18n.t('mailings.best_regards') }

        #{ I18n.t('mailings.signature') }
      PLAINTEXT

      return mail(record.email, nil, "#{ I18n.t('mailings.devise.reset_passwords_instructions.reset_password') } Sticky", html, text)
    end

    def forced_confirm_email(record, current_user, _opts = {})
      puts "#{ record.user.unconfirmed_email } #{ I18n.t('mailings.removed') }" if Rails.env.development?
      return if ENV['MAILGUN_TOKEN'].blank?

      html = render_to_string :locals => {
        name: record.name,
        email: record.user.unconfirmed_email,
        sendername: current_user.credentials.name,
        subject: "#{ I18n.t('association_name') } | #{ I18n.t('mailings.devise.changed_instructions.changed_email') }"
      }

      text = <<~PLAINTEXT
        #{ I18n.t('mailings.greeting') } #{ record.name },

        #{ I18n.t('mailings.devise.changed_instructions.inform_change_text', new_email: record.user.unconfirmed_email) }

        #{ I18n.t('mailings.best_regards') }

        #{ current_user.credentials.name }
      PLAINTEXT

      return mail([record.user.email, record.user.unconfirmed_email], current_user.sender, "#{ I18n.t('association_name') } | #{ I18n.t('mailings.devise.changed_instructions.changed_email') }", html, text)
    end
  end
end
