class InQueueDuration
  include Mongoid::Document

  belongs_to :student
  belongs_to :school_queue

  scope :finished, where(:enter_time.ne => nil, :exit_time.ne => nil)

  field :enter_time, type: DateTime
  field :exit_time, type: DateTime
  field :was_helped, type: Boolean, default: false

  def time_in_queue type = :seconds
    raise Exception, "Missing exit time" unless self.exit_time
    raise Exception, "Missing enter time" unless self.enter_time

    time = (exit_time.to_f - enter_time.to_f)
    if type == :seconds
      return time
    elsif type == :minutes
      return time / 60
    elsif type == :hours
      return (time / 60) / 60
    end
  end

  def queue
    school_queue
  end
end
