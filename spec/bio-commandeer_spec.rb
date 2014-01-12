require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "BioCommandeer" do
  it "should return stdout" do
    Bio::Commandeer.run("echo 1 3").should == "1 3\n"
  end

  it 'should raise when exit status the command fails' do
    expect {Bio::Commandeer.run("cat /definitelyNotAFile")}.to raise_error
  end
end
