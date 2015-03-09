require 'sshkit'
require 'sshkit/dsl'

SERVER = '192.241.228.42'

def deploy_project project, branch='master'
    SSHKit.config.default_env = {TEST_ENV: 'prod'}
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
                execute "rm -rf /home/#{project}/#{project}/public/"
                execute :git, :checkout, "#{branch}"
                execute :git, :reset, '--hard'
                execute :git, :pull, :origin, "#{branch}"
                execute :cp, "etc/nginx/#{project} /etc/nginx/sites-available/#{project}"
                execute :cp, "etc/cron.d/backup /etc/cron.d/backup"
                execute :service, :nginx, :restart
            end
            execute :bundle, :install
            execute :rake, 'assetpack:build'
            execute :thin, :restart
        end
    end
end

project, branch = ARGV
deploy_project project, branch
