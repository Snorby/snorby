require 'snorby/payload'

class Payload

  set_table_name "data"
  
  belongs_to :sensor, :required => true
  
  belongs_to :event, :required => true

  def to_s
    Snorby::Payload.new([data_payload].pack('H*'), :width => 26).to_s
  end
  
  def to_html
    return Snorby::Payload.new([data_payload].pack('H*'), :width => 26, :html => true).to_s.html_safe if data_payload
    nil
  end
  
  def to_ascii
    return Snorby::Payload.new([data_payload].pack('H*'), :width => 26, :ascii => true, :new_lines => true).to_s.html_safe if data_payload
    nil
  end

end
