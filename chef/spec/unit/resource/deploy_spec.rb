#
# Author:: Daniel DeLeo (<dan@kallistec.com>)
# Copyright:: Copyright (c) 2008 Opscode, Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "spec_helper"))

describe Chef::Resource::Deploy do
  
  class << self
    def resource_has_a_string_attribute(attr_name)
      it "has a String attribute for #{attr_name.to_s}" do
        @resource.send(attr_name, "this is a string")
        @resource.send(attr_name).should eql("this is a string")
        lambda {@resource.send(attr_name, 8675309)}.should raise_error(ArgumentError)
      end
    end
    
    def resource_has_a_boolean_attribute(attr_name, opts={:defaults_to=>false})
      it "has a Boolean attribute for #{attr_name.to_s}" do
        @resource.send(attr_name).should eql(opts[:defaults_to])
        @resource.send(attr_name, !opts[:defaults_to])
        @resource.send(attr_name).should eql( !opts[:defaults_to] )
      end
    end
  end
  
  before do
    @resource = Chef::Resource::Deploy.new("/my/deploy/dir")
  end
  
  resource_has_a_string_attribute(:repo)
  resource_has_a_string_attribute(:deploy_to)
  resource_has_a_string_attribute(:role)
  resource_has_a_string_attribute(:restart_command)
  resource_has_a_string_attribute(:migration_command)
  resource_has_a_string_attribute(:user)
  resource_has_a_string_attribute(:group)
  resource_has_a_string_attribute(:repository_cache)
  resource_has_a_string_attribute(:copy_exclude)
  resource_has_a_string_attribute(:revision)
  resource_has_a_string_attribute(:remote)
  resource_has_a_string_attribute(:git_ssh_wrapper)
  resource_has_a_string_attribute(:svn_username)
  resource_has_a_string_attribute(:svn_password)
  resource_has_a_string_attribute(:svn_arguments)
  
  resource_has_a_boolean_attribute(:migrate, :defaults_to=>false)
  resource_has_a_boolean_attribute(:enable_submodules, :defaults_to=>false)
  resource_has_a_boolean_attribute(:shallow_clone, :defaults_to=>false)
  resource_has_a_boolean_attribute(:force_deploy, :defaults_to=>false)
  
  it "uses the first argument as the deploy directory" do
    @resource.deploy_to.should eql("/my/deploy/dir")
  end
  
  # For git, any revision, branch, tag, whatever is resolved to a SHA1 ref.
  # For svn, the branch is included in the repo URL.
  # Therefore, revision and branch ARE NOT SEPARATE THINGS
  it "aliases #revision as #branch" do
    @resource.branch "stable"
    @resource.revision.should eql("stable")
  end
  
  it "takes the SCM resource to use as a constant, and defaults to git" do
    @resource.scm_provider.should eql(Chef::Provider::Git)
    @resource.scm_provider Chef::Provider::Subversion
    @resource.scm_provider.should eql(Chef::Provider::Subversion)
  end
  
  it "takes arbitrary environment variables in a hash" do
    @resource.environment "RAILS_ENV" => "production"
    @resource.environment.should == {"RAILS_ENV" => "production"}
  end
  
  it "takes string arguments to environment for backwards compat, setting RAILS_ENV, RACK_ENV, and MERB_ENV" do
    @resource.environment "production"
    @resource.environment.should == {"RAILS_ENV"=>"production", "RACK_ENV"=>"production","MERB_ENV"=>"production"}
  end
  
  it "sets destination to $deploy_to/shared/$repository_cache" do
    @resource.destination.should eql("/my/deploy/dir/shared/cached-copy/")
  end
  
  it "sets shared_path to $deploy_to/shared" do
    @resource.shared_path.should eql("/my/deploy/dir/shared")
  end
  
  it "sets current_path to $deploy_to/current" do
    @resource.current_path.should eql("/my/deploy/dir/current")
  end
  
  it "gets the current_path correct even if the shared_path is set (regression test)" do
    @resource.shared_path
    @resource.current_path.should eql("/my/deploy/dir/current")
  end
  
  it "gives #depth as 5 if shallow clone is true, nil otherwise" do
    @resource.depth.should be_nil
    @resource.shallow_clone true
    @resource.depth.should eql("5")
  end
  
  it "aliases repo as repository" do
    @resource.repository "git@github.com/opcode/cookbooks.git"
    @resource.repo.should eql("git@github.com/opcode/cookbooks.git")
  end
  
  it "aliases git_ssh_wrapper as ssh_wrapper" do
    @resource.ssh_wrapper "git_my_repo.sh"
    @resource.git_ssh_wrapper.should eql("git_my_repo.sh")
  end
  
  it "has an Array attribute purge_before_symlink, default: log, tmp/pids, public/system" do
    @resource.purge_before_symlink.should == %w{ log tmp/pids public/system }
    @resource.purge_before_symlink %w{foo bar baz}
    @resource.purge_before_symlink.should == %w{foo bar baz}
  end
  
  it "has an Array attribute create_dirs_before_symlink, default: tmp, public, config" do
    @resource.create_dirs_before_symlink.should == %w{tmp public config}
    @resource.create_dirs_before_symlink %w{foo bar baz}
    @resource.create_dirs_before_symlink.should == %w{foo bar baz}
  end
  
  it 'has a Hash attribute map_shared_files, default: ' +
    '{"system" => "public/system", "pids" => "tmp/pids", ' +
    '"log" => "log", "config/database.yml" => "config/database.yml"}' do
    default = { "system" => "public/system", "pids" => "tmp/pids", "log" => "log",
                "config/database.yml" => "config/database.yml"}
    @resource.map_shared_files.should == default
    @resource.map_shared_files "foo" => "bar/baz"
    @resource.map_shared_files.should == {"foo" => "bar/baz"}
  end
  
end
