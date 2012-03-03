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

  #
  # Search
  #
  module Search

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
            :id => :source_port,
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
