require 'spec_helper'

describe "testing" do
  before :all do
    @board = Factory.create :board
    @pass = @board.password = "foobar"
    @board.save
  end

  it "should fail" do
    visit "/boards/#{@board.title}/login"
    within :css, 'form#new_ta' do
      fill_in 'ta[username]', :with => 'tommy'
      fill_in 'ta_password', :with => @pass
      find_button('Login').click
    end
    page.should have_content "Available TAs"

    page.should have_content "tommy"
  end
end
