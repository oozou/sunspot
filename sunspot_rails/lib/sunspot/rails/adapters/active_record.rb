module Sunspot #:nodoc:
  module Rails #:nodoc:
    # 
    # This module provides Sunspot Adapter implementations for ActiveRecord
    # models.
    #
    module Adapters
      class ActiveRecordInstanceAdapter < Sunspot::Adapters::InstanceAdapter
        # 
        # Return the primary key for the adapted instance
        #
        # ==== Returns
        # 
        # Integer:: Database ID of model
        #
        def id
          @instance.id
        end
      end

      class ActiveRecordDataAccessor < Sunspot::Adapters::DataAccessor
        # options for the find
        attr_accessor :include, :select

        #
        # Set the fields to select from the database. This will be passed
        # to ActiveRecord.
        #
        # ==== Parameters
        #
        # value<Mixed>:: String of comma-separated columns or array of columns
        #
        def select=(value)
          value = value.join(', ') if value.respond_to?(:join)
          @select = value
        end

        # 
        # Get one ActiveRecord instance out of the database by ID
        #
        # ==== Parameters
        #
        # id<String>:: Database ID of model to retreive
        #
        # ==== Returns
        #
        # ActiveRecord::Base:: ActiveRecord model
        # 
        def load(id)
          @clazz.first(options_for_find.merge(
            :conditions => { @clazz.primary_key => id.to_i}
          ))
        end

        # 
        # Get a collection of ActiveRecord instances out of the database by ID
        #
        # ==== Parameters
        #
        # ids<Array>:: Database IDs of models to retrieve
        #
        # ==== Returns
        #
        # Array:: Collection of ActiveRecord models
        #
        def load_all(ids)
          @clazz.all(options_for_find.merge(
            :conditions => { @clazz.primary_key => ids.map { |id| id.to_i }}
          ))
        end

        def iterate_all(opts={}, &block)
          offset = 0
          batch_size = opts[:batch_size] || 25
          last_id = opts[:first_id] || 0
          loop do
            records = @clazz.all(:include => opts[:include], :conditions => ["#{@clazz.table_name}.#{@clazz.primary_key} > ?", last_id], :limit => batch_size, :order => @clazz.primary_key)
            break if records.empty?
            yield records
            last_id = records.last.id
            offset += batch_size
          end
        end

        private
        def options_for_find
          returning({}) do |options|
            options[:include] = @include unless @include.blank?
            options[:select]  =  @select unless  @select.blank?
          end
        end
      end
    end
  end
end

ActiveRecord::Base.send :include, Sunspot::Rails::Searchable
Sunspot::Adapters::InstanceAdapter.register(Sunspot::Rails::Adapters::ActiveRecordInstanceAdapter, ActiveRecord::Base)
Sunspot::Adapters::DataAccessor.register(Sunspot::Rails::Adapters::ActiveRecordDataAccessor, ActiveRecord::Base)