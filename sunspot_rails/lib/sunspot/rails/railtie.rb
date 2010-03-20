module Sunspot
  module Rails
    class Railtie < ::Rails::Railtie
      railtie_name :sunspot_rails

      initializer 'sunspot_rails.session' do |app|
        Sunspot.session = Sunspot::Rails.build_session
      end

      initializer 'sunspot_rails.active_record' do |app|
        if defined? ::ActiveRecord
          require File.join(File.dirname(__FILE__), 'adapters')
          Sunspot::Adapters::InstanceAdapter.register(Sunspot::Rails::Adapters::ActiveRecordInstanceAdapter, ActiveRecord::Base)
          Sunspot::Adapters::DataAccessor.register(Sunspot::Rails::Adapters::ActiveRecordDataAccessor, ActiveRecord::Base)

          require File.join(File.dirname(__FILE__), 'searchable')
          Sunspot::Rails::Searchable.enable!
        end
      end

      initializer 'sunspot_rails.action_controller' do |app|
        if defined? ::ActionController
          require File.join(File.dirname(__FILE__), 'request_lifecycle')
          Sunspot::Rails::RequestLifecycle.enable!
        end
      end

    end
  end
end
