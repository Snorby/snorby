module DataMapper
  module Pagination

    include Snorby::Jobs::CacheHelper

    def page(page = nil, options = {}, sql=false, count=false)
      options, page = page, nil if page.is_a? Hash
      page_param  = pager_option(:page_param, options)
      page ||= pager_option page_param, options
      options.delete page_param
      page = 1 unless (page = page.to_i) && page > 1
      per_page    = pager_option(:per_page, options).to_i
      query = options.dup
      total = query.delete(:total)

      options = {
        :limit => per_page,
        :offset => (page - 1) * per_page,
        :order => [:id.desc]
      }

      if sql
        
        if sql.kind_of?(Array)
          sql.push([options[:limit], options[:offset]]).flatten!
        else
          sql += " LIMIT #{options[:limit]} OFFSET #{options[:offset]}"
        end

        if count
          total = if count.kind_of?(Array)
            db_select(count.first, *(count.shift; count))
          else
            db_select(count)
          end.first.to_i
        end

        collection = find_by_sql(sql)
      else
        collection = new_collection scoped_query(options.merge(query))
      end

      query.delete :order
      options.merge! :total => total || count(query), page_param => page, :page_param => page_param
      collection.pager = DataMapper::Pager.new options
      
      collection
    end

  end
end
