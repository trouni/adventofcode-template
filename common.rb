require 'bundler'
require 'dotenv/load'

Bundler.require

# require 'benchmark'
require 'net/http'

class AdventDay
  SESSION = ENV['SESSION']
  YEAR = ENV['YEAR']
  FIRST_PART_TEST_VALUE = nil
  SECOND_PART_TEST_VALUE = nil

  def self.solve
    %i[first_part second_part].each do |part|
      puts
      puts ">>>>>>>>>> #{part.to_s.upcase.gsub('_', ' ')} <<<<<<<<<<"
      puts
      break unless run_test(part)

      puts
      # puts " - #{(Benchmark.measure { print new.first_part.inspect  }.real * 1000).round(3)}ms"
      puts "Result - #{new.send(part)}"
      puts
    end
  end

  def self.run_test(part)
    if test_data.any?
      actual = new.send(part, test_data)
      expected = const_get "#{part.upcase}_TEST_VALUE"
      if actual == expected
        puts '✅ TEST PASSED! 🥳'
      else
        puts '❌ TEST FAILED!'
        puts "Expected: #{expected}"
        puts "Got:      #{actual}"
      end
      return actual == expected
    else
      puts "No test data available in inputs/#{new.day_number}_test" 
    end
  end

  def first_part(input = data); end
  def second_part(input = data); end

  def convert_data(data)
    data.split("\n")
  end

  def data(path = "inputs/#{day_number}")
    input_path = Pathname.new(path)
    input_data = if input_path.exist?
      File.read(input_path)
    else
      download_input
    end
    convert_data(input_data)
  end

  def self.test_data
    self.new.data("inputs/#{self.new.day_number}_test")
  end

  INPUT_BASE_URL = 'https://adventofcode.com'.freeze
  INPUT_PATH_SCHEME = '/%{year}/day/%{number}/input'.freeze

  def download_input
    raise "Cannot download input without a session cookie" unless SESSION
    res = Faraday.get(
      INPUT_BASE_URL + INPUT_PATH_SCHEME % { year: YEAR, number: day_number },
      nil,
      { 'Cookie' => "session=#{SESSION}" },
    )
    raise "Input doesn't appear to be accessible (yet?)" if res.status == 404
    test_path = "inputs/#{day_number}_test"
    `touch #{test_path}` unless Pathname.new(test_path).exist?
    File.write('inputs/'+day_number, res.body)
    res.body
  end

  def day_number
    @day_number ||= self.class.name.gsub('Day', '')
  end
end

module Patches
  module Every
    def every(n)
      self.lazy.with_index.select { |_e, i| i % n == 0 }.map { |e,i| e }.eager
    end
  end
  Array.include Every

  module Nth
    def nth(n)
      n.times do |count|
        val = self.next
        break val if count == n-1
      end
    end
  end
  Enumerator.include Nth

  module ConvenientAccess
    def first
      chars.first
    end

    def last
      chars.last
    end
  end
  String.include ConvenientAccess

  module Without
    def without(*keys)
      reject { |k,_| keys.include? k }.to_h
    end
  end
  Hash.include Without

  module DeepCopy
    def deep_copy
      Marshal.load(Marshal.dump(self))
    end
  end
  Object.include DeepCopy

  module Unwrap
    class NotUnwrappableError < StandardError; end

    def unwrap
      raise NotUnwrappableError unless self.length == 1
      self.first
    end
  end
  Set.include Unwrap
  Array.include Unwrap
end

class Setup
  TEMPLATE = <<~RUBY.freeze
    require_relative 'common'

    class Day%{number} < AdventDay
  FIRST_PART_TEST_VALUE = nil
  SECOND_PART_TEST_VALUE = nil

      def first_part
      end

      def second_part
      end

      private

      def convert_data(data)
        super
      end
    end

    Day%{number}.solve
  RUBY

  def self.run
    created_files = (1..25).map do |n|
      filename = "day-#{n.to_s.rjust(2, '0')}.rb"
      next if File.exists? filename
      File.write(filename, TEMPLATE % { number: n })
      filename
    end.compact
    if created_files.any?
      puts "Created the following files: \n#{created_files.map { |file| " - #{file}" }.join("\n")}"
    else
      puts "No file to create."
    end
  end
end

if $0 == __FILE__
  Setup.run
end
