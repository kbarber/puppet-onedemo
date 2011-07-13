# Defaults
resources { "firewall": purge => true }
class { "my_soe": }

# This node will act as the puppetmaster and the OpenNebula controller
node /node\d+\.cloud\.*/ {
  # Node configuration
  class { "my_aptmirror": }
  class { "my_virtnode": }
  class { "my_dns": }
  class { "my_onecontroller": }

  # Mysql database for stored configurations and oned
  class { 'mysql::server':
    config_hash => {
      root_password => "myrootpassword",
    }
  }

  class { "apache::passenger":
  }

  # TODO: Some manual resource definitions here - need to be moved and cleaned 
  # up
  apache::a2site { "puppetmaster": }

  class { "ntp":
    servers => [
      'ntp1.hetzner.de',
      'ntp2.hetzner.com',
      'ntp3.hetzner.net',
      '0.debian.pool.ntp.org',
      '1.debian.pool.ntp.org',
    ],
  }

  # Mcollective
  class { "rabbitmq::server":
    delete_guest_user => true,
  }
  class { "mcollective":
    mc_security_psk => 'abc123',
    client => true,
  }

  ###################
  # Cluster pattern #
  ###################

  cluster { "db":
    domain => "vms.cloud.bob.sh",
    nodes => 2,
    cpu => 1,
    memory => 512,
    classes => {
      "my_db" => {}
    }
  }->
  cluster { "web":
    domain => "vms.cloud.bob.sh",
    nodes => 4,
    cpu => 1,
    memory => 384,
    classes => {
      "my_web" => {},
    }
  }->
  cluster { "lb":
    domain => "vms.cloud.bob.sh",
    nodes => 2,
    cpu => 1,
    memory => 256,
    classes => {
      "my_lb" => {},
    }
  }

  ## end ###

}

define export_classes($params) {
  #notify { "export_classes_${name}": message => $params }
  create_resources("class", $params)
}

define cluster($cpu, $memory, $classes, $nodes, $domain) {
   # Get an array of nodes to create
   $node_list = split(inline_template("<% for i in (1..${nodes}) do %>${name}<%= i.to_s %>.${domain},<% end %>"), ",")
   #notify { $node_list: message => "new node" }

   # Pass the array in to create multiple vms
   vm { $node_list:
    cpu => $cpu,
    memory => $memory,
    classes => $classes,
  }
}

define vm($cpu, $memory, $classes) {
  #notify {"new_vm_${name}": message => "CPU: ${cpu} Memory: ${memory} Classes: ${classes}" }

  $disks = [
      { image => "deb-wheezy-amd64-2", 
        driver => "qcow2", 
        target => "vda" },{}
  ]

  $nics = [
     { network => "foo2",
       model => "virtio" },{}
  ]

  onevm { "${name}":
    memory => "${memory}",
    cpu => $cpu,
    vcpu => $cpu,
    os_arch => "x86_64",
    disks => $disks,    
    nics => $nics,
    graphics_type => "vnc",
    graphics_listen => "0.0.0.0",
    context => {
      hostname => '$NAME',
      gateway => '$NETWORK[GATEWAY]',
      dns => '$NETWORK[DNS]',
      ip => '$NIC[IP]',
      files => ['/var/lib/one/context/init.sh'],
      target => "vdb",
    },
  }

  @@export_classes { "export_${name}":
    params => $classes,
    tag => "vm_${name}",
  }

}

node /^.+\.vms\.cloud\./ {
  Export_classes <<| tag == "vm_${fqdn}" |>>
}
