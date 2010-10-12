class AdminController < ApplicationController

  def settings
    
  end

  def severity
    @severity = Severity.first(:sig_id => params[:id])
    if @severity.update(params[:severity])
    else
    end
  end

end
