class my_soe {
  class { my_mc: }
  class { "my_soe::apt": stage => pre }
  class { "my_soe::fwpre": stage => pre }
  class { "my_soe::fwpost": stage => post }
  include my_puppet

  # Packages
  package { "vim": ensure => installed }
  package { "tcpdump": ensure => installed }

  sysctl::value { "net.ipv4.tcp_keepalive_time": value => "600" }

  class { "resolver": 
    nameserver => "10.1.2.254",
    search => ["cloud.bob.sh","vms.cloud.bob.sh"],
  }
}
