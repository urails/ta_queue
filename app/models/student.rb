class Student < QueueUser
  belongs_to :board
  belongs_to :ta, :class_name => "Ta"
  has_one :in_queue_duration

  field :in_queue, type: DateTime

  validates :location, :presence => true
  validates :location, :length => { :within => 1..20 }
  validates :location, :exclusion => { :in => ["location"] }

  validate :check_username_location, :on => :create

  scope :in_queue, where(:in_queue.ne => nil).asc(:in_queue)

  after_create :create_in_queue_duration

  #def output_hash
    #hash = {}
    #hash[:id] = id.to_s
    #hash[:username] = escp(username)
    #hash[:location] = escp(location)
    #hash[:in_queue] = (in_queue.nil? ? false : true)
    #hash
  #end

  def enter_queue
    if self.in_queue.nil?
      iqd = self.in_queue_duration ||= InQueueDuration.new

      date = DateTime.now
      self.in_queue = date

      iqd.enter_time = date
      iqd.save
    end
  end

  def enter_queue!
    enter_queue
    save
  end

  def exit_queue
    unless self.in_queue.nil?
      iqd = self.in_queue_duration

      iqd.exit_time = DateTime.now

      self.in_queue = nil

      unless self.ta.nil?
        iqd.was_helped = true
        self.ta = nil
      end

      iqd.save

      # Orphan off the old duration and build a new
      self.in_queue_duration = InQueueDuration.new
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
