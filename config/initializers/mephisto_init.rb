# this is for standard library loading and configuration.  All the hardcore monkey patching is in the mephisto plugin.
require 'tzinfo'
require 'action_controller/dispatcher'
require 'coderay'
require 'ruby_pants'
require 'xmlrpc_patch'
require 'base64'

ActiveRecord::Base.observers = [:article_observer, :comment_observer]

# temporarily moved to vendor/plugins/aaa/init.rb to make sure
# it's loaded before all other plugins
# Object::RAILS_PATH = Pathname.new(File.expand_path(RAILS_ROOT))

require 'mephisto'

class ActionController::Dispatcher
  def self.register_liquid_tags
    Mephisto.liquid_filters.each { |mod| Liquid::Template.register_filter mod }
    Mephisto.liquid_tags.each { |name, klass| Liquid::Template.register_tag name, klass }
  end
  
  def cleanup_application_with_plugins
    returning cleanup_application_without_plugins do
      self.class.register_liquid_tags
    end
  end
  
  alias_method_chain :cleanup_application, :plugins
end

ActionController::Dispatcher.register_liquid_tags

ActiveSupport::Inflector.inflections do |inflect|
  #inflect.plural /^(ox)$/i, '\1en'
  #inflect.singular /^(ox)en/i, '\1'
  #inflect.irregular 'person', 'people'
  inflect.uncountable %w( audio )
end

Engines::Plugin::Config.set_table_name 'mephisto_plugins'

# This code is very suspicious.  What it it trying to do?
ActiveSupport::Dependencies.autoloaded_constants.delete "Mephisto"
ActiveSupport::Dependencies.autoloaded_constants.delete "Mephisto::Plugin"
