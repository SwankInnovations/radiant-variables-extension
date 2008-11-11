require File.dirname(__FILE__) + '/../spec_helper'

module Variables
  describe Evaluator do

    scenario :home_page, :snippets

    before :each do
      create_page "Parent Page" do
        create_page "Child Page"
      end
      @parent_page = pages(:parent_page)
      @child_page = pages(:child_page)
    end

    it "should require an index" do
      @parent_page.should render('<r:evaluate value_for="vars"/>').
          with_error("vars element requires an index")
    end




    describe "where the variable named is not set" do

      it "should return nil" do
        @parent_page.should render('<r:evaluate value_for="vars[bogus]"/>').
          and_evaluate_as(nil)
      end


      it "should return nil even if other variables are set" do
        @parent_page.should render('<r:set_vars notBogus="a value"/><r:evaluate value_for="vars[bogus]"/>').
          and_evaluate_as(nil)
      end

    end




    describe "where the variable named is set" do

      it "should return the value set (boolean true value)" do
        @parent_page.should render('<r:set_vars myValue="true"/><r:evaluate value_for="vars[myValue]"/>').
          and_evaluate_as(true)
      end


      it "should return the value set (boolean false value)" do
        @parent_page.should render('<r:set_vars myValue="false"/><r:evaluate value_for="vars[myValue]"/>').
          and_evaluate_as(false)
      end


      it "should return the value set (nil value)" do
        @parent_page.should render('<r:set_vars myValue="nil"/><r:evaluate value_for="vars[myValue]"/>').
          and_evaluate_as(nil)
      end


      it "should return the value set (null value)" do
        @parent_page.should render('<r:set_vars myValue="null"/><r:evaluate value_for="vars[myValue]"/>').
          and_evaluate_as(nil)
      end


      it "should return the value set (nothing value)" do
        @parent_page.should render('<r:set_vars myValue="nothing"/><r:evaluate value_for="vars[myValue]"/>').
          and_evaluate_as(nil)
      end


      it "should return the value set (numeric value)" do
        @parent_page.should render('<r:set_vars myValue="-10.2"/><r:evaluate value_for="vars[myValue]"/>').
          and_evaluate_as(-10.2)
      end


      it "should return the value set (string value)" do
        @parent_page.should render('<r:set_vars myValue="my string"/><r:evaluate value_for="vars[myValue]"/>').
          and_evaluate_as("my string")
      end


      it "should return the value set (string value wrapped in single quotes)" do
        @parent_page.should render(%{<r:set_vars myValue="'my string'"/><r:evaluate value_for="vars[myValue]"/>}).
          and_evaluate_as("my string")
      end


      it "should return the value set (string value wrapped in single quotes)" do
        @parent_page.should render(%{<r:set_vars myValue=' "my string" '/><r:evaluate value_for="vars[myValue]"/>}).
          and_evaluate_as("my string")
      end


    end




    describe 'where the index is "*show all*' do
  
      it 'should render all of the current variables sorted by name' do
        create_snippet 'snippet 1', :content => '<r:snippet name="snippet 2" d="high" b="score" />'
        create_snippet 'snippet 2', :content => '<r:content part="other part" d="years" a="ago" />'
        create_page_part 'other part', :page_id => @parent_page.id, :content => '<r:content part="another part" c="7" a="4" />'
        create_page_part 'another part', :page_id => @parent_page.id, :content => '<r:puts value_for="vars[*show all*]" />'
        @parent_page.should render('<r:set_vars empty="nil" final="98.6" />' +
            '<r:snippet name="snippet 1" b="true" c="a string" d="nil" a="10" />').
            as("Current Variables:\n" +
               "  a = 4.0\n" +
               "  b = \"score\"\n" +
               "  c = 7.0\n" +
               "  d = \"years\"\n" +
               "  empty = nil\n" +
               "  final = 98.6\n"
            )
      end
      
      
      it 'should render "Current Variables: none" if no variables' do
        @parent_page.should render('<r:puts value_for="vars[*show all*]" />').
            as('Current Variables: none')
      end
  
    end
  end
end