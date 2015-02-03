require 'sshkit'
require 'sshkit/dsl'

SERVER = '192.241.228.42'

def deploy_project project
    SSHKit::Backend::Netssh.configure do |ssh|
        ssh.ssh_options = {
            user: project,
            keys: %w{'/Users/rob/.ssh/id_rsa.pub'},
            auth_methods: ['publickey']
        }
    end

    on SERVER do
        within "~/#{project}" do
            as 'root' do 
                execute :git, :reset, '--hard'
                execute :git, :pull
                execute :service, :nginx, :restart
            end
            execute :thin, :restart
        end
    end
end

project = ARGV.first
deploy_project project
