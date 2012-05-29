FactoryGirl.define do

  sequence :username do |n|
    "username#{n}"
  end

  sequence :email do |n|
    "foo#{n}@bar.com"
  end

  sequence :class_number do |n|
    "cs140#{n}"
  end

  sequence :location do |n|
    "location #{n}"
  end

  sequence :title do |n|
    "title#{n}"
  end

  sequence :name do |n|
    "University of Utah #{n}"
  end

  sequence :school_abbreviation do |n|
    "uofu#{n}"
  end

  factory :queue_user do
    username { Factory.next :username }
    token { SecureRandom.uuid }
    password "some_password"
  end

  factory :student do
    username { Factory.next :username }
    token { SecureRandom.uuid }
    location { Factory.next :location }
  end

  factory :ta do
    username { Factory.next :username }
    token { SecureRandom.uuid }
    password "foobar"
  end

  factory :school do
    name { Factory.next :name }
    abbreviation { Factory.next :school_abbreviation }
    master_password "foobar"
    contact_email "foo@bar.com"
  end

  factory :instructor do
    name "John Doe"
    username { Factory.next :username }
    email { Factory.next :email }
    password "foobar"
    password_confirmation "foobar"
    master_password "foobar"
  end

  factory :school_queue do
    frozen false
    title { Factory.next :title }
    class_number { Factory.next :class_number }
    active true
    status "Welcome!"
    password "foobar"
  end

end
