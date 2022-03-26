## 1.4 (2022-03-26)

* Moved to faraday > v2. There's no user facing changes here, but let me know if any issues arise (#172)
* PR by @LocoDelAssembly fixes `Serrano.content_negotiation(format: "citeproc-json")` by having it return `nil` instead of `Resource not found` when no DOI is found, so that the output is more compatible with flows that use serrano to create JSON (#169)
* PR by @xuanxu adds `REXML` as a runtime dependency (#159)

## 1.0.0 (2020-10-19)

* updated dependency versions

## 0.6.2 (2020-05-29)

* put documentation link back in rubygems page (#132)

## 0.6.0 (2020-02-18)

* query.title (`query_title` query filter as used here) has been removed; use `query_bibliographic` instead (#111)
* bump `faraday` to version 0.17.1 from 0.17.0 (via dependabot) (#107)
* bump `json` to version 2.3 from 2.2 (via dependabot) (#109)
* bump `thor` minimum version (via dependabot) (#110)
* better checking of filters; always check filters for proper formatting and acceptable types; improve filter tests; link to information on filters (#105) via PR from @beechnut

## 0.5.4 (2019-11-27)

* `Serrano.registration_agency` fixed: a change in an internal function caused this function to fail; tests added to prevent this in the future (#106)
* bundle update, changes in gemfile.lock

## 0.5.2 (2019-08-07)

* fix url encoding (#51)
* started using Rubocop; many styling changes (#52)

## 0.5.0 (2018-04-08)

* Updated dependency versions
* Change url used in content negotation from `http://dx.doi.org/` to `https://doi.org/` (#49)
* Fix `cursor_max` parameter type check to avoid Fixnum warning (#50)
* Add support for `mailto` email polite pool, and docs updated with info (#46) (#47)
* Add select parameter throughout methods (#43)
* Added additional filter options (#45) (#40)
* Added to docs info about additional `sort` parameter options (#41)
* Added to docs info about additional field query options (#42)

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
