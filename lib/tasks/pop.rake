namespace :db do
  desc "Fill daboardbase with sample board"

  task :pop => :environment do
    Board.destroy_all

    board = Board.create!(:title => "CS1410", :password => "foobar", :active => true)
    board.tas.create!(:username => "Parker", :token => SecureRandom.uuid, :password => board.password, )
    board.tas.create!(:username => "Michael", :token => SecureRandom.uuid, :password => board.password, )
    10.times do |i|
      board.students.create!(:username => "Student #{i}", :location => "lab1-#{i}", :token => SecureRandom.uuid, :in_queue => DateTime.now + i.seconds)
    end
  end

  task :reset => :environment do
    Mongoid.master.collections.select {|c| c.name !~ /system/ }.each(&:drop)
  end
  
end
