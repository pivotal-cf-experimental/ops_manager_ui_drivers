module OpsManagerUiDrivers
  module Version18
    class JobStatusHelper
      def self.from_job_row(job_row)
        ips_string = job_row.find('.actual-ips').text
        ips        = ips_string.split(', ')
        az         = job_row.all('.az').first.try(:text)
        new(ips: ips, az: az)
      end

      def initialize(ips:, az:)
        @ips = ips
        @az = az
      end

      attr_reader :ips, :az
    end
  end
end
