require 'generators/generic_people_rails/helpers'

module GenericPeopleRails
  module Generators
    class InstallGenerator < Rails::Generators::Base
      include GenericPeopleRails::Generators::Helpers

      source_root File.expand_path("../templates", __FILE__)

      desc "Mounts GenericPeopleRails into a rails app."
      
      def create_initializer
        template "initializer.rb", File.join('config','initializers','generic_people_rails.rb')
      end
      
      def mount_engine
        inject_into_file routes_path, :after => "Application.routes.draw do\n" do
          "  mount GenericPeopleRails::Engine => '/' \n"
        end
      end

    end
  end
end
