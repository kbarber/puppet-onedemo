# This node will act as the puppetmaster and the OpenNebula controller
node /node1.cloud.*/ {
  class { "opennebula::controller":
    oneadmin_password => "gozanoli",
#    oned_config => {
#      'HOST_MONITORING_INTERVAL' => { value => 600 },
#      'DB' => { value => {
#        "backend" => "mysql", 
#        "server" => "localhost", 
#      }},
#    },
#    networks => {
#      "public" => { value => {
#        'TYPE' => "fixed",
#        'BRIDGE' => "virbr0",
#        'LEASES' => [
#          { ip => "192.168.128.2" },
#        ],
#      }},
#    },
#    images => {
#      "debian-wheezy-amd64" => { value => {
#        path => "/var/lib/opennebula/images/debian-wheezy-amd64/disk.0",
#        public => "YES",
#        description => "Debian Wheezy AMD64 Image",
#      }},
#    },
#    instances => {
#      "puppetmaster1.cloud.bob.sh" => { 
#        config => {
#          'CPU' => 1,
#          'MEMORY' => 512,
#          'OS' => {
#            kernel => '/vmlinuz',
#            initrd => '/initrd.img',
#            root => 'sda',
#          },
#          'DISK' => {
#            image => "debian-wheezy-amd64",
#          },
#          'NIC' => {
#            network => "public",
#          },
#          'CONTEXT' => {
#            files => "/tmp/foo",
#          },
#        },
#        state => running,
#      },
#    }
  }
  class { "opennebula::node":
#    server => $fqdn,
#    im => "im_kvm",
#    vmm => "vmm_kvm",
#    tm => "tm_ssh",
#    cluster => "production",
  }
  class { "opennebula::econe":
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
}
