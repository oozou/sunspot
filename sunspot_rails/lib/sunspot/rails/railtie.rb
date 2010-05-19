ActiveSupport.on_load(:action_controller) { include Sunspot::Rails::RequestLifecycle }

module Sunspot
  module Rails
    class Railtie < ::Rails::Railtie
      initializer 'sunspot_rails.session' do |app|
        Sunspot.session = Sunspot::Rails.build_session
      end
    end
  end
end
