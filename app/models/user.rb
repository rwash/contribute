class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable, :lockable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :name, :location, :picture

	has_many :projects, :dependent => :destroy

	#Setting whiny to false makes it not spit verbose serrors out if something like identify goes wrong
	#has_attached_file :picture, :styles => { :show => "200x200>", :thumb => "100x100>" }, :whiny => false	
	mount_uploader :picture, PictureUploader, :mount_on => :picture_file_name

  validates_attachment_content_type :picture, :content_type => /^image/, :message => "must be jpg, png, or gif"
  validates_attachment_size :picture, :less_than => 150000, :message => "cannot be larger than 150KB"

	validates :name, :presence => true
end
