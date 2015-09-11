crossrefrb
=========

[![Build Status](https://api.travis-ci.org/sckott/crossrefrb.png)](https://travis-ci.org/sckott/crossrefrb)
[![codecov.io](http://codecov.io/github/sckott/crossrefrb/coverage.svg?branch=master)](http://codecov.io/github/sckott/crossrefrb?branch=master)

`crossrefrb` is a low level client for Crossref APIs

Docs: http://recology.info/crossrefrb/

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
gem install crossrefrb
```

### Development version

```
git clone git@github.com:sckott/crossrefrb.git
cd crossrefrb
rake install
```

## Examples

Search works by DOI

```ruby
require 'crossrefrb'
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
