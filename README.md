# Aquanaut

A web crawler that stays on a given domain and creates a graph representing the different pages, static assets and how they are interlinke.

## Installation

Add this line to your application's Gemfile:

    gem 'aquanaut'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install aquanaut

## Usage

Execute `aquanaut` and specify the domain on which it should be executed.

    $ aquanaut 'http://www.konrad-reiche.com'

The results are written into the directory `sitemap`.

## Contributing

1. Fork it ( http://github.com/<my-github-username>/aquanaut/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
. Create new Pull Request
