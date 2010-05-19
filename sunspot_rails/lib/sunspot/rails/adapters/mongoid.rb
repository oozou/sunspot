module Sunspot #:nodoc:
  module Rails #:nodoc:
    # 
    # This module provides Sunspot Adapter implementations for Mongoid
    #
    module Adapters
      class MongoidInstanceAdapter < Sunspot::Adapters::InstanceAdapter
        # 
        # Return the primary key for the adapted instance
        #
        # ==== Returns
        # 
        # String:: ID of the documents
        #
        def id
          @instance.id
        end
      end

      class MongoidDataAccessor < Sunspot::Adapters::DataAccessor
        # 
        # Get one document from Mongo
        #
        # ==== Parameters
        #
        # id<String>:: ID of the document to retreive
        #
        # ==== Returns
        #
        # Mongoid::Document infused model
        # 
        def load(id)
          @clazz.criteria.id(id)
        end

        # 
        # Get a collection of documents out of mongo by id
        #
        # ==== Parameters
        #
        # ids<Array>:: IDs of documents to retrieve
        #
        # ==== Returns
        #
        # Array:: Collection of Mongoid::Document infused models
        #
        def load_all(ids)
          primary_key = @clazz.primary_key || '_id'
          @clazz.criteria.in(primary_key.to_sym => ids)
        end

        def iterate_all(opts={}, &block)
          current_page = 1
          per_page = opts[:batch_size] || 25
          loop do
            documents = @clazz.paginate(:page => current_page, :per_page => per_page)
            break if documents.empty?
            yield documents
            current_page += 1
          end
        end

      end
    end
  end
end

Mongoid::Document::ClassMethods.class_eval do
  include Sunspot::Rails::Searchable::ActsAsMethods
end

Sunspot::Adapters::InstanceAdapter.register(Sunspot::Rails::Adapters::MongoidInstanceAdapter, Mongoid::Document)
Sunspot::Adapters::DataAccessor.register(Sunspot::Rails::Adapters::MongoidDataAccessor, Mongoid::Document)
