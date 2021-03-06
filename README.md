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
When a command fails (as detected through a non-zero exit status), then a `Bio::CommandFailedException` exception is thrown. While you can catch these exceptions with begin/rescue, often the best to do is fail, especially if you are writing quick one-off scripts.

Of course, when running commands such as this, take care not to trust the input directly from the command line, and especially not from a website. When in doubt, use `inspect` around the arguments to make sure that you don't run into [little bobby tables](http://xkcd.com/327).

Note: this software is under active development! Currently it is perhaps overly opinionated and as such not overly flexible.

## Logging
Commands run are logged with level info, if requested:

```ruby
require 'bio-commandeer'
Bio::Log::CLI.logger("stderr"); Bio::Log::CLI.trace("info");
puts Bio::Commandeer.run 'echo 5', :log=>true
```
On stderr this gives

```
 INFO bio-commandeer: Running command: echo 5
 INFO bio-commandeer: Command finished with exitstatus 0
```
Or a logging can be given directly, so long as it has an `info` method:

```ruby
Bio::Commandeer.run 'echo 5', :log=>my_logger
```

A command can also be run to completion without raising an errors using `run_to_finish`:
```ruby
require 'bio-commandeer'
result = Bio::Commandeer.run_to_finish 'echo 5' #=> Bio::CommandResult
result.stdout #=> "5\n"
```


## Installation

```sh
gem install bio-commandeer
```

## Biogems.info

This Biogem is published at (http://biogems.info/index.html#bio-commandeer)

## Copyright

Copyright (c) 2014-2015 Ben J. Woodcroft. See LICENSE.txt for further details.

