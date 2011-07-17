# Defaults
import 'solutions.pp'
resources { "firewall": purge => true }

# Stages
stage { "pre": before => Stage["main"] }
stage { "post": require => Stage["main"] }

# All nodes get SOE
class { "my_soe": }

# This node will act as the puppetmaster and the OpenNebula controller
node /node\d+\.cloud\.*/ {
  # Node configuration
  class { "my_aptmirror": }
  class { "my_virtnode": }
  class { "my_dns": }
  class { "my_onecontroller": }
  class { "my_puppetmaster": }
  class { "my_mq": }

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

}

node /^.+\.vms\.cloud\./ {
  Export_classes <<| tag == "vm_${fqdn}" |>>
}
