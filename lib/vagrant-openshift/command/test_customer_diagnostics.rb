#--
# Copyright 2016 Red Hat, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#++
require_relative "../action"

module Vagrant
  module Openshift
    module Commands
      class TestCustomerDiagnostics < Vagrant.plugin(2, :command)
        include CommandHelper

        def self.synopsis
          "run the customer diagnostics tests"
        end

        def execute
          options = {}
          options[:download] = false
          options[:target] = 'test-integration'

          opts = OptionParser.new do |o|
            o.banner = "Usage: vagrant test-customer-diagnostics [machine-name]"
            o.separator ""

            o.on("", "--root", String, "Run tests as root") do |f|
              options[:root] = true
            end

            o.on("-d","--artifacts", String, "Download logs") do |f|
              options[:download] = true
            end

            o.on("", "--env ENV=VALUE", String, "Environment variable to execute tests with") do |f|
              options[:envs] = [] unless options[:envs]
              options[:envs] << f
            end

            o.on("-t", "--target MAKEFILE_TARGETS", String, "Arguments to pass to the repository Makefile") do |f|
              options[:target] = f
            end

          end

          # Parse the options
          argv = parse_options(opts)
          return if !argv

          with_target_vms(argv, :reverse => true) do |machine|
            actions = Vagrant::Openshift::Action.run_customer_diagnostics_tests(options)
            @env.action_runner.run actions, {:machine => machine}
            0
          end
        end
      end
    end
  end
end
