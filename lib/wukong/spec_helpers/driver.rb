module Wukong
  module SpecHelpers
    class Driver

      #
      # These are methods you call on this object within the spec DSL.
      #
      
      def given *events
        @givens.concat(events)
        self
      end

      def as_json
        @json = true
        self
      end

      def delimited delimiter
        @delimited = true
        @delimiter = delimiter
        self
      end

      def as_tsv
        delimited("\t")
        self
      end

      #
      # These are methods used for other spec code to interface with
      # this driver.
      #

      def initialize proc, &block
        @proc   = proc
        yield @proc if @proc && block_given?
        @givens = []
      end
      
      def run
        return false unless @proc
        @proc.setup
        @outputs = [].tap do |output_records|
          @givens.each do |given_record|
            @proc.process(serialize(given_record)) do |output_record|
              output_records << output_record
            end
          end
        end
        @proc.finalize do |output_record|
          @outputs << output_record
        end
        @proc.stop
        true
      end

      def outputs
        @outputs || []
      end

      private
      
      def serialize record
        case
        when @json      then MultiJson.dump(record)
        when @delimited then record.map(&:to_s).join(@delimiter)
        else record
        end
      end

    end
  end
end