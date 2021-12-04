require 'benchmark'

require_relative 'input_fetcher'

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

      result = new.send(part, new.data)
      puts
      print "Result: "
      puts " - #{(Benchmark.measure { print result.inspect }.real * 1000).round(3)}ms"
      puts
      # Copy result to clipboard
      IO.popen('pbcopy', 'w') { |f| f << result }
    end
  end

  def self.run_test(part)
    expected = const_get "#{part.upcase}_TEST_VALUE"
    if expected && test_data.any?
      actual = new.send(part, test_data)
      puts
      if actual == expected
        puts '✅ TEST PASSED! 🥳'
      else
        puts '❌ TEST FAILED!'
        puts
        puts "Expected: #{expected}"
        puts "Got:      #{actual}"
      end
      return actual == expected
    else
      puts "No test data available in inputs/#{new.day_number}_test" if test_data.empty?
      puts "Test values missing" unless expected
    end
  end

  def first_part(input); end
  def second_part(input); end

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
