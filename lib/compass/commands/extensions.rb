require 'compass/commands/project_base'
require 'compass/compiler'

require 'compass/commands/extensions/base'

module Compass
  module Commands
    module ExtensionProjectOptionsParser
      def set_options(opts)
        opts.banner = %Q{
          Usage: compass clean [path/to/project] [options]

          Description:
          Remove generated files and the sass cache.

          Options:
        }.split("\n").map{|l| l.gsub(/^ */,'')}.join("\n")
                
        super
      end
    end

    class ExtensionProject < UpdateProject

      register :extension
      register :e
      
      SEARCH = ['search', 's']
      INSTALL = ['install', 'i']
      INFO = ['info', 'in']
      LIST = ['list', 'l']
      REMOVE = ['remove', 'r']

      def initialize(working_path, options)
        super
        assert_project_directory_exists!
      end

      def perform
        
      end


      class << self
        def option_parser(arguments)
          parser = Compass::Exec::CommandOptionParser.new(arguments)
          parser.extend(Compass::Exec::GlobalOptionsParser)
          parser.extend(Compass::Exec::ProjectOptionsParser)
          parser.extend(ExtensionProjectOptionsParser)
        end

        def usage
          option_parser([]).to_s
        end

        def primary; true; end

        def description(command)
          "Remove generated files and the sass cache"
        end

        def parse!(arguments)
          parser = option_parser(arguments)
          parser.parse!
          parse_arguments!(parser, arguments)
          parser.options
        end

        def parse_arguments!(parser, arguments)
          case arguments.shift 
            when *SEARCH
              Extensions::Base.search(arguments.shift)
            when *INSTALL
              Extensions::Base.install(arguments.shift)
            when *REMOVE
              puts 'remove'
              puts arguments.shift
            when *LIST
              Extensions::Base.list
            when *INFO
              puts 'info'
              puts arguments.shift
            else
              raise 'go away'
          end
  
        end
      end
    end
  end
end