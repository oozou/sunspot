module Sunspot #:nodoc:
  module Rails #:nodoc:
    # 
    # This module adds an after callback to ActionDispatch that commits
    # the Sunspot session if any documents have been added, changed, or removed
    # in the course of the request.
    #
    module RequestLifecycle
      class <<self
        def enable! #:nodoc:
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
