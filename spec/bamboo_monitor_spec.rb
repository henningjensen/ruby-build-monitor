require 'bamboo_monitor'

describe BambooMonitor do

	before(:each) do
		@username = "johndoe"
		@password = "helloworld"
		@monitor = BambooMonitor.new("hostname"=>"http://example.com/bamboo", "username"=>@username, "password"=>@password, "project_key"=>"EXAMPLE-TRUNK")
	end

	it "should authenticate with the supplied credentials" do
    xml = Hpricot("<response><auth>abc123</auth></response>")
    @monitor.should_receive(:parse_xml).with("login.action?username="+@username+"&password="+@password).and_return(xml)
    @monitor.authenticate
  end

	it "should raise exception when authentication fails" do
    xml=Hpricot("<errors><error>Invalid username or password.</error></errors>")
    @monitor.should_receive(:parse_xml).with("login.action?username="+@username+"&password="+@password).and_return(xml)
    lambda {@monitor.authenticate}.should raise_error(/Authentication failure/)
  end

	it "should return successful build status" do
    auth_xml = "<response><auth>abc123</auth></response>"
    @monitor.should_receive(:parse_xml).with("login.action?username="+@username+"&password="+@password).and_return(Hpricot(auth_xml))
		build_xml = <<END
<response>
    <projectname>Struts 2 Portlet 2 Plugin</projectname>
    <buildname>Main Build</buildname>
    <buildkey>STRUTSPORTLET2-MAIN</buildkey>
    <buildstate>Successful</buildstate>
    <buildnumber>9</buildnumber>
    <failedtestcount>0</failedtestcount>
    <successfultestcount>55</successfultestcount>
    <buildtime>2008-12-17 14:03:50</buildtime>
    <builddurationinseconds>73</builddurationinseconds>
    <builddurationdescription>1 minute</builddurationdescription>
    <buildrelativebuilddate>2 months ago</buildrelativebuilddate>
    <buildtestsummary>55 passed</buildtestsummary>
    <buildreason>Code has changed</buildreason>
</response>
END
    @monitor.stub!(:parse_xml).and_return(Hpricot(build_xml))

    @monitor.get_build_status().is(Status::SUCCESS).should be_true 
  end
	
	it "should return failed build status" do
    auth_xml = "<response><auth>abc123</auth></response>"
    @monitor.should_receive(:parse_xml).with("login.action?username="+@username+"&password="+@password).and_return(Hpricot(auth_xml))
		build_xml = <<END
<response>
    <projectname>Struts 2 Portlet 2 Plugin</projectname>
    <buildname>Main Build</buildname>
    <buildkey>STRUTSPORTLET2-MAIN</buildkey>
    <buildstate>Failure</buildstate>
    <buildnumber>9</buildnumber>
    <failedtestcount>1</failedtestcount>
    <successfultestcount>54</successfultestcount>
    <buildtime>2008-12-17 14:03:50</buildtime>
    <builddurationinseconds>73</builddurationinseconds>
    <builddurationdescription>1 minute</builddurationdescription>
    <buildrelativebuilddate>2 months ago</buildrelativebuilddate>
    <buildtestsummary>54 passed</buildtestsummary>
    <buildreason>Code has changed</buildreason>
</response>
END
    @monitor.stub!(:parse_xml).and_return(Hpricot(build_xml))

    @monitor.get_build_status().is(Status::FAILURE).should be_true 
  end
	
	it "should return unknown build status" do
    auth_xml = "<response><auth>abc123</auth></response>"
    @monitor.should_receive(:parse_xml).with("login.action?username="+@username+"&password="+@password).and_return(Hpricot(auth_xml))
		build_xml = <<END
<response>
    <projectname>Struts 2 Portlet 2 Plugin</projectname>
    <buildname>Main Build</buildname>
    <buildkey>STRUTSPORTLET2-MAIN</buildkey>
    <buildstate>Error</buildstate>
    <buildnumber>9</buildnumber>
    <failedtestcount>1</failedtestcount>
    <successfultestcount>54</successfultestcount>
    <buildtime>2008-12-17 14:03:50</buildtime>
    <builddurationinseconds>73</builddurationinseconds>
    <builddurationdescription>1 minute</builddurationdescription>
    <buildrelativebuilddate>2 months ago</buildrelativebuilddate>
    <buildtestsummary>54 passed</buildtestsummary>
    <buildreason>Code has changed</buildreason>
</response>
END
    @monitor.stub!(:parse_xml).and_return(Hpricot(build_xml))

    @monitor.get_build_status().is(Status::UNKNOWN).should be_true 
  end


end
