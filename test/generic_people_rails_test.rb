require 'test_helper'

class GenericPeopleRailsTest < ActiveSupport::TestCase
  test "truth" do
    assert_kind_of Module, GenericPeopleRails
  end

  test "address setting" do
    a = Address.create(:address => "")
    a.assign_attributes(:address => "20743 Canterbury Ct, Bend OR, 97702")
    assert_equal(a.city,"Bend");
  end

end
