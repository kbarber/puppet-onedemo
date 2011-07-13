class my_dns {
  # Setup bind
  class { "bind":
  }

  bind::view { "internal":
    match_clients => ["192.168.1.0/24"],
    options => {
      'check-names' => { 'master' => 'fail' },
    }
  }

  bind::view::zone { "internal:mydomain.com":
    type => "master",
    zone_contact => "ken@mydomain.com",
    options => {
      'allow-update' => ['127.0.0.1'],
    }
  }

  bind::view { "external":
  }

  bind::view::zone { "external:vms.cloud.bob.sh":
    type => "master",
    zone_contact => "root@bob.sh",
    options => {
      'masterfile-format' => 'text',
      'allow-update' => ['127.0.0.1'],
    },
  }

  bind::view::zone { "external:2.1.10.in-addr.arpa":
    type => "master",
    zone_contact => "root@bob.sh",
    options => {
      'allow-update' => ['127.0.0.1'],
    }
  }
}
