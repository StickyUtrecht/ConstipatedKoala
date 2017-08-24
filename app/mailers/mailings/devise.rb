# encoding: utf-8

module Mailings
  class Devise < ApplicationMailer
    include ::Devise::Controllers::UrlHelpers

    def confirmation_instructions(record, token, opts={})
      puts confirmation_url(record, confirmation_token: token) if Rails.env.development?
      return if ENV['MAILGUN_TOKEN'].blank?

      html = render_to_string :locals => {
        name: record.credentials.name,
        confirmation_url: confirmation_url(record, confirmation_token: token),
        subject: 'Studievereniging Sticky | account bevestigen'
      }

      text = <<-EOS
        Hoi #{record.credentials.name},

        Bevestig je email voor je account bij studievereniging sticky door naar #{confirmation_url(record, confirmation_token: token)} te gaan.

        Met vriendelijke groet
      EOS

      return mail(record.unconfirmed_email ||= record.email, nil, 'Sticky account activeren', html, text)
    end

    def activation_instructions(record, token, opts={})
      url = new_member_confirmation_url(confirmation_token: token)
      puts url if Rails.env.development?
      return if ENV['MAILGUN_TOKEN'].blank?

      html = render_to_string :locals => {
        name: record.credentials.name,
        activation_url: url,
        subject: 'Welkom bij Sticky! | account activeren'
      }

      text = <<-EOS
        Hoi #{record.credentials.name},

        Welkom bij Sticky! Activeer je account voor ons ledenbeheersysteem door naar #{url} te gaan.

        Met vriendelijke groet
      EOS

      return mail(record.email, nil, 'Welkom bij Sticky | account activeren', html, text)
    end


    def reset_password_instructions(record, token, opts={})
      puts edit_password_url(record, reset_password_token: token) if Rails.env.development?
      return if ENV['MAILGUN_TOKEN'].blank?

      html = render_to_string :locals => {
        name: record.credentials.name,
        reset_url: edit_password_url(record, reset_password_token: token),
        subject: 'Studievereniging Sticky | wachtwoord herstellen'
      }

      text = <<-EOS
        Hoi #{record.credentials.name},

        Er is een nieuw wachtwoord aangevraagd voor je Sticky account, of je hebt geprobeerd een nieuwe account aan te maken.
        Ga naar #{edit_password_url(record, reset_password_token: token)} om een nieuw wachtwoord in te stellen of negeer deze e-mail als je je huidige wachtwoord wil behouden.

        Met vriendelijke groet
      EOS

      return mail(record.email, nil, 'Sticky wachtwoord opnieuw instellen', html, text)
    end
  end
end
