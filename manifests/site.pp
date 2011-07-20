# Defaults
import 'solutions.pp'
resources { "firewall": purge => true }

# Stages
stage { "pre": before => Stage["main"] }
stage { "post": require => Stage["main"] }

node /node\d+\.cloud\.*/ {
  class { "my_aptmirror": }
  class { "my_virtnode": }
  class { "my_dns": }
  class { "my_onecontroller": }
  class { "my_mq": }
  class { "my_puppet": master => true }

  app_stuck { "pastebin.bob.sh":
    db_servers => 2,
    web_servers => 2,
    lb_servers => 2,
  }

  class { "my_soe": }
}

node /^.+\.vms\.cloud\./ {
  Export_classes <<| tag == "vm_${fqdn}" |>>

  class { "my_soe": }
}

