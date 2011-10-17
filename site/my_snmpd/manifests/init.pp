class my_snmpd {
  $my_snmpd_secret = hiera("snmp_secret")

  package { "snmpd":
    ensure => installed,
  }

  file { "/etc/snmp/snmpd.conf": 
    content => template("${module_name}/snmpd.conf"),
    owner => "root",
    group => "root",
    mode => "0600",
    require => Package["snmpd"],
  }

  service { "snmpd":
    ensure => running,
    enable => true,
    hasstatus => false,
    subscribe => File["/etc/snmp/snmpd.conf"],
  }
}
