class CommonController < ApplicationController

  def set_user
    # シークレットキーは無視、アクセスキーのみでユーザー判定
    api_key = request.headers.env["HTTP_ACCESS_KEY"] || params[:user_key]
    @user = User.find_by(api_key: api_key)
    if @user.nil?
      # userが存在しないので新規作成して証拠金も設定
      @user = User.create!(api_key: api_key,
                           balance_attributes: {},
                           leverage_balance_attributes: {})
    end
  end
end