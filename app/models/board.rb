class Board
  include Mongoid::Document

  field :title, type: String
  field :password, type: String
  # This is now part of the queue but here to show the old way we did it:
  # field :frozen, type: Boolean, default: false
  field :active, type: Boolean, default: false

  before_create :create_queue # create_queue is defined by Mongoid

  has_many :students, dependent: :destroy
  has_many :tas, dependent: :destroy
  has_one :queue, class_name: "BoardQueue", dependent: :destroy

  validates :title, :presence => true
  validates :title, :uniqueness => true
  validates :title, :format => { :with => /^[a-zA-Z_\-0-9]*$/, :message => "The title of a queue must contain only numbers, letters, _, and -"}

  before_save :purge_if_inactive
  before_save :check_if_active

  def queue_users
    QueueUser.where(:board_id => self.id)
  end

  def to_xml options = {}
    state.to_xml
  end

  def to_param
    self.title
  end

  private
    def purge_if_inactive
      unless active
        self.students.each do |stud|
          stud.exit_queue!
        end
      end
    end

    # If the board went from inactive to active, make sure the board gets unfrozen too
    def check_if_active
      if self.active_changed? && self.active
        _board_queue = self.queue
        _board_queue.frozen = false
        _board_queue.save
      end
    end
end
