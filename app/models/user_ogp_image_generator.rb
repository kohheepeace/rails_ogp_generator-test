class UserOgpImageGenerator
  include Magick
  require 'base64'
  require 'word_wrap/core_ext'

  def initialize(id="", name="", job="", bio="")
    @id = id.present? ? id : 1
    @name = name.present? ? name : "Della Zemlak"
    @job = job.present? ? job : "Amazon inc CEOです"
    @bio = bio.present? ? bio : "This impressive paella is a perfect party dish and a fun meal to cook together with your guests. Add 1 cup of frozen peas along with the mussels, if you like. This impressive paella is a perfect party dish and a fun meal to cook together with your guests. Add 1 cup of frozen peas along with the mussels, if you like."
  end

  def generate
    user_id = @id
    user_name = @name
    user_job = @job
    user_bio = @bio

    user_bio = user_bio.fit 50

    image = Magick::ImageList.new

    # image canvas
    image.new_image(1200, 630) do
      # canvas background color
      self.background_color = '#fff'
    end

    # draw text config
    draw = Magick::Draw.new
    draw.gravity = Magick::CenterGravity
    # draw.font = Rails.root.join('app', 'assets', 'fonts', 'NotoSansCJKjp-Medium.otf').to_s
    draw.font = "Noto-Sans-CJK-JP-Medium"
    draw.fill = '#000'

    # avatar
    avatar_image = Magick::Image.from_blob(open("https://pbs.twimg.com/profile_images/1105663166334230529/6M_HE8S7_400x400.jpg").read).first
    avatar_image = avatar_image.resize(300, 300)
    avatar_image = make_circle_mask(avatar_image, 300)
    image.composite!(avatar_image, Magick::CenterGravity, -380, -111, Magick::OverCompositeOp)

    # write name to canvas
    if user_name.present?
      draw.pointsize = 60
      draw.annotate(image, 0, 0, 417, 55, user_name) {
        self.fill = '#000'
        self.gravity = Magick::NorthWestGravity
      }
    end

    # write job title to canvas
    if user_job.present?
      draw.pointsize = 27
      draw.annotate(image, 0, 0, 423, 130, user_job) {
        self.fill = 'rgba(0, 0, 0, 0.54)'
        self.gravity = Magick::NorthWestGravity
      }
    end

    # write bio to canvas
    if user_bio.present?
      draw.pointsize = 35
      draw.annotate(image, 0, 0, 423, 200, user_bio) {
        self.font = "Noto-Sans-CJK-JP-Regular"
        self.gravity = Magick::NorthWestGravity
        self.kerning = -2
        self.interword_spacing = 12
        self.interline_spacing = -5
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
    draw.stroke_width(5)
    draw.stroke('gray50')
    draw.circle(size / 2, size / 2, size / 2, 5)
    draw.draw(circle_image)
    mask = circle_image.blur_image(0, 1).negate
    mask.matte = false

    image.matte = true
    image.composite!(mask, Magick::CenterGravity, Magick::CopyOpacityCompositeOp)

    image
  end
end
