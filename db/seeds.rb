# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

require "faker"

Faker::Config.locale = :nl

Study.create(
  id:             1,
  name:           "Informatica",
  code:           "INCA",
  masters:        false
)
Study.create(
  id:             2,
  name:           "Informatiekunde",
  code:           "INKU",
  masters:        false
)
Study.create(
  id:             3,
  name:           "Gametech",
  masters:        false,
  code:           "GT"
)
Study.create(
  id:             4,
  name:           "Computing Science",
  code:           "COSC",
  masters:        true
)
Study.create(
  id:             5,
  name:           "Business Informatics",
  code:           "MBI",
  masters:        true
)
Study.create(
  id:             6,
  name:           "Wiskunde",
  code:           "WISK",
  masters:        false
)
Study.create(
  id:             7,
  name:           "Artificial Intelligence",
  code:           "AI",
  masters:        true
)
Study.create(
  id:             8,
  name:           "Game and Media Technology",
  code:           "GMT",
  masters:        true
)

60.times do
  member = Member.create(
    first_name:   Faker::Name.first_name,
    infix:        (Random.rand(10) > 7 ? Faker::Name.tussenvoegsel : ''),
    last_name:    Faker::Name.last_name,
    address:      Faker::Address.street_name,
    house_number: Faker::Address.building_number,
    postal_code:  Faker::Address.postcode,
    city:         Faker::Address.city,
    phone_number: Faker::PhoneNumber.phone_number,
    email:        Faker::Internet.email,
    gender:       ['m', 'f'].sample,
    student_id:   Faker::Number.number(7),
    birth_date:   Faker::Business.credit_card_expiry_date,
    join_date:    Faker::Business.credit_card_expiry_date,
    comments:     (Random.rand(10) > 3 ? Faker::Company.catch_phrase : NIL)
  )

  Education.create(
    member:       member,
    study_id:     Random.rand(8) +1, #there are now 1..8 educations
    start_date:   Faker::Business.credit_card_expiry_date,
    end_date:     (Random.rand(10) > 6 ? Faker::Business.credit_card_expiry_date : NIL),
    status:       Random.rand(3)
  )
end

12.times do
  Activity.create(
    name:         Faker::Commerce.department,
    price:        Faker::Commerce.price,
    start_date:   Faker::Business.credit_card_expiry_date
  )
end

# Suppress exception for the unique key [member, activity]
suppress(Exception) do
  200.times do
    Participant.create(
      member:       Member.find(1+ Random.rand(Member.count)),
      activity:     Activity.find(1+ Random.rand(Activity.count)),
      price:        (Random.rand(10) > 8 ? Faker::Commerce.price : NIL),
      paid:        (Random.rand(10) > 8 ? true : false)
    )
  end
end
