class my_soe {
  # Default firewall rules
  firewall { "000 accept all icmp":
    proto => "icmp",
    jump => "ACCEPT",
  }
  firewall { "001 accept all to lo interface":
    proto => "all",
    iniface => "lo",
    jump => "ACCEPT",
  }
  firewall { "002 accept related established rules":
    proto => "all",
    state => ["RELATED","ESTABLISHED"],
    jump => "ACCEPT",
  }
  firewall { "100 accept ssh":
    proto => "tcp",
    dport => ["22"],
    jump => "ACCEPT",
  }
  firewall { "999 drop all":
    proto => "all",
    jump => "ACCEPT",
  }

  # Packages
  package { "vim": ensure => installed }
  package { "tcpdump": ensure => installed }
}
