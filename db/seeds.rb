# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

School.destroy_all
Instructor.destroy_all
SchoolQueue.destroy_all
QueueUser.destroy_all


school = School.create! name: "University of Utah", contact_email: "foo@bar.com", abbreviation: "uofu", master_password: "foobar"

instructor = school.instructors.create! name: "Erin Parker", email: "eparker@utah.edu", password: "foobar", password_confirmation: "foobar", username: "eparker"

queue = instructor.queues.create!({ 
                                    title: "Introduction to Java", 
                                    class_number: "CS1410",
                                    password: "foobar"
                                  })
