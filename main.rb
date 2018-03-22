# frozen_string_literal: true
require_relative 'downloader'



# The city name and country (as referenced by Wunderground)
CITY = OpenStruct.new(name: "San_Francisco", country: "US")

# The dates range for which you want data.
# The script will begin with most recent dates.
DATES_RANGE = (Date.new(1990, 1, 1)..Date.new(2017, 12, 31))

# Download options
OPTIONS = {
  gzip: true # whether or not gzip each json downloaded file.
}

# Edit theses lines if you have a different Wunderground plan.
# The script will stop when the daily limit is reached,
# or when 3 consecutive errors are received.
MAX_REQUESTS = 500
REQUESTS_MINUTE_RATE = 10



downloader = Downloader.new(CITY, DATES_RANGE, OPTIONS)
downloader.call
