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

module Snorby
  module Jobs

    class MassClassification < Struct.new(:classification_id, :options)

      def perform
        @events = Event.all(options)
        @classification = Classification.get(classification_id)

        @events.each do |event|
          next unless event

          old_classification = event.classification || false

          if @classification.blank?
            event.classification = nil
          else
            event.classification = @classification
          end

          if event.save
            @classification.up(:events_count) if @classification
            old_classification.down(:events_count) if old_classification
          end

        end
      end

    end
  end
end
