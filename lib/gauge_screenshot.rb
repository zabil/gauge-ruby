# Copyright 2018 ThoughtWorks, Inc.

# This file is part of Gauge-Ruby.

# Gauge-Ruby is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# Gauge-Ruby is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with Gauge-Ruby.  If not, see <http://www.gnu.org/licenses/>.
require_relative './util'
module Gauge
  class << self
    def capture
      GaugeScreenshot.instance.capture
    end
  end

  class GaugeScreenshot
    def initialize
      @screenshots = []
    end

    def self.instance
      @gauge_screenshots ||= GaugeScreenshot.new
    end      

    def capture
      @screenshots.push(capture_to_file)
    end

    def capture_to_file
      unless Configuration.instance.screenshot_writer?
        content = Configuration.instance.screengrabber.call
        file_name = Util.unique_screenshot_file
        File.write(file_name, content)
        return File.basename(file_name)
      end
      Configuration.instance.screengrabber.call
    end

    def pending_screenshot
      pending_screenshot = @screenshots
      clear
      pending_screenshot
    end

    def get
      @screenshots
    end

    def clear
      @screenshots = []
    end

  end
end