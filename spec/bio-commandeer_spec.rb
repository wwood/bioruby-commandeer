require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'tempfile'

describe "BioCommandeer" do
  it "should return stdout" do
    Bio::Commandeer.run("echo 1 3").should == "1 3\n"
  end

  it 'should raise when exit status the command fails' do
    expect {Bio::Commandeer.run("cat /definitelyNotAFile")}.to raise_error
  end

  it 'should accept stdin' do
    Bio::Commandeer.run('cat', :stdin => 'dog').should == "dog"
  end

  it 'should do logging with bio-logger' do
    Tempfile.open('script') do |f|
      f.puts [
        "require 'bio-commandeer'",
        'Bio::Log::CLI.logger("stderr"); Bio::Log::CLI.trace("info")',
        "puts Bio::Commandeer.run 'echo 5', :log=>true"
      ].join("\n")
      f.close
      lib = File.join(File.dirname(__FILE__), '..', 'lib')

      status, stdout, stderr = systemu "RUBYLIB=$RUBYLIB:#{lib} ruby #{f.path}"

      stderr.should == " INFO bio-commandeer: Running command: echo 5\n"+
        " INFO bio-commandeer: Command finished with exitstatus 0\n"
      stdout.should == "5\n"
    end
  end

  it 'should do logging given a log object' do
    Tempfile.open('script') do |f|
      f.puts [
        "require 'bio-commandeer'",
        'Bio::Log::CLI.logger("stderr"); Bio::Log::CLI.trace("info")',
        'log = Bio::Log::LoggerPlus.new("anotherlog"); Bio::Log::CLI.configure("anotherlog")',
        "puts Bio::Commandeer.run 'echo 50', :log=>log"
      ].join("\n")
      f.close
      lib = File.join(File.dirname(__FILE__), '..', 'lib')

      status, stdout, stderr = systemu "RUBYLIB=$RUBYLIB:#{lib} ruby #{f.path}"

      # Note the source of the log
      stderr.should == " INFO anotherlog: Running command: echo 50\n"+
        " INFO anotherlog: Command finished with exitstatus 0\n"
      stdout.should == "50\n"
    end
  end
end
