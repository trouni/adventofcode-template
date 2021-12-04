require_relative 'common'

class Day13 < AdventDay
  FIRST_PART_TEST_VALUE = nil
  SECOND_PART_TEST_VALUE = nil
  # SKIP_FIRST_PART = true

  def first_part(input)
  end

  def second_part(input)
  end

  private

  def convert_data(data)
    super.map do |line|
      pp line
    end
  end

  # def test_input
  #   # Use this method to override the test data.
  #   # If you need to keep the leading spaces, you can replace the HEREDOC `<<~` with `<<-`.
  #   <<~DATA
  #     CUSTOM_TEST_DATA
  #   DATA
  # end
end

Day13.solve
