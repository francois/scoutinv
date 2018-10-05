require "net/http"
require "stringio"

class ImportProductImageJob < ApplicationJob
  def perform(product, url)
    uri = URI.parse(url)

    Product.transaction do
    end
  end
end
