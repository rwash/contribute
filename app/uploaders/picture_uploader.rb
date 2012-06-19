class PictureUploader < CarrierWave::Uploader::Base
	include CarrierWave::Compatibility::Paperclip
	include CarrierWave::RMagick
	
	def extension_white_list
		%w(jpg jpeg gif png)
	end

	version :thumb do
		begin
			process :resize_to_fill => [230,159]
		rescue
			raise CarrierWave::ProcessingError
		end
	end

	version :show do
		begin
			process :resize_to_fill => [200,200]
		rescue
			raise CarrierWave::ProcessingError
		end
	end
	
	version :user do
		begin
			process :resize_to_fill => [170,170]
		rescue
			raise CarrierWave::ProcessingError
		end
	end
end
