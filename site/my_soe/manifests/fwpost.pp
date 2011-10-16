class my_soe::fwpost {
  firewall { "999 drop all":
    proto => "all",
    action => accept,
  }
}
