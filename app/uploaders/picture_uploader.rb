class PictureUploader < CarrierWave::Uploader::Base
  include CarrierWave::Compatibility::Paperclip
  include CarrierWave::MiniMagick

  def extension_white_list
    %w(jpg jpeg gif png)
  end

  version :thumb do
    begin
      process resize_to_limit: [100,100]
    rescue
      raise CarrierWave::ProcessingError
    end
  end

  version :show do
    begin
      process resize_to_fill: [250,250]
    rescue
      raise CarrierWave::ProcessingError
    end
  end

  version :user do
    begin
      process resize_to_fill: [150,150]
    rescue
      raise CarrierWave::ProcessingError
    end
  end
end
