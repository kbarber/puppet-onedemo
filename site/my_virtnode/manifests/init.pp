class my_virtnode {
  # Allow forwarding for virtual machine hosts
  sysctl::value { "net.ipv4.ip_forward": value => "1" }

  # Get natting working
  firewall { "100 snat for network foo2":
    table => "nat",
    chain => "POSTROUTING",
    proto => "all",
    source => "10.1.2.0/24",
    outiface => "eth0",
    jump => "MASQUERADE",
  }
  firewall { "100 allow forwarding from foo2":
    chain => "FORWARD",
    proto => "all",
    source => "10.1.2.0/24",
    jump => "ACCEPT",
  }
  firewall { "100 allow forwarding to foo2":
    chain => "FORWARD",
    proto => "all",
    destination => "10.1.2.0/24",
    jump => "ACCEPT",
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

}
