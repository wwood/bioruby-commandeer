require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'tempfile'

describe "BioCommandeer" do
  it "should return stdout" do
    expect(Bio::Commandeer.run("echo 1 3")).to eq "1 3\n"
  end

  it 'should raise when exit status the command fails' do
    expect{Bio::Commandeer.run("cat /definitelyNotAFile")}.to raise_error(Bio::CommandFailedException)
  end

  it 'should accept stdin' do
    expect(Bio::Commandeer.run('cat', :stdin => 'dog')).to eq "dog"
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

      expect(stderr).to eq " INFO bio-commandeer: Running command: echo 5\n"+
        " INFO bio-commandeer: Command finished with exitstatus 0\n"
      expect(stdout).to eq "5\n"
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
      expect(stderr).to eq " INFO anotherlog: Running command: echo 50\n"+
        " INFO anotherlog: Command finished with exitstatus 0\n"
      expect(stdout).to eq "50\n"
    end
  end

  it 'should run to finish' do
    obj = Bio::Commandeer.run_to_finish("cat /definitelyNotAFile")
    expect(obj.stdout).to eq ""
    expect(obj.status.exitstatus).to eq 1
    expect(obj.stderr).to eq "cat: /definitelyNotAFile: No such file or directory\n"
    expect(obj.command).to eq "cat /definitelyNotAFile"
  end

  it 'should raise if failed' do
    obj = Bio::Commandeer.run_to_finish("cat /definitelyNotAFile")
    expect{obj.raise_if_failed}.to raise_error(Bio::CommandFailedException)
  end

  it 'should respect timeout' do
    Bio::Commandeer.run "sleep 2"
    expect { Bio::Commandeer.run "sleep 1", :timeout => 1}.
      to raise_error(Bio::CommandFailedException)
  end
end
