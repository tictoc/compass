require 'test_helper'
require 'fileutils'
require 'compass'
require 'compass/exec'
require 'timeout'
require 'mocha'

class ExtensionsTest < Test::Unit::TestCase
  include Compass::TestCaseHelper
  include Compass::CommandLineHelper
  include Compass::IoHelper
  
  def gem_data(options = {})
    {"created_at"=>"2011-10-30T20:39:00Z", "documentation"=>"http://rdoc.info/compass", "gem_version_cache"=>[{"built_at"=>"2011-08-30T07:00:00Z", "number"=>"0.12.alpha.0", "prerelease"=>true, "authors"=>"Chris Eppstein, Eric A. Meyer, Brandon Mathis, Nico Hagenburger, Scott Davis", "description"=>"Compass is a Sass-based Stylesheet Framework that streamlines the creation and maintainance of CSS.", "summary"=>"A Real Stylesheet Framework", "downloads_count"=>12796, "platform"=>"ruby"}], "gem_version_last_updated"=>"2011-10-30T20:38:37Z", "homepage"=>"http://compass-style.org", "id"=>1, "image"=>{"url"=>"/uploads/extension/image/1/extension_test.png"}, "mailing_list"=>"http://mail.google.com", "name"=>"compass 1", "ruby_gem"=>"compass", "ruby_gem_cache"=>{"name"=>"compass", "dependencies"=>{"runtime"=>[{"name"=>"chunky_png", "requirements"=>"~> 1.2"}, {"name"=>"fssm", "requirements"=>">= 0.2.7"}, {"name"=>"sass", "requirements"=>"~> 3.1"}], "development"=>[]}, "downloads"=>531138, "info"=>"Compass is a Sass-based Stylesheet Framework that streamlines the creation and maintainance of CSS.", "version"=>"0.11.5", "version_downloads"=>107049, "homepage_uri"=>"http://compass-style.org", "authors"=>"Chris Eppstein, Eric A. Meyer, Brandon Mathis, Nico Hagenburger, Scott Davis", "project_uri"=>"http://rubygems.org/gems/compass", "gem_uri"=>"http://rubygems.org/gems/compass-0.11.5.gem", "source_code_uri"=>"http://github.com/chriseppstein/compass", "bug_tracker_uri"=>"http://github.com/chriseppstein/compass/issues", "wiki_uri"=>"http://wiki.github.com/chriseppstein/compass/", "documentation_uri"=>"http://compass-style.org/docs/", "mailing_list_uri"=>"http://groups.google.com/group/compass-users"}, "ruby_gem_cache_last_updted"=>"2011-10-30T20:39:00Z", "source_code"=>"http://github.com/compass", "updated_at"=>"2011-10-30T20:39:00Z", "user_id"=>1}.merge(options) 
  end
  
  def json_data
    data = []
    10.times do |i|
      data << gem_data(:name => "Compass #{i}")
    end
    data.to_json
  end
  
  def within_sandbox
    within_tmp_directory do
      compass 'init'
      yield
    end
  end
  
  def setup
    Compass::Commands::Extensions::Base.stubs(:load_json_from_repo).returns(json_data)
  end
  
  
  it "should get gem json" do
    Compass::Commands::Extensions::Base.expects(:load_json_from_repo).once
    compass 'extension', 'list'   
  end
  
  it "should search for a gem" do
    compass 'extension', 'search', 'compass 2'
    assert @last_result.downcase.include?('compass 2')
    assert !@last_result.downcase.include?('compass 1')
  end
  
  it "should search for a few gems" do
    compass 'extension', 'search', 'compass'
    r = @last_result.scan %r{Compass ([0-9]+)}
    assert_equal r.flatten, %w(0 1 2 3 4 5 6 7 8 9)
  end
  
  it "should search for a non exsistant gem" do
    compass 'extension', 'search', 'foobar'
    assert @last_result.include? 'No Exensions found matching: foobar'
  end
  
  it "should list all the gems" do
    compass 'extension', 'list'
    r = @last_result.scan %r{Compass ([0-9]+)}
    assert_equal r.flatten, %w(0 1 2 3 4 5 6 7 8 9)
  end
  
  it "should install the gem and dependencies" do
    ::Gem::DependencyInstaller.any_instance.expects(:install).once.with("compass", "0.11.5").returns(true)
    within_sandbox do
      compass 'extension', 'install', 'compass 1'
    end
    assert @last_result.include? 'dependencies'
  end
  
  it "should install gem into Gemfil if it exists" do
    within_sandbox do
      FileUtils.touch('Gemfile')
      compass 'extension', 'install', 'compass 1'
      assert File.read('Gemfile').include? "gem 'compass'"
    end
  end

  
end