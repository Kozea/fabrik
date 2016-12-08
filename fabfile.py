#!/usr/bin/env python2

import signal

from fabric.api import env, sudo as fabric_sudo, parallel
from gi.repository import Notify


env.use_ssh_config = True
env.hosts = ['geraldine', 'claire', 'cecile', 'fanny', 'melanie']

Notify.init('Fabrik')


def sudo(title, task, timeout=120):
    signal.signal(
        signal.SIGALRM,
        lambda signum, frame: Notify.Notification.new(title).show())
    signal.alarm(timeout)
    fabric_sudo(task)
    signal.alarm(0)


def password():
    sudo('Saisie du mot de passe', 'echo "PASSWORD OK"', timeout=10)


@parallel
def sync():
    fabric_sudo('emaint sync -a')


def update():
    sudo('Lecture des nouvelles', 'eselect news read')
    sudo('Mise à jour du serveur', 'emerge -DNautq --keep-going --with-bdeps=y --quiet-build @world')
    sudo('Mise à jour des configurations', 'dispatch-conf')
    sudo('Recompilation des paquets', 'revdep-rebuild -q -- -avq1')
    sudo('Recompilation des paquets préservés', 'emerge -aq --keep-going @preserved-rebuild')
    sudo('Nettoyage du serveur', 'emerge -aq --depclean')


def depclean():
    sudo('Nettoyage du serveur', 'emerge -avq --depclean')
