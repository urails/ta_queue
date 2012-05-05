class Instructor
  include Mongoid::Document
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  attr_accessor :master_password
  before_create :check_master_password

  ## Database authenticatable
  field :email,              :type => String, :null => false, :default => ""
  field :encrypted_password, :type => String, :null => false, :default => ""

  ## Recoverable
  field :reset_password_token,   :type => String
  field :reset_password_sent_at, :type => Time

  ## Rememberable
  field :remember_created_at, :type => Time

  ## Trackable
  field :sign_in_count,      :type => Integer, :default => 0
  field :current_sign_in_at, :type => Time
  field :last_sign_in_at,    :type => Time
  field :current_sign_in_ip, :type => String
  field :last_sign_in_ip,    :type => String

  # ATTRIBUTES

  field :name, type: String
  field :username, type: String

  # ASSOCIATIONS

  belongs_to :school
  has_many :school_queues, dependent: :destroy

  # SCOPES
  
  # CALLBACKS

  def queues
    self.school_queues
  end

  def to_param
    username
  end

  private
    
    def check_master_password
      if self.master_password != self.school.master_password
        self.errors[:master_password] = "is invalid"
      end
    end

end
