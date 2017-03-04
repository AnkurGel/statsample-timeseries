# statsample-timeseries

[![Build Status](https://travis-ci.org/SciRuby/statsample-timeseries.png)](https://travis-ci.org/SciRuby/statsample-timeseries)

Statsample-Timeseries is an extension to [Statsample](https://github.com/sciruby/statsample), a suite for advanced statistics with Ruby.

## Description

Statsample-Timeseries is extension of Statsample, and incorporates helpful time series functions, estimation techniques, and modules, such as:

* ACF
* PACF
* ARIMA
* Kalman Filter
* Log Likelihood
* Autocovariances
* Moving Averages

Statsample-Timeseries is part of the [SciRuby project](http://sciruby.com).

## Dependency

Please install [rb-gsl]() which is a Ruby wrapper over GNU Scientific Library.
It enables us to use various minimization techniques during estimations.

## Installation

`gem install statsample-timeseries`

## Usage

To use the library:

`require 'statsample-timeseries'`

See [Ankur's blog posts](http://ankurgoel.com) for explanations and examples.

## Documentation

The API doc is [online](http://rubygems.org/gems/statsample-timeseries). For more code examples see also the test files in the source tree.

## Contributing

* Fork the project.
* Create your feature branch
* Add/Modify code.
* Write equivalent documentation and *tests*.
* Run `rake test` to verify that all tests pass.
* Push your branch.
* Pull request. :)

## Project home page

For information on the source tree, documentation, issues and how to contribute, see [http://github.com/SciRuby/statsample-timeseries](git@github.com:SciRuby/statsample-timeseries.git).

## Copyright

Copyright (c) 2013 Ankur Goel and the Ruby Science Foundation. See LICENSE.txt for further details.

Statsample is (c) 2009-2013 Claudio Bustos and the Ruby Science Foundation.
