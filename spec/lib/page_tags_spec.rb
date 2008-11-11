require File.dirname(__FILE__) + '/../spec_helper'

describe "Variables::PageTags" do

  scenario :home_page, :snippets

  before :each do
    @page = pages(:home)
  end


  describe "<r:set_vars> tag" do

    it 'should raise appropriate error if no attributes are given' do
      @page.should render('<r:set_vars />').with_error(%{`set_vars' tag must be given at least one attribute})
    end


    it "should render nothing if proper attribute(s) are given" do
      @page.should render(%{<r:set_vars myVar="some value"/>}).as("")
    end

  end




  [ { :input_text => "true", :result => true },
    { :input_text => " true ", :result => true },
    { :input_text => "True", :result => true },
    { :input_text => "TRUE", :result => true },
    { :input_text => "false", :result => false },
    { :input_text => " false ", :result => false },
    { :input_text => "False", :result => false },
    { :input_text => "FALSE", :result => false },
    { :input_text => "nil", :result => nil },
    { :input_text => "  nil  ", :result => nil },
    { :input_text => "NIL", :result => nil },
    { :input_text => "null", :result => nil },
    { :input_text => " null ", :result => nil },
    { :input_text => "NULL", :result => nil },
    { :input_text => "nothing", :result => nil },
    { :input_text => "  nothing  ", :result => nil },
    { :input_text => "NOTHING", :result => nil },
    { :input_text => "10", :result => 10.0 },
    { :input_text => "  10  ", :result => 10.0 },
    { :input_text => "0", :result => 0.0 },
    { :input_text => " 0 ", :result => 0.0 },
    { :input_text => "-10", :result => -10.0 },
    { :input_text => " -10 ", :result => -10.0 },
    { :input_text => "125.32", :result => 125.32 },
    { :input_text => "  125.32  ", :result => 125.32 },
    { :input_text => "0.000", :result => 0.0 },
    { :input_text => "  0.000  ", :result => 0.0 },
    { :input_text => "-125.32", :result => -125.32 },
    { :input_text => " -125.32 ", :result => -125.32 },
    { :input_text => "string", :result => "string" },
    { :input_text => "a string", :result => "a string" },
    { :input_text => "a longer 'string'", :result => "a longer 'string'" },
    { :input_text => "'string'", :result => "string" },
    { :input_text => " 'a string' ", :result => "a string" },
    { :input_text => " 'a longer ''string'''", :result => "a longer 'string'" },
    { :input_text => ' "string" ', :result => "string" },
    { :input_text => '"a string"', :result => "a string" },
    { :input_text => ' "a longer ""string""" ', :result => 'a longer "string"' },
  ].each do |curr_value|

    describe "<r:set_vars> tag" do

      it "should set the attribute name/value pair into a variable name/value pair" do
        tag = build_tag('set_vars', :myVar => curr_value[:input_text])
        @page.should render(tag + evaluate_var('myVar')).
            and_evaluate_as(curr_value[:result])
      end


      it "additional set_vars should overwrite any previously set values (for the same variable name only)" do
        initial_tag = '<r:set_vars myVar="Initial Value" otherVar="25" />'
        final_tag = build_tag('set_vars', :myVar => curr_value[:input_text])
        @page.should render(initial_tag + final_tag + evaluate_var('myVar')).
            and_evaluate_as(curr_value[:result])
      end


      it "additional set_vars should not overwrite any previously set values if the variable names are different" do
        initial_tag = '<r:set_vars myVar="Initial Value" otherVar="25" />'
        final_tag = build_tag('set_vars', :myVar => curr_value[:input_text])
        @page.should render(initial_tag + final_tag + evaluate_var('otherVar')).
            and_evaluate_as(25.0)
      end

    end




    describe "<r:snippets> tag" do

      it 'should set any attribute (other than "name") into a variable' do
        create_snippet 'a snippet', :content => evaluate_var('myVar')
        tag = build_tag('snippet', :name => 'a snippet', :myVar => curr_value[:input_text])
        @page.should render(tag).and_evaluate_as(curr_value[:result])
      end

    end




    describe '<r:content> tag' do

      it 'should set any attribute (other than "name") into a variable' do
        create_page_part 'other part', :page_id => @page.id, :content => evaluate_var('myVar')
        tag = build_tag('content', :part => 'other part', :myVar => curr_value[:input_text])
        @page.should render(tag).and_evaluate_as(curr_value[:result])
      end

    end
  end




  [ { :name => 'snippet', :attr => 'name'},
    { :name => 'content', :attr => 'part'}
  ].each do |tag|

    describe "contextual variables with preceding declarations (#{tag[:name]})" do

      before :each do
        create_snippet 'content', :content => evaluate_var('myVar')
        create_snippet 'forwarder', :content => '<r:snippet name="content" />'
        create_page_part 'content', :page_id => @page.id, :content => evaluate_var('myVar')
        create_page_part 'forwarder', :page_id => @page.id, :content => '<r:content part="content" />'
      end

      it "should override variables declared globally from outside with the same name" do
        @page.should render('<r:set_vars myVar="Initial Value" />' +
            %{<r:#{tag[:name]} #{tag[:attr]}="content" myVar="New Value" />}).
            and_evaluate_as('New Value')
      end


      it "should not override variables declared globally from outside if the names are different" do
        @page.should render('<r:set_vars myVar="Initial Value" otherVar="Other Value" />' +
            %{<r:#{tag[:name]} #{tag[:attr]}="content" otherVar="New Value" />}).
            and_evaluate_as('Initial Value')
      end


      it "should override variables declared contextually from outside with the same name" do
        @page.should render('<r:set_vars myVar="Initial Value" />' +
            %{<r:#{tag[:name]} #{tag[:attr]}="forwarder" myVar="New Value" />}).
            and_evaluate_as('New Value')
      end


      it "should not override variables declared contextually from outside if the names are different" do
        @page.should render('<r:set_vars myVar="Initial Value" otherVar="Other Value" />' +
            %{<r:#{tag[:name]} #{tag[:attr]}="forwarder" otherVar="New Value" />}).
            and_evaluate_as('Initial Value')
      end

    end

  end

end
