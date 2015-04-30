module OpsManagerUiDrivers
  module Version14
    class JobStatusHelper
      def self.from_job_row(job_row)
        ips_string = job_row.find('.actual-ips').text
        ips = ips_string.split(', ')
        new(ips: ips)
      end

      def initialize(ips:)
        @ips = ips
      end

      attr_reader :ips
    end
  end
end
