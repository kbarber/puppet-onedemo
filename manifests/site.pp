# This node will act as the puppetmaster and the OpenNebula controller
node /node1.cloud.*/ {
  class { "opennebula::controller":
    oneadmin_password => "gozanoli",
    oned_config => {
      'db_backend' => 'sqlite',
#      'db_backend' => 'mysql',
#      'db_server' => 'localhost',
#      'db_user' => 'opennebula',
#      'db_passwd' => 'opennebula',
#      'db_name' => 'opennebula',
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
      },
      'foo2' => { 
        'type' => "ranged",
        'bridge' => "virbr1",
        'network_size' => "C",
        'network_address' => "10.1.2.0",
        'public' => false,
      },
    },
    vms => {
      "base1" => {
        memory => "256",
        cpu => 1,
        vcpu => 1,
        os_arch => "x86_64",
        disks => [
          { image => "debian-wheezy-amd64", 
            driver => "qcow2", 
            target => "vda" }
        ],
        nics => [
          { network => "foo1" }
        ],
        graphics_type => "vnc",
        graphics_listen => "0.0.0.0",
      },
      "base2" => {
        memory => "256",
        cpu => 1,
        vcpu => 1,
        os_arch => "x86_64",
        disks => [
          { image => "debian-wheezy-amd64", 
            driver => "qcow2", 
            target => "vda" }
        ],
        nics => [
          { network => "foo2" }
        ],
        graphics_type => "vnc",
        graphics_listen => "0.0.0.0",
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
#    server => $fqdn,
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

}
