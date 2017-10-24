# Weather history downloader

This ruby script will download weather history on [wunderground.com](https://www.wunderground.com/?apiref=8bb7c7c4dd649d33) for a given city, between dates of your choice.

## Configuration

You'll first need to get a [Wunderground API key](https://www.wunderground.com/weather/api/?apiref=8bb7c7c4dd649d33). The free developer plan permits 500 requests per day, at a max rate of 10 per minute.

Create a `.env` file as the root of directory and paste it your api key like this:

```env
WUNDERGROUND_API_KEY=you-api-key
```

Open the `main.rb` file, and configure these lines as you want :

```ruby
# The city name and country (as referenced by Wunderground)
CITY = OpenStruct.new(name: "San_Francisco", country: "US")

# The dates range for which you want data.
# The script will begin with most recent dates.
DATES_RANGE = (Date.new(1990, 1, 1)..Date.new(2016, 12, 31))

# Download options
OPTIONS = {
  gzip: false # whether or not gzip each json downloaded file.
}

# Edit theses lines if you have a different Wunderground plan.
MAX_REQUESTS = 500
REQUESTS_MINUTE_RATE = 10
```

# Usage

You must have ruby on your system.

```sh
bundle install
ruby ./main.rb
```

Raw json files are downloaded into `./data/name-of-the-city/` directory.  
1 request = 1 day of history = 1 json file.

The script will stop when the daily limit is reached, or when it received 3 consecutive errors.

Depending of the extend of the dates range, **you'll have to manually re-run the script several days** until you'll get all your data. But hopefully, you don't have to change the dates range each day: the script won't download two times the same day of history (just configure the script once).

This script was very quickly written and I don't expect to maintain it. Use it as it is or modify it as you want.

Only tested or MacOS High Sierra, ruby 2.4.1.

## License

This script is released under MIT license.
