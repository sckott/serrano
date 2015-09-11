crossrefrb
=========

[![Build Status](https://api.travis-ci.org/sckott/crossrefrb.png)](https://travis-ci.org/sckott/crossrefrb)
[![codecov.io](http://codecov.io/github/sckott/crossrefrb/coverage.svg?branch=master)](http://codecov.io/github/sckott/crossrefrb?branch=master)

`crossrefrb` is a low level client for Crossref APIs

## Changes

For changes see the [NEWS file](https://github.com/sckott/crossrefrb/blob/master/NEWS.md).

## Install

### Release version

```
gem install crossrefrb
```

### Development version

```
git clone git@github.com:sckott/crossrefrb.git
cd crossrefrb
rake install
```

## Within Ruby

Search by DOI

```ruby
require 'crossrefrb'
Crossref.works(doi: '10.1371/journal.pone.0033693')
```

Search by query string

```ruby
Crossref.works(query: "ecology")
```

## Meta

Please note that this project is released with a [Contributor Code of Conduct](CONDUCT.md). By participating in this project you agree to abide by its terms.
