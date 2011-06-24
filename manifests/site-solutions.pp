# This node will act as the puppetmaster and the OpenNebula controller
node /node\d+\.cloud\.*/ {
  # Purge vm's for this solution
  resources { "onevm": purge => true }

  # Allow forwarding for virtual machine hosts
  sysctl::value { "net.ipv4.ip_forward": value => "1" }

  resources { "firewall": purge => true }
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

  # Get natting working
  firewall { "100 snat for network foo2":
    table => "nat",
    chain => "POSTROUTING",
    proto => "all",
    source => "10.1.2.0/24",
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

  # Mysql database for stored configurations and oned
  class { 'mysql::server':
    config_hash => {
      root_password => "myrootpassword",
    }
  }

  class { "opennebula::controller":
    oneadmin_password => "gozanoli",
    oned_config => {
      'db_backend' => 'sqlite',
#      'db_backend' => 'mysql',
#      'db_server' => 'localhost',
#      'db_user' => 'opennebula',
#      'db_passwd' => 'opennebula',
#      'db_name' => 'opennebula',
      hooks => {
        'dnsupdate' => {
          on => "running",
          command => "/usr/share/one/hooks/puppet/dnsupdate.rb",
          arguments => 'vms.cloud.bob.sh 127.0.0.1 $NAME $NIC[IP]',
          remote => "no",
        },
        'dnsdelete' => {
          on => "done",
          command => "/usr/share/one/hooks/puppet/dnsdelete.rb",
          arguments => 'vms.cloud.bob.sh 127.0.0.1 $NAME',
          remote => "no",
        },
      },
    },
    clusters => [
      'foo'
    ],
    hosts => {
      "${fqdn}" => {
        'im_mad' => 'im_kvm',
        'vm_mad' => 'vmm_kvm',
        'tm_mad' => 'tm_ssh',
      }
    },
    networks => {
      'foo1' => { 
        'type' => "fixed",
        'bridge' => "virbr0",
        'leases' => ["192.168.128.2", "192.168.128.3"],
        'public' => true,
        context => {
          'gateway' => '192.168.128.1',
          'dns' => '8.8.8.8',
        }
      },
      'foo2' => { 
        'type' => "ranged",
        'bridge' => "virbr1",
        'network_size' => "C",
        'network_address' => "10.1.2.0",
        'public' => false,
        context => {
          'gateway' => '10.1.2.254',
          'dns' => '8.8.8.8',
        }        
      },
    },
   images => {
      "debian-wheezy-amd64" => {
        path => "/srv/images/debian-wheezy-amd64-opennebula.qcow2",
        public => true,
        persistent => false,
        dev_prefix => "vd",
        bus => "virtio",
        type => "os",
        description => "Debian Wheezy AMD64 Image",
      },
    },
  }

  class { "opennebula::node":
    controller => $fqdn,
#    im => "im_kvm",
#    vmm => "vmm_kvm",
#    tm => "tm_ssh",
#    cluster => "production",
  }

  class { "opennebula::econe":
    one_xmlrpc => "http://localhost:2633/RPC2",
    port => 4567,
#    econe_config => {
#      'ONE_XMLRPC' => { value => "http://localhost:2633/RPC2" },
#      'SERVER' => { value => $fqdn },
#      'PORT' => { value => 4567 },
#      'VM_TYPE' => { value => [
#	{ name => "m1.small", template => "m1.small.erb" },
#      ]},
#    },
#    vm_types => {
#      'vm1.small' => {
#        cpu => "0.2",
#        memory => 256,
#      }
#    }
  }

  class { "kvm":
  }

  class { libvirt:
    libvirtd_config => {
      max_clients => { value => 10 },
    },
    qemu_config => {
      vnc_listen => { value => "0.0.0.0" },
    },
  }

  class { "apache::passenger":
  }

  # TODO: Some manual resource definitions here - need to be moved and cleaned 
  # up
  apache::a2site { "puppetmaster": }
  apache::a2site { "mirror": }

  # Setup bind
  class { "bind":
  }

  bind::zone { "vms.cloud.bob.sh":
    type => "master",
    allow_update => "127.0.0.1",
    zone_contact => "root@bob.sh",
  }

  bind::zone { "2.1.10.in-addr.arpa":
    type => "master",
    allow_update => "127.0.0.1",
    zone_contact => "root@bob.sh",
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

  ###################
  # Cluster pattern #
  ###################

  cluster { "web":
    domain => "vms.cloud.bob.sh",
    nodes => 4,
    cpu => 1,
    memory => 384,
    classes => {
      "apache" => {},
    }
  }
  cluster { "db":
    domain => "vms.cloud.bob.sh",
    nodes => 2,
    cpu => 1,
    memory => 512,
    classes => {
      "mysql::server" => {
        root_password => "stupidgit",
      },
    }
  }
  cluster { "lb":
    domain => "vms.cloud.bob.sh",
    nodes => 2,
    cpu => 1,
    memory => 256,
    classes => {
      "apache" => {},
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
      files => '/var/lib/one/context/init.sh',
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
