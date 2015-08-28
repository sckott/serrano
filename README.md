textminer
=========

[![Build Status](https://api.travis-ci.org/sckott/textminer.png)](https://travis-ci.org/sckott/textminer)
[![codecov.io](http://codecov.io/github/sckott/textminer/coverage.svg?branch=master)](http://codecov.io/github/sckott/textminer?branch=master)

## What is it?

__`textminer` helps you text mine through Crossref's TDM (Text & Data Mining) services:__

## Changes

For changes see the [NEWS file](https://github.com/sckott/textminer/blob/master/NEWS.md).

## Install

### Release version

```
gem install textminer
```

### Development version

```
git clone git@github.com:sckott/textminer.git
cd textminer
rake install
```

## Within Ruby

Search by DOI

```ruby
require 'textminer'
out = textminer.links("10.5555/515151")
```

Get the pdf link

```ruby
out.pdf
```

```ruby
"http://annalsofpsychoceramics.labs.crossref.org/fulltext/10.5555/515151.pdf"
```

Get the xml link

```ruby
out.xml
```

```ruby
"http://annalsofpsychoceramics.labs.crossref.org/fulltext/10.5555/515151.xml"
```

Fetch XML

```ruby
Textminer.fetch("10.3897/phytokeys.42.7604", "xml")
```

```ruby
=> {"article"=>
  {"front"=>
    {"journal_meta"=>
      {"journal_id"=>
        {"__content__"=>"PhytoKeys", "journal_id_type"=>"publisher-id"},
       "journal_title_group"=>
        {"journal_title"=>{"__content__"=>"PhytoKeys", "lang"=>"en"},
         "abbrev_journal_title"=>{"__content__"=>"PhytoKeys", "lang"=>"en"}},
       "issn"=>
        [{"__content__"=>"1314-2011", "pub_type"=>"ppub"},
         {"__content__"=>"1314-2003", "pub_type"=>"epub"}],
       "publisher"=>{"publisher_name"=>"Pensoft Publishers"}},
     "article_meta"=>

...
```

Fetch PDF

```ruby
Textminer.fetch("10.3897/phytokeys.42.7604", "pdf")
```

> pdf written to disk

## On the CLI

Get links

```sh
tm links 10.3897/phytokeys.42.7604
```

```sh
http://phytokeys.pensoft.net/lib/ajax_srv/article_elements_srv.php?action=download_xml&item_id=4190
http://phytokeys.pensoft.net/lib/ajax_srv/article_elements_srv.php?action=download_pdf&item_id=4190
```

More than one DOI:

```sh
tm links '10.3897/phytokeys.42.7604,10.3897/zookeys.516.9439'
```

## To do

* CLI executable
* get actual full text
* better test suite
* documentation
