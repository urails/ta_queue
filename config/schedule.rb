Crom.schedule do

   every '30m' do
     QueueUser.where(:alive_time.lt => DateTime.now - 2.hours).destroy_all
   end

  # cron '* * * * *' do
    # Some task
  # end

  # schedule_in '20m' do
    # Some task
  # end

  # schedule_at 'Thu Mar 26 07:31:43 +0900 2020' do
    # Some task
  # end

end
