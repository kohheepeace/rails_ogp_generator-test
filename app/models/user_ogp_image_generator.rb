class UserOgpImageGenerator
  include Magick
  require 'base64'

  def generate
    user_id = 1
    user_name = "Della Zemlak"
    user_job = "Amazon inc CEOです"
    user_bio = "This impressive paella is a perfect party dish and a fun meal to cook together with your guests. Add 1 cup of frozen peas along with the mussels, if you like. This impressive paella is a perfect party dish and a fun meal to cook together with your guests. Add 1 cup of frozen peas along with the mussels, if you like."

    image = Magick::ImageList.new

    # image canvas
    image.new_image(1200, 630) do
      # canvas background color
      self.background_color = '#fff'
    end

    # draw text config
    draw = Magick::Draw.new
    draw.gravity = Magick::CenterGravity
    draw.font = Rails.root.join('app', 'assets', 'fonts', 'NotoSansCJKjp-Medium.otf').to_s
    draw.fill = '#000'

    # avatar
    avatar_image = Magick::Image.from_blob(open("https://pbs.twimg.com/profile_images/1105663166334230529/6M_HE8S7_400x400.jpg").read).first
    avatar_image = avatar_image.resize(320, 320)
    avatar_image = make_circle_mask(avatar_image, 320)
    image.composite!(avatar_image, Magick::CenterGravity, -380, -100, Magick::OverCompositeOp)

    # write name to canvas
    if user_name.present?
      draw.pointsize = 58
      draw.annotate(image, 0, 0, -60, -240, user_name) {
        self.fill = '#000'
      }
    end

    # write job title to canvas
    if user_job.present?
      draw.pointsize = 30
      draw.annotate(image, 0, 0, -60, -180, user_job) {
        self.fill = 'rgba(0, 0, 0, 0.54)'
      }
    end

    # write bio to canvas
    if user_bio.present?
      draw.pointsize = 40
      draw.annotate(image, 0, 0, -60, -140, user_bio) {
        self.fill = '#000'
      }
    end

    # convert image to png binary
    # png_bytes = image.to_blob { |attrs| attrs.format = 'PNG' }
    # data_uri = Base64.encode64(png_bytes)
    # data_uri = URI.escape(data_uri)

    # Upload to cloudinary
    # auth = {
    #   cloud_name: "",
    #   api_key:    "",
    #   api_secret: ""
    # }
    # Cloudinary::Uploader.upload(data_uri, auth)


    # save image for checking image
    dist_dir = "#{Rails.root.join('tmp', 'ogp_image')}"
    Dir.mkdir(dist_dir) unless File.exists?(dist_dir)
    dist_path = "#{dist_dir}/#{user_id}-#{user_name}.png"
    image.write(dist_path)
    dist_path
  end

  private

  def make_circle_mask(image, size)
    circle_image = Magick::Image.new(size, size)
    draw = Magick::Draw.new

    # ref: https://rmagick.github.io/draw.html#circle
    draw.circle(size / 2, size / 2, size / 2, 0)
    draw.draw(circle_image)
    mask = circle_image.blur_image(0, 1).negate
    mask.matte = false

    image.matte = true
    image.composite!(mask, Magick::CenterGravity, Magick::CopyOpacityCompositeOp)

    image
  end
end