#!/usr/bin/env python2

from fabric.api import env, sudo, hosts, parallel

env.use_ssh_config = True
env.roledefs['webservers'] = [
    'geraldine', 'claire', 'clementine', 'marjorie', 'julia']


@hosts(env.roledefs['webservers'])
def password():
    sudo('echo "PASSWORD OK"')


@parallel
@hosts(env.roledefs['webservers'])
def sync():
    if env.host_string not in ('clementine',):
        sudo('layman -S')
    sudo('emerge --sync --quiet')


@hosts(env.roledefs['webservers'])
def update():
    sudo('emerge -DNautvq --keep-going --with-bdeps=y @world')
    sudo('dispatch-conf')
    sudo('revdep-rebuild -- -avq1')
