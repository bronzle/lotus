require 'rack'

module Lotus
  module Commands
    class Console
      ENGINES = {
        'pry'  => 'Pry',
        'ripl' => 'Ripl',
        'irb'  => 'IRB'
      }.freeze

      attr_reader :options

      def initialize(env)
        @options = env.to_options
      end

      def start
        # Clear out ARGV so Pry/IRB don't attempt to parse the rest
        ARGV.shift until ARGV.empty?
        require File.expand_path(options[:applications], Dir.pwd)

        engine.start
      end

      def engine
        load_engine options.fetch(:engine) { engine_lookup }
      end

      private
      def engine_lookup
        (ENGINES.find {|_, klass| Object.const_defined?(klass) } || default_engine).first
      end

      def default_engine
        ENGINES.to_a.last
      end

      def load_engine(engine)
        require engine
      rescue LoadError
      ensure
        return Object.const_get(
          ENGINES.fetch(engine) {
            raise ArgumentError.new("Unknown console engine: #{ engine }")
          }
        )
      end
    end
  end
end
