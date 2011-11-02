require 'spec_helper'

describe Notification do
  before :all do
    10.times do |i|
      board = Factory.build :board
      board.save
      st = board.students.create(Factory.attributes_for :student)
      st.save
      ta = board.tas.create(Factory.attributes_for :ta)
      ta.save
      board.save
    end
  end

  after :all do
    Student.destroy_all
    Ta.destroy_all
  end

  it "should properly reserve many_to_many" do
    notif = Notification.create
    notif.queue_users = QueueUser.all
    notif.save

    QueueUser.all.each do |qu|
      qu.notifications.where(:_id => notif.id).first.should == notif
    end

    notif.queue_users.count.should == QueueUser.count
  end
end
