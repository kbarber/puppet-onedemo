# This node will act as the puppetmaster and the OpenNebula controller
node /node1.cloud.*/ {
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
    root_password => "myrootpassword",
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
    vms => {
#      "virt4.vms.cloud.bob.sh" => {
#        memory => "512",
#        cpu => 1,
#        vcpu => 1,
#        os_arch => "x86_64",
#        disks => [
#          { image => "deb-wheezy-amd64-2", 
#            driver => "qcow2", 
#            target => "vda" }
#        ],
#        nics => [
#          { network => "foo2",
#            model => "virtio" }
#        ],
#        graphics_type => "vnc",
#        graphics_listen => "0.0.0.0",
#        context => {
#          hostname => '$NAME',
#          gateway => '$NETWORK[GATEWAY]',
#          dns => '$NETWORK[DNS]',
#          ip => '$NIC[IP]',
#          files => '/var/lib/one/context/init.sh',
#          target => "vdb",
#        },
#      },
#      "virt3.vms.cloud.bob.sh" => {
#        memory => "512",
#        cpu => 1,
#        vcpu => 1,
#        os_arch => "x86_64",
#        disks => [
#          { image => "deb-wheezy-amd64-2",
#            driver => "qcow2", 
#            target => "vda" }
#        ],
#        nics => [
#          { network => "foo2",
#            model => "virtio" }
#        ],
#        graphics_type => "vnc",
#        graphics_listen => "0.0.0.0",
#        context => {
#          hostname => '$NAME',
#          gateway => '$NETWORK[GATEWAY]',
#          dns => '$NETWORK[DNS]',
#          ip => '$NIC[IP]',
#          files => '/var/lib/one/context/init.sh',
#          target => "vdb",
#        },
#      },
#      "virt2.vms.cloud.bob.sh" => {
#        memory => "512",
#        cpu => 1,
#        vcpu => 1,
#        os_arch => "x86_64",
#        disks => [
#          { image => "deb-wheezy-amd64-2", 
#            driver => "qcow2", 
#            target => "vda" }
#        ],
#        nics => [
#          { network => "foo2",
#            model => "virtio" }
#        ],
#        graphics_type => "vnc",
#        graphics_listen => "0.0.0.0",
#        context => {
#          hostname => '$NAME',
#          gateway => '$NETWORK[GATEWAY]',
#          dns => '$NETWORK[DNS]',
#          ip => '$NIC[IP]',
#          files => '/var/lib/one/context/init.sh',
#          target => "vdb",
#        },
#      },
      "virt1.vms.cloud.bob.sh" => {
        memory => "512",
        cpu => 1,
        vcpu => 1,
        os_arch => "x86_64",
        disks => [
          { image => "deb-wheezy-amd64-2", 
            driver => "qcow2", 
            target => "vda" }
        ],
        nics => [
          { network => "foo2",
            model => "virtio" }
        ],
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

  # Create sample zone file
  $bind_zone_name = "vms.cloud.bob.sh"
  $bind_zone_contact = "root.bob.sh"
  $bind_zone_ns = "node1.cloud.bob.sh"
  file { "/var/lib/bind/vms.cloud.bob.sh.zone":
    replace => false,
    owner => $bind::bind_user,
    group => $bind::bind_group,
    mode => "0644",
    content => template("bind/sample.zone"),
  }

  bind::zone { "vms.cloud.bob.sh":
    type => "master",
    file => "/var/lib/bind/vms.cloud.bob.sh.zone",
    allow_update => "127.0.0.1",
  }

}

define foo () {
  file { "/tmp/foo": content => $name }
}

node /^virt/ {
  notify { "welcome": message => "Box is ${fqdn}" }
  file { "/etc/motd": content => "Welcome to ${fqdn}\n" }
}
