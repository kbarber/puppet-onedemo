class app_basetomcat::web {
  class { "apache": }

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
  @@keepalived_real_server { "10.1.2.201|80|TCP/${ipaddress_eth0}|80":
    ensure             => 'present',
    healthcheck        => $hc,    
    weight             => '1',
    tag	               => "app_basetomcat_lb",
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
 
  ##############
  # Tomcat app #
  ##############

  class { "mysql": }
  class { "java": }~>
  exec { "update-sun-java":
    command => "/usr/sbin/update-java-alternatives -s java-6-sun",
    refreshonly => true,
  }->
  file { "/usr/lib/jvm/default-java":
    ensure => "link",
    source => "/usr/lib/jvm/java-6-sun",
  }
  file { "/etc/default/tomcat7":
    content => template("${module_name}/tomcat7"),
    before => Package["tomcat7"],
    notify => Service["tomcat7"],
  }
  package { ["tomcat7", "tomcat7-admin", "tomcat7-common", "tomcat7-docs",
    "tomcat7-examples", "tomcat7-user"]:
    ensure => installed,
    notify => Service["tomcat7"],
    require => [Class["java"], File["/usr/lib/jvm/default-java"]],
  }
  file { "/etc/tomcat7/server.xml":
    content => template("${module_name}/server.xml"),
    require => Package["tomcat7"],
    notify => Service["tomcat7"],
  }
  service { "tomcat7":
    ensure => running,
    enable => true,
    hasstatus => true,
    hasrestart => true,
  }->
  exec { "/usr/sbin/a2enmod proxy_ajp":
    creates => "/etc/apache2/mods-enabled/proxy_ajp.load",
    require => Package["apache2"],
    notify => Service["apache2"],
  }
  exec { "/usr/sbin/a2enmod rewrite":
    creates => "/etc/apache2/mods-enabled/rewrite.load",
    require => Package["apache2"],
    notify => Service["apache2"],
  }
  file { "/etc/apache2/sites-available/basetomcat":
    content => template("${module_name}/apache.conf"),
    require => Package["apache2"],
  }->
  apache::a2site { "basetomcat": }

}
