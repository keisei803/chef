#
# Author:: Adam Jacob (<adam@chef.io>)
# Author:: Seth Chisamore (<schisamo@chef.io>)
# Author:: Tyler Cloke (<tyler@chef.io>)
# Copyright:: Copyright 2008-2016, Chef Software Inc.
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

require "chef/resource/file"
require "chef/provider/cookbook_file"
require "chef/mixin/securable"

class Chef
  class Resource
    class CookbookFile < Chef::Resource::File
      include Chef::Mixin::Securable

      resource_name :cookbook_file

      property :source, [ String, Array ], default: lazy { |r| ::File.basename(r.name) }
      property :cookbook, String

      default_action :create
    end
  end
end
