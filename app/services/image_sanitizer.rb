require "tempfile"

class ImageSanitizer
  class Error < StandardError; end

  FORMATS = {
    "image/jpeg" => { format: :jpeg, extension: "jpg" },
    "image/png" => { format: :png, extension: "png" },
    "image/webp" => { format: :webp, extension: "webp" },
  }.freeze

  def self.call(attachable)
    new(attachable).call
  end

  def initialize(attachable)
    @attachable = attachable
  end

  def call
    input = copy_input_to_tempfile
    content_type = Marcel::MimeType.for(input, name: filename)
    format = FORMATS.fetch(content_type) do
      raise Error, "unsupported image format"
    end

    output = ImageProcessing::Vips
      .source(input)
      .convert(format.fetch(:format))
      .saver(strip: true, quality: 80)
      .call

    {
      io: output,
      filename: "#{basename}.#{format.fetch(:extension)}",
      content_type: content_type,
    }
  rescue Vips::Error, ImageProcessing::Error => error
    raise Error, error.message
  ensure
    input&.close!
  end

  private

  def copy_input_to_tempfile
    tempfile = Tempfile.new([ "image-upload", File.extname(filename) ], binmode: true)
    source = input_io
    source.rewind if source.respond_to?(:rewind)
    IO.copy_stream(source, tempfile)
    tempfile.rewind
    tempfile
  end

  def input_io
    return @attachable.tempfile if @attachable.respond_to?(:tempfile)

    @attachable.fetch(:io)
  end

  def filename
    return @attachable.original_filename if @attachable.respond_to?(:original_filename)

    @attachable.fetch(:filename)
  end

  def basename
    File.basename(filename, File.extname(filename)).presence || "image"
  end
end
