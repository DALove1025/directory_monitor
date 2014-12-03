require "test_helper"

class Watch_TestCase < MiniTest::Unit::TestCase

  # Run the executable script and make sure we get an appropriate version
  # string written to the output.
  def test_watch_version
    assert(`ruby -Ilib bin/watch` =~ /version 0\.0\.1/, "Version not found")
  end

end

