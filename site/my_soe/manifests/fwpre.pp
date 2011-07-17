class my_soe::fwpre {
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
  # TODO: move to ssh module
  firewall { "100 accept ssh":
    proto => "tcp",
    dport => ["22"],
    jump => "ACCEPT",
  }
}
