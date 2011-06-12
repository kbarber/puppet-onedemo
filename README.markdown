# OpenNebula Demo Environment

This repository contains a self-contained Puppet environment which demonstrates
the capabilities of Puppet and OpenNebula integration.

# Quickstart

The demo is designed to run in an environment. Try creating the directory:

    /etc/puppet/envs

Then checking out the onedemo repository:

    cd /etc/puppet/envs
    git clone --recursive git@github.com:kbarber/onedemo.git

Here is a sample puppet.conf:

    [main]
    logdir=/var/log/puppet
    vardir=/var/lib/puppet
    ssldir=/var/lib/puppet/ssl
    rundir=/var/run/puppet
    factpath=$vardir/lib/facter
    templatedir=$confdir/templates
    prerun_command=/etc/puppet/etckeeper-commit-pre
    postrun_command=/etc/puppet/etckeeper-commit-post
    
    [master]
    ssl_client_header = SSL_CLIENT_S_DN 
    ssl_client_verify_header = SSL_CLIENT_VERIFY
    
    [onedemo]
    manifest=/etc/puppet/envs/onedemo/manifests/site.pp
    modulepath=/etc/puppet/envs/onedemo/modules
    
    [agent]
    environment = onedemo
    pluginsync = true

You should then be able to test with:

    puppet agent -t

# Copyright

Copyright 2011 Puppetlabs Inc, unless otherwise noted.
