class QueueUser
  include Mongoid::Document

  has_and_belongs_to_many :notifications

  field :username, type: String
  field :token, type: String, default: -> { SecureRandom.uuid }
  field :location, type: String
  field :alive_time, type: DateTime, default: -> { DateTime.now }

  validates :username, :token, :presence => true
  validates :username, :length => { :within => 1..40 }
  validates :username, :exclusion => { :in => ["username", "Username", "name", "Name"], :message => "Please choose a different username" }

  #def as_json options = {}
    #output_hash
  #end

  def to_xml
    output_hash.to_xml 
  end


  def ta?
    self.class == Ta
  end

  def student?
    self.class == Student
  end

  def keep_alive 
    if self.alive_time.nil?
      self.alive_time = DateTime.now
      self.save
      logger.debug "Alive time updated"
    else
      if self.alive_time + 15.minutes < DateTime.now
        self.alive_time = DateTime.now
        self.save
        logger.debug "Alive time updated"
      end
    end
  end

end
