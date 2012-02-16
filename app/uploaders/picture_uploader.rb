class PictureUploader < CarrierWave::Uploader::Base
	include CarrierWave::Compatibility::Paperclip
	include CarrierWave::RMagick

	version :thumb do
		process :resize_to_fill => [100,100]
	end

	version :show do
		process :resize_to_fill => [200,200]
	end
end
