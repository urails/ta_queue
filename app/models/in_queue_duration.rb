class InQueueDuration
  include Mongoid::Document

  belongs_to :student

  field :enter_time, type: DateTime
  field :exit_time, type: DateTime
  field :was_helped, type: Boolean, default: false

  def time_in_queue type = :seconds
    time = (exit_time.to_f - enter_time.to_f)
    if type == :seconds
      return time
    elsif type == :minutes
      return time / 60
    elsif type == :hours
      return (time / 60) / 60
    end
  end
end
