class SettingsController < ApplicationController

  before_filter :require_administrative_privileges

  def index
    @process = Snorby::Worker.process
  end

end
