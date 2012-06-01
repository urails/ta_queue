FactoryGirl.define do

  sequence(:username) { |n| "username#{n}" }

  sequence(:email) { |n| "foo#{n}@bar.com" }

  sequence(:class_number) { |n| "cs140#{n}" }

  sequence(:location) { |n| "location #{n}" }

  sequence(:title) { |n| "title#{n}" }

  sequence(:name) { |n| "University of Utah #{n}" }

  sequence(:school_abbreviation) { |n| "uofu#{n}" }

  factory :queue_user do
    username { generate :username }
    token { SecureRandom.uuid }
    password "some_password"
  end

  factory :student do
    username { generate :username }
    token { SecureRandom.uuid }
    location { generate :location }
  end

  factory :ta do
    username { generate :username }
    token { SecureRandom.uuid }
    password "foobar"
  end

  factory :school do
    name { generate :name }
    abbreviation { generate :school_abbreviation }
    master_password "foobar"
    contact_email "foo@bar.com"
  end

  factory :instructor do
    name "John Doe"
    username { generate :username }
    email { generate :email }
    password "foobar"
    password_confirmation "foobar"
    master_password "foobar"
  end

  factory :school_queue do
    frozen false
    title { generate :title }
    class_number { generate :class_number }
    active true
    status "Welcome!"
    password "foobar"
  end

end
