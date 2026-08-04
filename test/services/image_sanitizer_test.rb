require "test_helper"
require "base64"
require "stringio"

class ImageSanitizerTest < ActiveSupport::TestCase
  ORIENTED_JPEG = <<~BASE64.delete("\n")
    /9j/4AAQSkZJRgABAQAAGQAZAAD/4QCwRXhpZgAATU0AKgAAAAgABQESAAMAAAABAAYAAAEaAAUAAAAB
    AAAASgEbAAUAAAABAAAAUgEoAAMAAAABAAIAAIdpAAQAAAABAAAAWgAAAAAAAAB/AAAABQAAAH8AAAAF
    AAaQAAAHAAAABDAyMTCRAQAHAAAABAECAwCgAAAHAAAABDAxMDCgAQADAAAAAQABAACgAgAEAAAAAQAA
    AASgAwAEAAAAAQAAAAIAAAAA/+0AOFBob3Rvc2hvcCAzLjAAOEJJTQQEAAAAAAAAOEJJTQQlAAAAAAAQ
    1B2M2Y8AsgTpgAmY7PhCfv/AABEIAAIABAMBIgACEQEDEQH/xAAfAAABBQEBAQEBAQAAAAAAAAAAAQID
    BAUGBwgJCgv/xAC1EAACAQMDAgQDBQUEBAAAAX0BAgMABBEFEiExQQYTUWEHInEUMoGRoQgjQrHBFVLR
    8CQzYnKCCQoWFxgZGiUmJygpKjQ1Njc4OTpDREVGR0hJSlNUVVZXWFlaY2RlZmdoaWpzdHV2d3h5eoOE
    hYaHiImKkpOUlZaXmJmaoqOkpaanqKmqsrO0tba3uLm6wsPExcbHyMnK0tPU1dbX2Nna4eLj5OXm5+jp
    6vHy8/T19vf4+fr/xAAfAQADAQEBAQEBAQEBAAAAAAAAAQIDBAUGBwgJCgv/xAC1EQACAQIEBAMEBwUE
    BAABAncAAQIDEQQFITEGEkFRB2FxEyIygQgUQpGhscEJIzNS8BVictEKFiQ04SXxFxgZGiYnKCkqNTY3
    ODk6Q0RFRkdISUpTVFVWV1hZWmNkZWZnaGlqc3R1dnd4eXqCg4SFhoeIiYqSk5SVlpeYmZqio6Slpqeo
    qaqys7S1tre4ubrCw8TFxsfIycrS09TV1tfY2dri4+Tl5ufo6ery8/T19vf4+fr/2wBDAAICAgICAgMC
    AgMFAwMDBQYFBQUFBggGBgYGBggKCAgICAgICgoKCgoKCgoMDAwMDAwODg4ODg8PDw8PDw8PDw//2wBD
    AQICAgQEBAcEBAcQCwkLEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQ
    EBAQEBD/3QAEAAH/2gAMAwEAAhEDEQA/APi+iiiv5TP9/D//2Q==
  BASE64

  test "applies orientation and removes EXIF metadata" do
    source = Vips::Image.new_from_buffer(Base64.strict_decode64(ORIENTED_JPEG), "")
    sanitized = ImageSanitizer.call(
      io: StringIO.new(Base64.strict_decode64(ORIENTED_JPEG)),
      filename: "oriented.jpg",
    )

    image = Vips::Image.new_from_file(sanitized.fetch(:io).path)

    assert_includes source.get_fields, "exif-ifd0-Orientation"
    assert_equal "image/jpeg", sanitized.fetch(:content_type)
    assert_equal "oriented.jpg", sanitized.fetch(:filename)
    assert_equal 2, image.width
    assert_equal 4, image.height
    assert_empty image.get_fields.grep(/exif|orientation/i)
  ensure
    sanitized&.fetch(:io)&.close!
  end
end
