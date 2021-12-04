require 'benchmark'

class View
  def self.display_section_header(title)
    puts
    puts ">>>>>>>>>> #{title} <<<<<<<<<<"
    puts
  end

  def self.test_passed
    puts '✅ TEST PASSED! 🥳'
  end

  def self.test_failed(actual, expected)
    puts '❌ TEST FAILED!'
    puts
    puts "Expected: #{expected}"
    puts "Got:      #{actual}"
  end

  def self.display_result(result)
    puts
    print "Result: "
    puts " - #{(Benchmark.measure { print result.inspect }.real * 1000).round(3)}ms"
    puts
  end

  def self.copy_to_clipboard(str)
    IO.popen('pbcopy', 'w') { |f| f << str }
  end
end