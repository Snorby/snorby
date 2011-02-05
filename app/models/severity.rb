require 'snorby/model'

class Severity
  
  include Snorby::Model

  has_many :signatures

  validates_presence_of :sig_id, :name, :text_color
  validates_uniqueness_of :sig_id
  validates_format_of :text_color, :with => /^#?([a-f]|[A-F]|[0-9]){3}(([a-f]|[A-F]|[0-9]){3})?$/, :message => "is invalid"
  validates_format_of :bg_color, :with => /^#?([a-f]|[A-F]|[0-9]){3}(([a-f]|[A-F]|[0-9]){3})?$/, :message => "is invalid"

  def locked?
    return true if [1,2,3].include?(id)
    false
  end

end
