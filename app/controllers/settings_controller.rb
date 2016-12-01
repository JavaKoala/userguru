class SettingsController < ApplicationController

  def index
    @settings = Setting.all
    # Update the setting values to defaults if they are blank
    @settings.each do |setting|
      setting.value = setting_value(setting.name)
    end
  end
  
  def update
  end
end
