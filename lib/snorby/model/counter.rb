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
  module Model
    
    module Counter

      def up(column, amount=1)
        if self.respond_to?(column.to_sym)
          count = self.send(column.to_sym).to_i + amount
          self.update(column.to_sym => count)
        end
      end

      def down(column, amount=1)
        if self.respond_to?(column.to_sym)
          count = self.send(column.to_sym).to_i - amount
          if count <= 0
            self.update(column.to_sym => 0)
          else
            self.update(column.to_sym => count)
          end

          self.save!
        end

      end

    end

  end
end
