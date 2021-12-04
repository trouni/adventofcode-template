require 'faraday'
require 'net/http'

class InputFetcher
  SESSION = ENV['SESSION']
  YEAR = ENV['YEAR']
  INPUT_FILE_PATH = "inputs/%{day}"
  TEST_FILE_PATH = "inputs/%{day}_test"

  attr_reader :day_number, :year
  def debug?; @debug; end

  def initialize(day_number, debug: false)
    @day_number = day_number
    @debug = debug
    generate_test_file unless Pathname.new(TEST_FILE_PATH % { day: day_number }).exist?
    download_input unless Pathname.new(INPUT_FILE_PATH % { day: day_number }).exist?
  end

  def get
    File.read(file_path) if file_path.exist?
  end

  def file_path
    Pathname.new(debug? ? TEST_FILE_PATH % { day: day_number } : INPUT_FILE_PATH % { day: day_number })
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
    
    File.write(INPUT_FILE_PATH % { day: day_number }, res.body)
    res.body
  end

  def generate_test_file
    test_path = "inputs/#{day_number}_test"
    `touch #{test_path}` unless Pathname.new(test_path).exist?
  end
end
