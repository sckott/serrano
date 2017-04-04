## 0.3.6 (2017-04-04)

* Updated dependency versions
* Now using `vcr` gem for caching HTTP requests for test suite (#38)
* Changed base URL for Crossref API for all requests to `https` (#37)
* Updated docs for `facet` parameter that it can be either a
boolean or a query string, e.g,. `license:*` to facet by license (#36)
* Documented in `offset` parameter the max of 10K instituted somewhat
recently (#34)
* Documented in top level `Serrano` module and in README the new
rate limit on all requests - which varies through time. (#32)

## 0.3.0 (2016-10-20)

* Field queries now supported in appropriate methods:
`Serrano.works`, `Serrano.members`, `Serrano.prefixes`, `Serrano.funders`,
`Serrano.journals`, and `Serrano.types` (#27)
* Caching bundler on Travis for faster build time (#28)
* `sample` parameter now has a max of 100, where it was
1000 previously (#30)
* Two new filters are available: `has-clinical-trial-number` and `has-abstract`.
Both are added to the filter helper functions and can be used in queries (#31)
* Updated (dev) dependency versions

## 0.2.2 (2016-06-07)

* Fixed bug in `content_negotation` in which a length 1 array of DOIs was
failing (#29)
* Added more tests to the test suite

## 0.2.0 (2016-03-07)

* Added error classes to fail more gracefully, adapted from instagram gem (#4)
* Added support for the cursor feature in the Crossref API for deep paging (#14)
* Added disclaimer to docs that full text/abstracts aren't searched (#24)
* Now passing user agent string with serrano version in each request (#25)

## 0.1.4 (2015-12-04)

* Added `csl_styles()` method to get CSL styles info (#23)
* note to docs that `sample` parameter is ignored unless `works` route used (#22)
* note to docs that `funderes` without IDs don't show up in the `funders` route (#21)
* Added hash and array method to extract links from output of any methods with works (#18)
* Method `Serrano.text` for text mining removed. use the `textminer` gem (#13)

## 0.1.0 (2015-11-17)

* Improved documentation
* `licenses()` loses `ids` param as it doesn't accept IDs
* `agency()` method changed to `registration_agency()`
* `cn()` method changed to `content_negotiation()`
* `random_dois()` gains default value of `sample = 10`
* New method `get_styles()` to get CSL styles

## 0.0.7 (2015-11-04)

* First version to Rubygems
