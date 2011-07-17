class my_web {
  class { "apache": }
  class { "apache::php": }

  apache::a2site { "default": }

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

  file { "/var/www/index.html":
    content => "${fqdn}\n",
    require => Class["apache"],
  }

  # Networking for DR load-balancing
  sysctl::value { "net.ipv4.conf.eth0.arp_ignore":
    value => 1,
  }->
  sysctl::value { "net.ipv4.conf.eth0.arp_announce":
    value => 2,
  }->
  file { "/etc/network/interfaces":
    owner => "root",
    group => "root",
    mode => "0640",
    content => template("${module_name}/interfaces"),
    notify => Exec["ifup_all"],
  }
  exec { "ifup_all":
    command => "/sbin/ifup -a",
    refreshonly => true,
  }
 
  #############
  # Stuck app #
  #############

  # TODO: consider creating a module for this

  class { "mysql": }
  package { "php5": 
    ensure => installed 
  }->
  package { "php5-mysql": 
    ensure => installed,
    notify => Service["apache2"],
  }

  class { "git": }
  vcsrepo { "/opt/stuck":
    ensure => present,
    source => "https://github.com/cdzombak/Stuck.git",
    provider => "git",
    revision => "HEAD",
  }

  file { "/opt/stuck/system/application/config/config.php":
    content => template("${module_name}/stuck/config.php.dist"),
    before => Apache::A2site["stuck"],
    notify => Service["apache2"],
  }
  file { "/opt/stuck/system/application/config/stikked.php":
    content => template("${module_name}/stuck/stikked.php"),
    before => Apache::A2site["stuck"],
    notify => Service["apache2"],
  }
  file { "/opt/stuck/system/application/config/database.php":
    content => template("${module_name}/stuck/database.php"),
    before => Apache::A2site["stuck"],
    notify => Service["apache2"],
  }

  file { "/etc/apache2/sites-available/stuck":
    content => template("${module_name}/stuck/apache.conf"),
    require => Package["apache2"],
  }->
  apache::a2site { "stuck": }
}
