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
      @parent_page.should render('<r:evaluate element="vars"/>').
          with_error("vars element requires an index")
    end




    describe "where the variable named is not set" do

      it "should return nil" do
        @parent_page.should render('<r:evaluate element="vars[bogus]"/>').
          and_evaluate_as(nil)
      end


      it "should return nil even if other variables are set" do
        @parent_page.should render('<r:set_vars notBogus="a value"/><r:evaluate element="vars[bogus]"/>').
          and_evaluate_as(nil)
      end

    end




    describe "where the variable named is set" do

      it "should return the value set (boolean true value)" do
        @parent_page.should render('<r:set_vars myValue="true"/><r:evaluate element="vars[myValue]"/>').
          and_evaluate_as(true)
      end


      it "should return the value set (boolean false value)" do
        @parent_page.should render('<r:set_vars myValue="false"/><r:evaluate element="vars[myValue]"/>').
          and_evaluate_as(false)
      end


      it "should return the value set (nil value)" do
        @parent_page.should render('<r:set_vars myValue="nil"/><r:evaluate element="vars[myValue]"/>').
          and_evaluate_as(nil)
      end


      it "should return the value set (null value)" do
        @parent_page.should render('<r:set_vars myValue="null"/><r:evaluate element="vars[myValue]"/>').
          and_evaluate_as(nil)
      end


      it "should return the value set (nothing value)" do
        @parent_page.should render('<r:set_vars myValue="nothing"/><r:evaluate element="vars[myValue]"/>').
          and_evaluate_as(nil)
      end


      it "should return the value set (numeric value)" do
        @parent_page.should render('<r:set_vars myValue="-10.2"/><r:evaluate element="vars[myValue]"/>').
          and_evaluate_as(-10.2)
      end


      it "should return the value set (string value)" do
        @parent_page.should render('<r:set_vars myValue="my string"/><r:evaluate element="vars[myValue]"/>').
          and_evaluate_as("my string")
      end


      it "should return the value set (string value wrapped in single quotes)" do
        @parent_page.should render(%{<r:set_vars myValue="'my string'"/><r:evaluate element="vars[myValue]"/>}).
          and_evaluate_as("my string")
      end


      it "should return the value set (string value wrapped in single quotes)" do
        @parent_page.should render(%{<r:set_vars myValue=' "my string" '/><r:evaluate element="vars[myValue]"/>}).
          and_evaluate_as("my string")
      end


    end

  end
end