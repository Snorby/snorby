# Snorby - All About Simplicity.
# 
# Copyright (c) 2010 Dustin Willis Webber (dustin.webber at gmail.com)
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA

# Snorby
module Snorby

# select a.* 
# from (select event.* from event
 # inner join tcphdr on event.sid = tcphdr.sid and event.cid = tcphdr.cid 
# where 1 = 0 or (tcphdr.tcp_dport = 80)

# union

# select  event.* from event
 # inner join udphdr on event.sid = udphdr.sid and event.cid = udphdr.cid 
# where 1 = 0 or (udphdr.udp_dport > 1)

# union

# select  event.* from event
 # inner join signature on event.signature = signature.sig_sid 
# where 1 = 0 or (signature.sig_name is not null)) a
# order by a.timestamp desc
# limit 100 
# offset 10

  #
  # Search
  #
  module Search

    COLUMN = {
      :signature => "event.signature",
      :signature_name => "signature.sig_name",
      :source_ip => "iphdr.ip_src",
      :destination_ip => "iphdr.ip_dst",
      :source_port => {
        :tcp => "tcphdr.tcp_sport",
        :udp => "udphdr.udp_sport"
      },
      :destination_port => {
        :tcp => "tcphdr.tcp_dport",
        :udp => "udphdr.udp_dport"
      },
      :classification => "event.classification_id",
      :sensor => "event.sid",
      :user => "event.user_id",
      :payload => "data.data_payload",
      :start_time => "event.timestamp",
      :end_time => "event.timestamp"
    }

    OPERATOR = {
      :is => "= ?",
      :is_not => "!= ?",
      :contains => "LIKE ?",
      :contains_not => 'NOT LIKE ?',
      :gte => ">= ?",
      :lte => "<= ?",
      :lt => "< ?",
      :gt => "> ?",
      :in => "IN (?)",
      :notnull => "NOT NULL ?"
    }

    EXAMPLE = {"0"=>{"column"=>"source_port", "operator"=>"is", "value"=>"80"}, "1"=>{"column"=>"destination_ip", "operator"=>"is", "value"=>"10.0.1.1"}, "2"=>{"column"=>"signature", "operator"=>"is", "value"=>"1"}, "3"=>{"column"=>"classification", "operator"=>"is", "value"=>"1"}, "4"=>{"column"=>"sensor", "operator"=>"is", "value"=>"1"}, "5"=>{"column"=>"start_time", "operator"=>"gte", "value"=>"2012/02/21 12:05:17"}}

    OR = lambda do |data|
      "select a.* from (#{data}) a"
    end

    AND = lambda do |data|
      "select event.* from event #{data}"
    end

    DO_OR = lambda do |data|
      return "select event.* from event #{data} where 1 = 0 or " if data
      "select event.* from event where 1 = 0 or "
    end

    TCP = "inner join tcphdr on event.sid = tcphdr.sid and event.cid = tcphdr.cid "

    UDP = "inner join udphdr on event.sid = udphdr.sid and event.cid = udphdr.cid "

    SIGNATURE = "inner join signature on event.signature = signature.sig_sid "

    SENSOR = "inner join sensor on event.sid = sensor.sid "

    IP = "inner join iphdr on event.sid = iphdr.sid and event.cid = iphdr.cid "

    PAYLOAD = "inner join data on event.sid = data.sid and event.cid = data.cid "

    DEFAULT_PROCESS = lambda do |data|
      data
    end

    BUILD = {
      :or => {
        :event => { 
          :sql => DO_OR.call(false),
          :process => DEFAULT_PROCESS
        },
        :tcp => {
          :sql => DO_OR.call(TCP),
          :process => DEFAULT_PROCESS,
        },
        :udp => { 
          :sql => DO_OR.call(UDP),
          :process => DEFAULT_PROCESS
        },
        :signature => { 
          :sql => DO_OR.call(SIGNATURE),
          :process => DEFAULT_PROCESS
        },
        :sensor => { 
          :sql => DO_OR.call(SENSOR),
          :process => DEFAULT_PROCESS
        },
        :payload => { 
          :sql => DO_OR.call(PAYLOAD),
          :process => lambda do |data|
            convert_values = []
            data.each do |x|
              hex = ""
              x.to_s.each_char { |x| hex += x.unpack('H*')[0] }
              convert_values.push("%#{hex}%")
            end
            convert_values
          end
        },
        :ip => { 
          :sql => DO_OR.call(IP),
          :process => lambda do |data|
            tmp = []
            data.each do |ip|
              tmp.push(IPAddr.new(ip.to_s).to_i)
            end
            tmp
          end
        }
      },
      :and => {
        :event => { 
          :sql => "",
          :process => DEFAULT_PROCESS
        },
        :tcp => { 
          :sql => TCP,
          :process => DEFAULT_PROCESS
        },
        :udp => {
          :sql => UDP,
          :process => DEFAULT_PROCESS
        },
        :signature => {
          :sql => SIGNATURE,
          :process => DEFAULT_PROCESS
        },
        :sensor => {
          :sql => SENSOR,
          :process => DEFAULT_PROCESS
        },
        :payload => {
          :sql => PAYLOAD,
          :process => DEFAULT_PROCESS
        },
        :ip => {
          :sql => IP,
          :process => lambda do |data|
            tmp = []
            data.each do |ip|
              tmp.push(IPAddr.new(ip.to_s).to_i)
            end
            tmp
          end
        }
      }
    }

    MAP = {
      :source_port => [:tcp, :udp],
      :source_ip => :ip,
      :destination_port => [:tcp, :udp],
      :destination_ip => :ip,
      :signature_name => [:signature],
      :signature => :event,
      :payload => :payload,
      :start_time => :event,
      :end_time => :event,
      :classification => :event,
      :user => :event,
      :sensor => :event,
      :sensor_name => :sensor
    }

    def self.joins
      [
        :event,
        :signature,
        :payload, 
        :ip, 
        :sensor,
        :tcp, 
        :udp
      ]
    end

    def self.all(&block)
      all = []
      self.joins.each do |x|
        block.call(x) if block
        all.push instance_variable_get("@" + x.to_s)
      end
      all
    end

    def self.build(matchall, params=EXAMPLE)
      self.joins.each do |x|
        instance_variable_set("@" + x.to_s, [])
        instance_variable_set("@" + x.to_s + "_value", [])
      end

      @type = if matchall === "true"
        :and
      else
        :or
      end

      @params = params
      
      self.build_logic
      self.perform
    end

    def self.perform
      sql = []
      values = []

      if @type.to_sym == :or
        join_string = " OR "
        sql_join_string = " UNION "
        pack = OR
      else
        join_string = " AND "
        sql_join_string = " "
        pack = AND
        and_values = []
      end

      self.all do |x|
        k = instance_variable_get("@" + x.to_s)
        v = instance_variable_get("@" + x.to_s + "_value")

        unless k.empty?
          if @type == :or
            sql.push(BUILD[@type][x.to_sym][:sql] + "(#{k.join(join_string)})")
            values.push(BUILD[@type][x.to_sym][:process].call(v)).flatten!
          else
            sql.push(BUILD[@type][x.to_sym][:sql])
            and_values.push("(#{k.join(join_string)})")
            values.push(BUILD[@type][x.to_sym][:process].call(v)).flatten!
          end
        end
      end

      if @type == :and
        # hack = []
        # p and_values

        # and_values.each_with_index do |value, index|
          # if value.match(/^\(tcphdr\.|^\(udphdr\./)
            # hack.push(value)
            # and_values.delete_at(index)
          # end
        # end

        # p hack
        # hacked_values = "(#{hack.join(" OR ")})"
        # p hacked_values
        # and_values.push(hacked_values)

        sql = ["#{sql.join} where #{and_values.join(join_string)}"]
      end

      total_sql = []
      total_sql.push(pack.call(sql.join(sql_join_string)) + " LIMIT ? OFFSET ?")
      total_sql.push(values.flatten).flatten!

      total_sql
    end

    def self.build_logic
      @params.each do |k,v|
        column = v['column'].to_sym
        operator = v['operator'].to_sym
        value = v['value']

        if MAP.has_key?(column.to_sym)
          map_value = MAP[column.to_sym]

          if map_value.is_a?(Array)

            map_value.each do |x|
              tmp_sql = "#{COLUMN[column][x]} #{OPERATOR[operator]}"
              instance_variable_get("@" + x.to_s).push(tmp_sql)
              instance_variable_get("@" + x.to_s + "_value").push(value)
            end

          else
            tmp_sql = "#{COLUMN[column]} #{OPERATOR[operator]}"
            instance_variable_get("@" + map_value.to_s).push(tmp_sql)
            instance_variable_get("@" + map_value.to_s + "_value").push(value)
          end

        end
      end
    end

    def self.json
      @signatures ||= Signature.all(:fields => [:sig_name, :sig_id])
      @classifications ||= Classification.all(:fields => [:name, :id])
      @users ||= User.all(:fields => [:name, :id])
      @sensors ||= Sensor.all(:fields => [:name, :sid])

      @json ||= {
        :operators => {
          :more_text_input => [
            {
              :id => :is,
              :value => "is"
            },
            {
              :id => :is_not,
              :value => "is not"
            },
            {
              :id => :contains,
              :value => "contains"
            },
            {
              :id => :contains_not,
              :value => "does not contain"
            }
          ],
          :text_input => [
            {
              :id => :is,
              :value => "is"
            },
            {
              :id => :is_not,
              :value => "is not"
            }
          ],
          :datetime => [
            {
              :id => :is,
              :value => "is"
            },
            {
              :id => :is_not,
              :value => "is not"
            },
            {
              :id => :contains,
              :value => "contains"
            },
            {
              :id => :contains_not,
              :value => "does not contain"
            },
            {
              :id => :gt,
              :value => "greater than"
            },
            {
              :id => :gte,
              :value => "greater than or equal to"
            },
            {
              :id => :lt,
              :value => "less than"
            },
            {
              :id => :lte,
              :value => "less than or equal to"
            }
          ]
        },
        :columns => [
          {
            :value => "Source Address",
            :id => :source_ip,
            :type => :text_input
          },
          {
            :value => "Source Port",
            :id => :source_port,
            :type => :text_input
          },
          {
            :value => "Destination Address",
            :id => :destination_ip,
            :type => :text_input
          },
          {
            :value => "Destination Port",
            :id => :destination_port,
            :type => :text_input
          },
          {
            :value => "Classification",
            :id => :classification,
            :type => :select
          },
          {
            :value => "Signature",
            :id => :signature,
            :type => :select
          },
          {
            :value => "Classified By",
            :id => :user,
            :type => :select
          },
          {
            :value => "Sensor",
            :id => :sensor,
            :type => :select
          },
          {
            :value => "Start Time",
            :id => :start_time,
            :type => :text_input
          },
          {
            :value => "End Time",
            :id => :end_time,
            :type => :text_input
          },
          {
            :value => "Payload",
            :id => :payload,
            :type => :text_input
          },
          {
            :value => "Protocol",
            :id => :protocol,
            :type => :select
          }
        ],
        :protocol => {
          :value => [
            {
              :id => :tcp,
              :value => "TCP"
            },
            {
              :id => :udp,
              :value => "UDP"
            },
            {
              :id => :icmp,
              :value => "ICMP"
            }
          ]
        },
        :classifications => {
          :type => :dropdown,
          :value => @classifications.collect do |x|
            {
              :id => x.id,
              :value => x.name
            }
          end
        },
        :signatures => {
          :type => :dropdown,
          :value => @signatures.collect do |x|
            {
              :id => x.sig_id,
              :value => x.sig_name
            }
          end
        },
        :users => {
          :type => :dropdown,
          :value => @users.collect do |x|
            {
              :id => x.id,
              :value => x.name
            }
          end
        },
        :sensors => {
          :type => :dropdown,
          :value => @sensors.collect do |x|
            {
              :id => x.sid,
              :value => x.name
            }
          end
        }
      }

      @json.to_json.html_safe
    end

  end # Search
end # Snorby
