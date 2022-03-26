serrano
=========

[![gem version](https://img.shields.io/gem/v/serrano.svg)](https://rubygems.org/gems/serrano)
[![Ruby](https://github.com/sckott/serrano/workflows/Ruby/badge.svg)](https://github.com/sckott/serrano/actions)
[![codecov.io](https://codecov.io/github/sckott/serrano/coverage.svg?branch=main)](https://codecov.io/github/sckott/serrano?branch=main)
[![DOI](https://zenodo.org/badge/2600/sckott/serrano.svg)](https://zenodo.org/badge/latestdoi/2600/sckott/serrano)
[![Ruby Style Guide](https://img.shields.io/badge/code_style-standard-brightgreen.svg)](https://github.com/testdouble/standard)

`serrano` is a low level client for Crossref APIs

Docs: https://www.rubydoc.info/gems/serrano

Other Crossref API clients:

- Python: [habanero](https://github.com/sckott/habanero)
- R: [rcrossref](https://github.com/ropensci/rcrossref)

Crossref's API issue tracker: https://gitlab.com/crossref/issues

## Changes

For changes see the [Changelog][changelog]

## API

Methods in relation to [Crossref search API][crapi] routes

* `/works` - `Serrano.works()`
* `/members` - `Serrano.members()`
* `/prefixes` - `Serrano.prefixes()`
* `/funders` - `Serrano.funders()`
* `/journals` - `Serrano.journals()`
* `/licenses` - `Serrano.licenses()`
* `/types` - `Serrano.types()`

Additional methods built on top of the Crossref search API:

* DOI minting agency - `Serrano.registration_agency()`
* Get random DOIs - `Serrano.random_dois()`

Other methods:

* [Conent negotiation][cn] - `Serrano.content_negotiation()`
* [Citation count][ccount] - `Serrano.citation_count()`
* [get CSL styles][csl] -  `Serrano.csl_styles()`

Note about searching:

You are using the Crossref search API described at https://api.crossref.org When you search with query terms, on Crossref servers they are not searching full text, or even abstracts of articles, but only what is available in the data that is returned to you. That is, they search article titles, authors, etc. For some discussion on this, see https://gitlab.com/crossref/issues/issues/101

Rate limits:

Crossref introduced rate limiting recently. The rate limits apparently vary,
so we can't give a predictable rate limit. As of this writing, the rate
limit is 50 requests per second. Look for the headers `X-Rate-Limit-Limit`
and `X-Rate-Limit-Interval` in requests to see what the current rate
limits are.

The Polite Pool:

To get in the polite pool it's a good idea now to include a `mailto` email
address. See docs for more information. TLDR: set your email in an env var `CROSSREF_EMAIL`.


URL Encoding:

We do URL encoding of DOIs for you for all methods except `Serrano.citation_count` which doesn't work if you encode DOIs beforehand. We use `ERB::Util.url_encode` to encode.


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
  config.base_url = "https://api.crossref.org"
end
```

We recommend you set your `mailto` email here so you can get in the "polite pool" which gives you faster rate limits:

```ruby
Serrano.configuration do |config|
  config.mailto = "jane@doe.org"
end
```

Or use an env var with name `CROSSREF_EMAIL`

## Examples

### Use in a Ruby repl

Search works by DOI

```ruby
require 'serrano'
Serrano.works(ids: '10.1371/journal.pone.0033693')
```

Search works by query string

```ruby
Serrano.works(query: "ecology")
```

Search works using metadata filters. See [CrossRef filter docs](https://github.com/CrossRef/rest-api-doc#filter-names).

```ruby
Serrano.works(query: "ecology", filter: { has_abstract: true })
```

Search journals by publisher name

```ruby
Serrano.journals(query: "peerj")
```

Search funding information by DOI

```ruby
Serrano.funders(ids: ['10.13039/100000001','10.13039/100000015'])
```

Get agency for a set of DOIs

```ruby
Serrano.registration_agency(ids: ['10.1007/12080.1874-1746','10.1007/10452.1573-5125'])
```

Get random set of DOIs

```ruby
Serrano.random_dois(sample: 100)
```

Content negotiation

```ruby
Serrano.content_negotiation(ids: '10.1126/science.169.3946.635', format: "citeproc-json")
```

### Use on the CLI

The command line tool `serrano` should be available after you install

```
~$ serrano
Commands:
  serrano contneg                   # Content negotiation
  serrano funders [funder IDs]      # Search for funders by DOI prefix
  serrano help [COMMAND]            # Describe available commands or one spec...
  serrano journals [journal ISSNs]  # Search for journals by ISSNs
  serrano licenses                  # Search for licenses by name
  serrano members [member IDs]      # Get members by id
  serrano prefixes [DOI prefixes]   # Search for prefixes by DOI prefix
  serrano types [type name]         # Search for types by name
  serrano version                   # Get serrano version
  serrano works [DOIs]              # Get works by DOIs
```

```
# A single DOI
~$ serrano works 10.1371/journal.pone.0033693

# Many DOIs
~$ serrano works "10.1007/12080.1874-1746,10.1007/10452.1573-5125"
## if above two dois in a file called dois.txt 
~$ cat dois.txt | xargs -I{} serrano works {}

# output JSON, then parse with e.g., jq
~$ serrano works --filter=has_orcid:true --json --limit=2 | jq '.message.items[].author[].ORCID | select(. != null)'
```

## Meta

* Please note that this project is released with a [Contributor Code of Conduct](CONDUCT.md). By participating in this project you agree to abide by its terms.
* License: MIT

[crapi]: https://api.crossref.org/
[cn]: https://citation.crosscite.org/docs.html
[ccount]: https://www.crossref.org/documentation/retrieve-metadata/openurl/
[csl]: https://github.com/citation-style-language/styles
[changelog]: https://github.com/sckott/serrano/blob/main/CHANGELOG.md
