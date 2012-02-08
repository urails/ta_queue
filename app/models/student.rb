class Student < QueueUser
  belongs_to :board
  belongs_to :ta, :class_name => "Ta"

  field :in_queue, type: DateTime

  validates :location, :presence => true
  validates :location, :length => { :within => 1..20 }
  validates :location, :exclusion => { :in => ["location"] }

  validate :check_username_location, :on => :create

  scope :in_queue, where(:in_queue.ne => nil, :ta_id => nil).asc(:in_queue)
  
  def output_hash
    hash = {}
    hash[:id] = id.to_s
    hash[:username] = escp(username)
    hash[:location] = escp(location)
    hash[:in_queue] = (in_queue.nil? ? false : true)
    hash
  end

  def enter_queue
    if self.in_queue.nil?
      self.in_queue = DateTime.now
    end
  end

  def enter_queue!
    enter_queue
    save
  end

  def exit_queue
    unless self.in_queue.nil?
      self.in_queue = nil
    end
    unless self.ta.nil?
      self.ta = nil
    end
  end

  def exit_queue!
    exit_queue
    save
  end

  private

    def check_username_location
      if Student.where(:username => self.username, :location => self.location).first
        self.errors["username"] = "This username and location are already logged in. Are you already logged in somewhere else?"
      end
    end

end
