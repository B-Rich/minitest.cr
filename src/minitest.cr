require "./minitest/reporter"
require "./minitest/runnable"
require "./minitest/test"

module Minitest
  class Result
    property :assertions, :failures

    def initialize
      @assertions = 0
      @failures = [] of Assertion | Skip | UnexpectedError
    end

    def passed?
      failures.empty?
    end

    def skipped?
      failures.any? { |f| f.is_a?(Skip) }
    end

    def result_code
      return "." if passed?
      return "S" if skipped?
      return "E" if failures.any? { |f| f.is_a?(UnexpectedError) }
      return "F"
    end

    def failure
      failures.first
    end
  end

  def self.run
    reporter = CompositeReporter.new
    reporter << SummaryReporter.new
    reporter << ProgressReporter.new
    reporter.start

    Runnable.runnables.shuffle.each(&.run(reporter))

    reporter.report
    reporter.passed?
  end
end
