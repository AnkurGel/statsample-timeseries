# bio-statsample-timeseries

[![Build Status](https://secure.travis-ci.org/AnkurGel/bioruby-statsample-timeseries.png)](http://travis-ci.org/ankurgel/bioruby-statsample-timeseries)

Statsample-Timeseries is an extension to [Statsample](https://github.com/clbustos/statsample), a suite of advance statistics in Ruby. It incorporates helpful timeseries functions, estimations and modules such as:

  * ACF
  * PACF
  * ARIMA
  * KalmanFilter
  * LogLikelihood
  * Autocovariances
  * Moving Averages

Note: this software is under active development!


## Dependency

Please install [`rb-gsl`](http://rb-gsl.rubyforge.org/) which is a Ruby wrapper over GNU Scientific Library. It enables us to use various minimization techniques during estimations.

## Installation

```sh
    gem install bio-statsample-timeseries
```

## Usage

```ruby
    require 'bio-statsample-timeseries'
```

The [API doc](http://rubydoc.info/gems/bio-statsample-timeseries/0.2.0/frames) is online. For more code examples see the test files in
the source tree.


## Contributing

* Fork the project. 
* Add/Modify code. 
* Write equivalent documentation and **tests**
* Run `rake test` to verify that all test case passes
* Pull request. :)

 
## Project home page

Information on the source tree, documentation, examples, issues and
how to contribute, see

  http://github.com/ankurgel/bioruby-statsample-timeseries

The BioRuby community is on IRC server: irc.freenode.org, channel: #bioruby.

## Cite

If you use this software, please cite one of
  
* [BioRuby: bioinformatics software for the Ruby programming language](http://dx.doi.org/10.1093/bioinformatics/btq475)
* [Biogem: an effective tool-based approach for scaling up open source software development in bioinformatics](http://dx.doi.org/10.1093/bioinformatics/bts080)

## Biogems.info

This Biogem is published at [#bio-statsample-timeseries](http://biogems.info/index.html)

## Copyright

Copyright (c) 2013 Ankur Goel. See LICENSE.txt for further details.

