serrano
=========

[![Build Status](https://api.travis-ci.org/sckott/serrano.png)](https://travis-ci.org/sckott/serrano)
[![codecov.io](http://codecov.io/github/sckott/serrano/coverage.svg?branch=master)](http://codecov.io/github/sckott/serrano?branch=master)

`serrano` is a low level client for Crossref APIs

Docs: http://recology.info/serrano/

## Changes

For changes see the [NEWS file](NEWS.md).

## API

Methods in relation to Crossref search API routes

* `/works` - `Crossref.works()`
* `/members` - `Crossref.members()`
* `/prefixes` - `Crossref.prefixes()`
* `/funders` - `Crossref.fundref()`
* `/journals` - `Crossref.journals()`
* `/licenses` - `Crossref.licenses()`

## Install

### Release version

```
gem install serrano
```

### Development version

```
git clone git@github.com:sckott/serrano.git
cd serrano
rake install
```

## Setup

Crossref's API will likely be used by others in the future, allowing the base URL to be swapped out. You can swap out the base URL by passing named options in a block to `Serrano.configuration`. 

This will also be the way to set up other user options, as needed down the road.

```ruby
Serrano.configuration do |config|
  config.base_url = "http://api.crossref.org"
end
```

## Examples

Search works by DOI

```ruby
require 'serrano'
Crossref.works(doi: '10.1371/journal.pone.0033693')
```

Search works by query string

```ruby
Crossref.works(query: "ecology")
```

Search journals by publisher name

```ruby
Crossref.journals(query: "peerj")
```

Search funding information by DOI

```ruby
Crossref.fundref(ids: ['10.13039/100000001','10.13039/100000015'])
```

## Todo

* Export CLI interface
* More robust test suite
* More examples
* Suite of methods on output data

## Meta

Please note that this project is released with a [Contributor Code of Conduct](CONDUCT.md). By participating in this project you agree to abide by its terms.
