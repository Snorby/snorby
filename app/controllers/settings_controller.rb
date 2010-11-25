class SettingsController < ApplicationController

  before_filter :require_administrative_privileges

  def index
  end

  def create
    @params = params[:settings]
    @settings = Setting.all

    @settings.each do |setting|
      name = setting.name
      if @params.keys.include?(name)
        if @params[name].kind_of?(ActionDispatch::Http::UploadedFile)
          Setting.file(name, @params[name])
        else
          setting.update(:value => @params[name])
        end
      else
        setting.update(:value => nil) if setting.checkbox?
      end
    end

    redirect_to settings_path, :notice => 'Settings Updated Successfully.'
  end

  def update

  end

  def start_worker
    Snorby::Worker.start unless Snorby::Worker.running?
    redirect_to settings_path
  end

  def start_sensor_cache
    Snorby::Jobs.sensor_cache.destroy! if Snorby::Jobs.sensor_cache?
    Delayed::Job.enqueue(Snorby::Jobs::SensorCacheJob.new(false), 1)
    redirect_to settings_path
  end

  def start_daily_cache
    Snorby::Jobs.daily_cache.destroy! if Snorby::Jobs.daily_cache?
    Delayed::Job.enqueue(Snorby::Jobs::DailyCacheJob.new(false), 1, Time.now.tomorrow.beginning_of_day)
    redirect_to settings_path
  end

end
