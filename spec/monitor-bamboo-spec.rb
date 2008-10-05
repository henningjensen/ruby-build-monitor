require '../monitor-bamboo'

describe BambooMonitor do

  before(:each) do
    @monitor = BambooMonitor.new
    @config = {"hostname"=>"http://example.com/bamboo", "username"=>"henning", "password"=>"hello"}
  end
  
  it "should return all possible configuration properties" do
    @monitor.properties.should eql(["hostname", "username", "password"])
  end
  
  it "should authenticate with the supplied credentials" do
    xml = Hpricot("<response><auth>abc123</auth></response>")
    @monitor.should_receive(:fetch_xml).with("login.action?username=henning&password=hello").and_return(xml)
    @monitor.configure(@config)
    @monitor.authenticate
  end

  it "should raise exception when authentication fails" do
    xml=Hpricot("<errors><error>Invalid username or password.</error></errors>")
    @monitor.should_receive(:fetch_xml).with("login.action?username=henning&password=hello").and_return(xml)    
    @monitor.configure(@config)
    lambda {@monitor.authenticate}.should raise_error(/Authentication failure/)
  end
    
  it "should create array of build identifiers" do
    xml = "<response><build><name>Example project - Trunk</name><key>EXAMPLE-TRUNK</key></build></response>"
    @monitor.stub!(:fetch_xml).and_return(Hpricot(xml))
    @monitor.get_identifiers.should eql(["EXAMPLE-TRUNK|Example project - Trunk"])
  end
    
  it "should return build status for the supplied identifier" do
    xml = "<response><buildstate>Successful</buildstate><buildtestsummary>99 passed</buildtestsummary></response>"
    @monitor.stub!(:fetch_xml).and_return(Hpricot(xml))
    @monitor.configure(@config)
    @monitor.get_build_status("EXAMPLE-TRUNK").should eql(["EXAMPLE-TRUNK","Successful","99 passed","http://example.com/bamboo/browse/EXAMPLE-TRUNK/latest"])
  end
    
end
