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

module Vagrant
  module Openshift
    module Action
      class RunOriginMetricsTests
        include CommandHelper

        @@SSH_TIMEOUT = 4800

        def initialize(app, env, options)
          @app = app
          @env = env
          @options = options.clone
        end

        def run_tests(env, cmds, as_root=true)
          tests = ''
          cmds.each do |cmd|
            tests += "
echo '***************************************************'
echo 'Running #{cmd}...'
time #{cmd}
echo 'Finished #{cmd}'
echo '***************************************************'
"
          end
          cmd = %{
set -e
pushd #{Constants.build_dir}/origin-metrics/hack/tests >/dev/null
export PATH=$GOPATH/bin:$PATH
#{tests}
popd >/dev/null
        }
          exit_code = 0
          if as_root
            _,_,exit_code = sudo(env[:machine], cmd, {:timeout => 60*60*4, :fail_on_error => false, :verbose => false})
          else
            _,_,exit_code = do_execute(env[:machine], cmd, {:timeout => 60*60*4, :fail_on_error => false, :verbose => false})
          end
          exit_code
        end

        #
        # All env vars will be added to the beginning of the command like VAR=1 make test
        #
        def call(env)
          @options.delete :logs

          cmd_env = []

          if @options[:envs]
            cmd_env += @options[:envs]
          end

          if @options[:image_registry]
            cmd_env << "OPENSHIFT_TEST_IMAGE_REGISTRY=#{@options[:image_registry]}"
          end

          cmd_env << './ci_test_every_pr.sh'
          cmd = cmd_env.join(' ')
          env[:test_exit_code] = run_tests(env, [cmd], @options[:root])

          @app.call(env)
        end
      end
    end
  end
end
