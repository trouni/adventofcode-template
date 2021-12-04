require_relative 'input_fetcher'
require_relative 'view'

class AdventDay
  FIRST_PART_TEST_VALUE = nil
  SECOND_PART_TEST_VALUE = nil
  SKIP_FIRST_PART = false

  def self.solve
    parts = self::SKIP_FIRST_PART ? [:second_part] : %i[first_part second_part]
    parts.each do |part|
      View.display_section_header(part.to_s.upcase.gsub('_', ' '))
      break unless check_test_data(part)

      result = new.send(part, new.data)
      View.display_result(result)
      View.copy_to_clipboard(result)
    end
  end

  def first_part(input); end
  def second_part(input); end

  def convert_data(data)
    data.split("\n")
  end

  def data(test: false)
    return @input if defined?(@input)
    # Using hook methods instead of calling InputFetcher directly
    input_data = test ? debug_input : source_input
    @input ||= convert_data(input_data)
  end

  def self.check_test_data(part)
    expected = const_get "#{part.upcase}_TEST_VALUE"
    test_data = self.new.data(test: true)

    if expected && test_data.any?
      actual = new.send(part, test_data)
      test_passed = actual == expected
      test_passed ? View.test_passed : View.test_failed(actual, expected)
      return test_passed
    else
      puts "No test data available in inputs/#{new.day_number}_test" if test_data.empty?
      puts "Test values missing" unless expected
      return true
    end
  end

  # HOOK for subclass override
  def source_input
    InputFetcher.new(day_number, debug: false).get
  end

  # HOOK for subclass override
  def debug_input
    InputFetcher.new(day_number, debug: true).get
  end

  def day_number
    @day_number ||= self.class.name.gsub('Day', '')
  end
end
