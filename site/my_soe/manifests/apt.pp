class my_soe::apt {
  exec { "getkey":
    command => "/usr/bin/gpg --keyserver subkeys.pgp.net --recv 1054B7A24BD6EC30 && touch /var/lib/puppet/mirror.key",
    creates => "/var/lib/puppet/mirror.key",
    notify => Exec["addkey"],
  }
  exec { "addkey":
    command => "/usr/bin/gpg --export --armor 1054B7A24BD6EC30 | /usr/bin/apt-key add -",
    refreshonly => true,
    notify => Exec["apt-get-update"],
  }
  exec { "apt-get-update":
    command => "/usr/bin/apt-get update",
    refreshonly => true,
  }
}
