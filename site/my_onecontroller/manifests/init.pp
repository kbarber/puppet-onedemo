class my_onecontroller {
  # Purge vm's for this solution
  resources { "onevm": purge => true }

  class { "opennebula::controller":
    oneadmin_password => hiera("opennebula_controller_password"),
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
      'production'
    ],
    hosts => {
      "${fqdn}" => {
        'im_mad' => 'im_kvm',
        'vm_mad' => 'vmm_kvm',
        'tm_mad' => 'tm_ssh',
      }
    },
    networks => {
      'internal' => {
        'type' => "ranged",
        'bridge' => "virbr1",
        'network_size' => "C",
        'network_address' => "10.1.2.0",
        'public' => false,
        context => {
          'gateway' => '10.1.2.254',
          'dns' => '10.1.2.254',
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

  class { "opennebula::econe":
    one_xmlrpc => "http://localhost:2633/RPC2",
    port => 4567,
#    econe_config => {
#      'ONE_XMLRPC' => { value => "http://localhost:2633/RPC2" },
#      'SERVER' => { value => $fqdn },
#      'PORT' => { value => 4567 },
#      'VM_TYPE' => { value => [
#       { name => "m1.small", template => "m1.small.erb" },
#      ]},
#    },
#    vm_types => {
#      'vm1.small' => {
#        cpu => "0.2",
#        memory => 256,
#      }
#    }
  }

  class { "opennebula::sunstone": }
}
