# coding: utf-8

module Mailings
  class Checkout < Mailer

    def confirmation_instructions (card, confirmation_url)
      return if ENV['MAILGUN_TOKEN'].blank?

      html = render_to_string( :layout => "mailings", :locals => {
        name: card.member.first_name,
        confirmation_url: confirmation_url,
        subject: 'Studievereniging Sticky | Checkout kaart bevestigen'
      })

      text = <<-EOS
        Hoi #{card.member.first_name},

        Bevestig je Checkout kaart voor je account bij Studievereniging Sticky door naar #{confirmation_url} te gaan.

        Met vriendelijke groet,

        Studievereniging Sticky
      EOS

      return mail(card.member.email, nil, 'Studievereniging Sticky | Checkout kaart bevestigen', html, text)
    end
  end
end