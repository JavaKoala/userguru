module SettingsHelper

  # Method to return the default setting value
  def default_setting_value(setting_name)
    case setting_name
    when "application_name"
      "USER GURU"
    when "tagline_1"
      "Welcome to User Guru"
    when "tagline_2"
      "Location for all your user needs"
    else
      ""
    end
  end

  # Method to return the value from the settings table
  # It accepts the setting name
  # If the setting name does not exist it returns the input
  # If the setting name exists but the value is empty it returns the default value
  # If the setting name exists and the value is not empty it returns the value
  def setting_value(setting_name)
    if Setting.exists?(name: setting_name)
      setting = Setting.find_by(name: setting_name)
      if setting.value.empty?
        default_setting_value(setting_name)
      else
        setting.value
      end
    else
      setting_name
    end
  end
end
