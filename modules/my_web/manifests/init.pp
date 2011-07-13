class my_web {
  class { "apache": 
  }
  apache::a2site { "default": 
  }

  # Export real server
  $hc = {
    type => "HTTP_GET",
    connect_port       => '80',
    connect_timeout    => '3',
    nb_get_retry       => '3',
    delay_before_retry => '3',
    url                => [
      {'status_code' => 200, path => '/'}
    ],
  }

  @@keepalived_real_server { "10.1.2.200|80|TCP/${ipaddress_eth0}|80":
    ensure             => 'present',
    healthcheck        => $hc,    
    weight             => '1',
    tag	               => "my_lb",
  }

  sysctl::value { "net.ipv4.conf.eth0.arp_ignore":
    value => 1,
  }
  sysctl::value { "net.ipv4.conf.eth0.arp_announce":
    value => 2,
  }

  network_config { "lo:1":
    bootproto     => "none",
    netmask       => "255.255.255.255",
    ipaddr        => "10.1.2.200",
    require       => Sysctl::Value["net.ipv4.conf.eth0.arp_ignore",
                       "net.ipv4.conf.eth0.arp_announce"],
  }

  file { "/var/www/index.html":
    content => "${fqdn}\n",
  }
 
}
