serrano
=========

[![Build Status](https://api.travis-ci.org/sckott/serrano.png)](https://travis-ci.org/sckott/serrano)
[![codecov.io](http://codecov.io/github/sckott/serrano/coverage.svg?branch=master)](http://codecov.io/github/sckott/serrano?branch=master)

`serrano` is a low level client for Crossref APIs

Docs: http://recology.info/serrano/

Other Crossref API clients:

- Python: [habanero](https://github.com/sckott/habanero)
- R: [rcrossref](https://github.com/ropensci/rcrossref)

## Changes

For changes see the [NEWS file](NEWS.md).

## API

Methods in relation to Crossref search API routes

* `/works` - `Serrano.works()`
* `/members` - `Serrano.members()`
* `/prefixes` - `Serrano.prefixes()`
* `/funders` - `Serrano.fundref()`
* `/journals` - `Serrano.journals()`
* `/licenses` - `Serrano.licenses()`
* `/types` - `Serrano.licenses()`

Additional methods:

* `/agency` - `Serrano.agency()`

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
Serrano.works(doi: '10.1371/journal.pone.0033693')
```

Search works by query string

```ruby
Serrano.works(query: "ecology")
```

Search journals by publisher name

```ruby
Serrano.journals(query: "peerj")
```

Search funding information by DOI

```ruby
Serrano.fundref(ids: ['10.13039/100000001','10.13039/100000015'])
```

Get agency for a set of DOIs

```ruby
Serrano.agency(ids: ['10.1007/12080.1874-1746','10.1007/10452.1573-5125'])
```

## Todo

* Export CLI interface
* More robust test suite
* More examples
* Suite of methods on output data

## Meta

Please note that this project is released with a [Contributor Code of Conduct](CONDUCT.md). By participating in this project you agree to abide by its terms.
