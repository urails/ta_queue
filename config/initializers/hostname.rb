if Rails.env == "production"
  QUEUE_HOSTNAME = "nine.eng.utah.edu"
elsif
  QUEUE_HOSTNAME = "localhost"
end

