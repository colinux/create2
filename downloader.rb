# frozen_string_literal: true

require 'rest-client'
require 'dotenv/load'

require 'ostruct'
require 'pathname'
require 'json'

class Downloader
  attr_reader :api_key
  attr_accessor :dates
  attr_reader :city
  attr_reader :directory
  attr_reader :options
  attr_accessor :requests_count
  attr_accessor :client_errors
  attr_accessor :server_errors

  BASE_URL = "http://api.wunderground.com/api"
  MAX_ERRORS = 3

  def initialize(city, date_range, options)
    @api_key = ENV.fetch("WUNDERGROUND_API_KEY")
    @dates = date_range.to_a
    @city = city
    @options = options

    city_dir = [city.country, city.name].join("_")
    @directory = Pathname.new("data").join(city_dir)

    @requests_count = 0
    @client_errors = 0
    @server_errors = 0
  end

  def call
    make_directory

    self.dates = dates - already_fetched_dates

    make_request(dates.pop)
  end

  def make_request(date)
    url = [
      BASE_URL,
      api_key,
      "history_#{format_date(date)}",
      "q",
      city.country,
      "#{city.name}.json"
    ].join("/")

    puts "Downloading #{url}"

    response = RestClient.get url

    json = JSON.parse(response.body)

    if json.fetch("response").has_key?("error")
      self.client_errors += 1
      next_or_stop(:error, date)
    else
      save_response(json, date)
      register_success
      next_or_stop(:success, date)
    end
  rescue
    self.server_errors += 1

    next_or_stop(:error, date)
  end

  def register_success
    self.requests_count += 1
    self.server_errors = 0
  end

  def next_or_stop(status, date)
    if requests_count >= MAX_REQUESTS || client_errors >= MAX_ERRORS || server_errors >= MAX_ERRORS
      puts "Stop after %d requests, %d client errors, %d server errors" % \
        [requests_count, client_errors, server_errors]
      return
    end

    new_date = if status == :success
      dates.pop
    else
      date
    end

    sleep (60 / REQUESTS_MINUTE_RATE.to_f) + 0.1

    make_request(new_date)
  end

  private

  def save_response(json_hash, date)
    filename = directory.join("#{format_date(date)}.json")

    json_hash.delete("response")
    json = JSON.pretty_generate(json_hash)

    if gzip?
      Zlib::GzipWriter.open("#{filename.to_s}.gz", Zlib::BEST_COMPRESSION) do |gz|
        gz.orig_name = filename.basename.to_s
        gz.write json
      end
    else
      filename.write(json)
    end
  end

  def make_directory
    directory.mkpath
  end

  def already_fetched_dates
    ext = ".json"

    Pathname.glob("#{directory.to_s}/" "*#{ext}*").map { |f|
      date_str = f.basename.to_s.gsub(ext, "")

      Date.strptime(date_str, date_format)
    }
  end

  def date_format
    "%Y%m%d"
  end

  def format_date(date)
    date.strftime(date_format)
  end

  def gzip?
    !! options.fetch(:gzip) { false }
  end
end
