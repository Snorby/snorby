module Snorby
  module Jobs
    class MassClassification < Struct.new(:ids, :classification_id, :user_id)

      def perform
        Event.update_classification(ids, classification_id.to_i, user_id.to_i)
      end

    end
  end
end

