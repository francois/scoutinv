class Dev::AuthController < ApplicationController
  skip_before_action :authenticate_member!

  def show
    reset_session
    member = Member.find_by!(email: params[:email])
    sign_in_member!(member)

    redirect_to root_path, notice: t(".authenticated_as", email: member.email)
  end
end
