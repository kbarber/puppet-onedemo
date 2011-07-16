class my_web {
  class { "apache": }
  class { "apache::php": }

  # Php - meh
  package { "php5": ensure => installed }

  apache::a2site { "default": }
  apache::a2site { "stikked": }

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
  }->
  sysctl::value { "net.ipv4.conf.eth0.arp_announce":
    value => 2,
  }

  # TODO: setup networking for non-arp 10.1.2.200 address

  file { "/var/www/index.html":
    content => "${fqdn}\n",
    require => Class["apache"],
  }

  file { "/etc/network/interfaces":
    owner => "root",
    group => "root",
    mode => "0640",
    content => template("${module_name}/interfaces"),
    require => Sysctl::Value["net.ipv4.conf.eth0.arp_announce"],
    notify => Exec["ifup_all"],
  }

  exec { "ifup_all":
    command => "/sbin/ifup -a",
    refreshonly => true,
  }
 
  class { "mysql": }
}
