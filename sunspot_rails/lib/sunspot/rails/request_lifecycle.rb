module Sunspot #:nodoc:
  module Rails #:nodoc:
    # 
    # This module adds an after callback that commit
    # the Sunspot session if any documents have been added, changed, or removed
    # in the course of the request.
    #
    module RequestLifecycle
      class <<self
         def included(base) #:nodoc:
           if(defined?(::Rails.env))
             hook_for_rails3
           else
             hook_for_rails2(base)
           end
        end

        def hook_for_rails2(base)
           loaded_controllers =
             [base].concat(base.subclasses.map { |subclass| subclass.constantize })
           puts "loaded_controllers -> #{loaded_controllers.inspect}"
           # Depending on how Sunspot::Rails is loaded, there may already be
           # controllers loaded into memory that subclass this controller. In
           # this case, since after_filter uses the inheritable_attribute
           # structure, the already-loaded subclasses don't get the filters. So,
           # the below ensures that all loaded controllers have the filter.
           loaded_controllers.each do |controller|
             controller.after_filter do
               if Sunspot::Rails.configuration.auto_commit_after_request?
                 Sunspot.commit_if_dirty
               elsif Sunspot::Rails.configuration.auto_commit_after_delete_request?
                 Sunspot.commit_if_delete_dirty
               end
            end
          end
        end

        def hook_for_rails3
          ActionDispatch::Callbacks.after do
            if Sunspot::Rails.configuration.auto_commit_after_request?
              Sunspot.commit_if_dirty
            elsif Sunspot::Rails.configuration.auto_commit_after_delete_request?
              Sunspot.commit_if_delete_dirty
            end
          end
        end

      end
    end
  end
end
