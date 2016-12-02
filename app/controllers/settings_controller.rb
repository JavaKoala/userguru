class SettingsController < ApplicationController
  before_action :logged_in_user, only: [:index, :update]
  before_action :admin_user,     only: [:index, :update]

  def index
    @settings = Setting.all
    # Update the setting values to defaults if they are blank
    @settings.each do |setting|
      setting.value = setting_value(setting.name)
    end
  end

  def update
    @setting = Setting.find(params[:id])
    if @setting.update_attributes(settings_params)
      flash[:success] = "Setting updated"
    else
      flash[:danger] = @setting.errors.full_messages[0]
    end
    redirect_to settings_path
  end

  private

    def settings_params
      params.require(:setting).permit(:value)
    end
end
