class Student < QueueUser
  
  # ATTRIBUTES
  
  field :in_queue, type: DateTime
  field :question, type: String
  
  # ASSOCIATIONS

  belongs_to :ta, :class_name => "Ta"
  # NOTE: there does NOT need to be a belongs_to :school_queue because that
  # is declared in QueueUser

  # Used for statistics
  has_one :in_queue_duration, dependent: :nullify

  # VALIDATIONS

  validates :location, :presence => true
  validates :location, :length => { :within => 1..20 }
  validates :location, :exclusion => { :in => ["location"] }
  validate :check_username_location, :on => :create
  validate :check_question_if_question_based

  # SCOPES

  default_scope asc(:in_queue)
  scope :in_queue, where(:in_queue.ne => nil).asc(:in_queue)

  # CALLBACKS
  
  before_save :detect_ta_change
  after_create :create_new_in_queue_duration
  before_destroy :nullify_in_queue_duration

  def enter_queue
    if self.in_queue.nil?
      return unless check_question_if_question_based
      iqd = self.in_queue_duration ||= self.queue.in_queue_durations.new

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

      # Orphan off the old duration and build a new one
      self.in_queue_duration = self.queue.in_queue_durations.new
    end
  end

  def exit_queue!
    exit_queue
    save
  end

  def putback!
    self.putback
    self.save
  end

  def putback
    if self.in_queue
      self.ta = nil
    end
  end

  private

    def check_username_location
      if Student.where(:username => self.username, :location => self.location).first
        self.errors[:base] = "This username and location are already being used. Are you already logged in somewhere else?"
      end
    end

    def check_question_if_question_based
      if self.in_queue && self.queue.is_question_based
        if question.blank?
          self.errors[:question] = "is blank, must provide a question." 
          return false
        end
      end
      return true
    end

    def create_new_in_queue_duration
      iqd = self.in_queue_duration = self.queue.in_queue_durations.new
      iqd.save
    end

    def nullify_in_queue_duration
      idq = self.in_queue_duration
      idq.exit_time = DateTime.now
    end

    # If a TA starts helping a student while they're in the queue,
    # we need to mark their InQueueDuration.was_helped = true
    def detect_ta_change
      if self.ta_id.present? && self.in_queue
        idq = self.in_queue_duration
        idq.was_helped = true   
        idq.save
      end
    end

end
