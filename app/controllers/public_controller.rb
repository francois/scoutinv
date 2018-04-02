class PublicController < ApplicationController
  skip_before_action :authenticate_member!
end
