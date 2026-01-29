class VideoThumbnailService
    def initialize(video, record)
      @video = video
      @record = record
    end
  
    def generate_thumbnail
      video_path = Rails.root.join("tmp", "video.mp4")
      thumbnail_path = Rails.root.join("tmp", "thumbnail.jpg")
  
      File.open(video_path, 'wb') do |file|
        file.write(@video.download)
      end
  
      system("ffmpeg -i #{video_path} -ss 00:00:01 -vframes 1 #{thumbnail_path}")
  
      if File.exist?(thumbnail_path)
        attach_thumbnail(thumbnail_path)
      end
  
      File.delete(video_path) if File.exist?(video_path)
      File.delete(thumbnail_path) if File.exist?(thumbnail_path)
    end
  
    private
  
    def attach_thumbnail(path)
      @record.thumbnail.attach(io: File.open(path), filename: 'thumbnail.jpg', content_type: 'image/jpeg')
    end
  end
  