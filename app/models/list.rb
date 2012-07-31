class List < ActiveRecord::Base
	has_many :items, :order => "position"
	belongs_to :listable, :polymorphic => true
end