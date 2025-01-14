class Setup
  TEMPLATE = <<~RUBY.freeze
    require_relative 'common'

    class Day%{number} < AdventDay
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
