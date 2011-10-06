# TODO: split this out into a module

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
     { network => "internal",
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
      puppet_environment => "onedemo",
    },
  }

  @@export_classes { "export_${name}":
    params => $classes,
    tag => "vm_${name}",
  }

}
