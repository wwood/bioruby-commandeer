# bio-commandeer

[![Build Status](https://secure.travis-ci.org/wwood/bioruby-commandeer.png)](http://travis-ci.org/wwood/bioruby-commandeer)

`Bio::Commandeer` provides a dead simple method of running shell commands from within Ruby:

```ruby
require 'bio-commandeer'
Bio::Commandeer.run 'echo 5' #=> "5\n"
```
The real advantage of bio-commandeer is that when something goes wrong, it tells you; you don't have go looking for the error. Take for instance this simple script:
```ruby
#!/usr/bin/env ruby
require 'bio-commandeer'
print Bio::Commandeer.run('echo 5')
print Bio::Commandeer.run('cat /not_a_file')
```
The output is:
```sh
5
<snip>/lib/bio-commandeer/commandeer.rb:32:in `run': Command returned non-zero exit status (1), likely indicating failure. Command run was cat /not_a_file and the STDERR was: (Bio::CommandFailedException)
cat: /not_a_file: No such file or directory
	from spec/eg.rb:4:in `<main>'
```
When a command fails (detected through a non-zero exit status), then a `Bio::CommandFailedException` exception is thrown. While you can catch these exceptions with begin/rescue, often the best to do is fail, especially if you are writing quick one-off scripts.

Of course, when running commands such as this, make sure that

Note: this software is under active development!

## Installation

```sh
gem install bio-commandeer
```

## Usage

```ruby
require 'bio-commandeer'
```

The API doc is online. For more code examples see the test files in
the source tree.

## Project home page

Information on the source tree, documentation, examples, issues and
how to contribute, see

  http://github.com/wwood/bioruby-commandeer

The BioRuby community is on IRC server: irc.freenode.org, channel: #bioruby.

## Cite

If you use this software, please cite one of

* [BioRuby: bioinformatics software for the Ruby programming language](http://dx.doi.org/10.1093/bioinformatics/btq475)
* [Biogem: an effective tool-based approach for scaling up open source software development in bioinformatics](http://dx.doi.org/10.1093/bioinformatics/bts080)

## Biogems.info

This Biogem is published at (http://biogems.info/index.html#bio-commandeer)

## Copyright

Copyright (c) 2014 Ben J. Woodcroft. See LICENSE.txt for further details.

