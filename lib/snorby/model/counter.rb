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
