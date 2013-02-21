#!/usr/bin/env python2

from fabric.api import env, sudo, hosts, parallel

env.use_ssh_config = True
env.hosts = [
    'geraldine', 'claire', 'clementine', 'marjorie', 'julia', 'sandra',
    'amandine']


def password():
    sudo('echo "PASSWORD OK"')


@parallel
def sync():
    if env.host_string not in ('clementine',):
        sudo('layman -S')
    sudo('emerge --sync --quiet')


def update():
    sudo('emerge -DNautvq --keep-going --with-bdeps=y @world')
    sudo('dispatch-conf')
    sudo('revdep-rebuild -- -avq1')
    sudo('emerge -DNautvq --keep-going @preserved-rebuild')
