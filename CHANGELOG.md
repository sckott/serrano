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
