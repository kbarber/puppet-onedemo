class my_snmpd {
  if !$my_snmp_secret {
    $my_snmp_secret = "public"
  }

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
