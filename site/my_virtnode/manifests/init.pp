class my_virtnode {
  # Allow forwarding for virtual machine hosts
  sysctl::value { "net.ipv4.ip_forward": value => "1" }

  firewall { "100 allow forwarding from internal":
    chain => "FORWARD",
    proto => "all",
    source => "10.1.2.0/24",
    jump => "ACCEPT",
  }
  firewall { "100 allow forwarding to internal":
    chain => "FORWARD",
    proto => "all",
    destination => "10.1.2.0/24",
    jump => "ACCEPT",
  }

  firewall { "200 dnat loadbalanced ip":
    chain => "PREROUTING",
    table => "raw",
    proto => "tcp",
    destination => "46.4.106.119",
    dport => "80",
    todest => "10.1.2.200",
    iniface => "eth0",
    jump => "RAWDNAT",
  }
  firewall { "201 snat loadbalanced ip":
    chain => "POSTROUTING",
    table => "rawpost",
    proto => "tcp",
    source => "10.1.2.200",
    sport => "80",
    tosource => "46.4.106.119",
    outiface => "eth0",
    jump => "RAWSNAT",
  }

  # Outbound nat
  firewall { "500 outbound nat for internal":
    table => "nat",
    chain => "POSTROUTING",
    proto => "all",
    source => "10.1.2.0/24",
    outiface => "eth0",
    jump => "MASQUERADE",
  }


  class { "opennebula::node":
    controller => $fqdn,
#    im => "im_kvm",
#    vmm => "vmm_kvm",
#    tm => "tm_ssh",
#    cluster => "production",
  }

  class { "kvm": }

  class { libvirt:
    libvirtd_config => {
      max_clients => { value => 10 },
    },
    qemu_config => {
      vnc_listen => { value => "0.0.0.0" },
    },
  }

  class { "ntp":
    servers => [
      'ntp1.hetzner.de',
      'ntp2.hetzner.com',
      'ntp3.hetzner.net',
      '0.debian.pool.ntp.org',
      '1.debian.pool.ntp.org',
    ],
  }
}
