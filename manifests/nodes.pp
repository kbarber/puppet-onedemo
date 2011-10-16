node /node\d+\.cloud\.*/ {
  class { "my_aptmirror": }
  class { "my_virtnode": }
  class { "my_dns": }
  class { "my_onecontroller": }
  class { "my_mq": }
  class { "my_puppet": master => true }

  app_stuck { "pastebin.bob.sh":
    db_servers => 1,
    web_servers => 2,
    lb_servers => 2,
  }
#  app_basetomcat { "tc.bob.sh":
#    db_servers => 0,
#    web_servers => 4,
#    lb_servers => 0,
#  }


  # virt1
#  $disks = [
#      { image => "deb-wheezy-amd64-2",
#        driver => "qcow2",
#        target => "vda" },{}
#  ]
#  $nics = [
#     { network => "internal",
#       model => "virtio" },{}
#  ]
#  onevm { "virt1.vms.cloud.bob.sh":
#    memory => "256",
#    cpu => 1,
#    vcpu => 1,
#    os_arch => "x86_64",
#    disks => $disks,
#    nics => $nics,
#    graphics_type => "vnc",
#    graphics_listen => "0.0.0.0",
#    context => {
#      hostname => '$NAME',
#      gateway => '$NETWORK[GATEWAY]',
#      dns => '$NETWORK[DNS]',
#      ip => '$NIC[IP]',
#      files => '/var/lib/one/context/init.sh',
#      target => "vdb",
#      puppet_environment => "onedemo",
#    }
#  }

  class { "my_soe": }

}

node default {
  Solution::Export_classes <<| tag == "vm_${fqdn}" |>>

  class { "my_soe": }
}

