require 'test_helper'

class MemberTest < ActiveSupport::TestCase
  test "blank Member is invalid" do
    m = Member.new
    assert_not m.save
  end

  # This hash lists all attributes that are required for a member to be valid,
  # along with a purposefully empty/invalid value.
  minimal_required_attributes = {
    "first_name" => '', "last_name" => '',
    "address" => '', "house_number" => '', "postal_code" => '', "city" => '',
    "phone_number" => '', "email" => '', "gender" => '',
    "birth_date" => nil, "join_date" => nil
  }

  # Verify that a Member model with the minimal set of attributes defined above
  # is valid, AND that this set is actually the minimal set of attributes,
  # meaning that the model is invalid if any of these values are missing.
  test "filled-out Member is valid" do
    m = Member.new
    m.first_name = "Test_first"
    m.last_name = "Test_last"
    m.address = "Teststreet"
    m.house_number = "123" # Not a number, to allow for 'bis', 'A', etc.
    m.postal_code = '1234 AB'
    m.city = 'Testville'
    m.phone_number = '0612345678'
    m.email = 'test@svsticky.nl'
    m.gender = 'm'
    m.birth_date = Date.today
    m.join_date = Date.today

    assert m.save, "Could not save minimal valid Member"

    minimal_required_attributes.each do |attribute, emptyvalue|
      temp = m.attributes[attribute]
      m.assign_attributes({attribute => emptyvalue })

      assert_not m.save, "#{attribute} is not required"

      m.assign_attributes({attribute => temp})
    end
  end
end
