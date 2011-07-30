module EventsHelper

  def event_port_number(event, type)
    if event.tcp?
      return event.tcp.send(:"tcp_#{type.to_s}")
    elsif event.udp?
      return event.udp.send(:"udp_#{type.to_s}")
    else
      nil
    end
  end
  
  
  def protocol(event)
    if event.tcp?
      :tcp
    elsif event.udp?
      :udp
    elsif event.icmp?
      :icmp
    else
      nil
    end
  end
  
end
