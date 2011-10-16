define app_stuck (
  $web_servers = 1,
  $db_servers = 1,
  $lb_servers = 1
  ) {

  ######################
  # Pastie application #
  ######################
  solution::cluster { "db":
    domain => "vms.cloud.bob.sh",
    nodes => $db_servers,
    cpu => 1,
    memory => 512,
    classes => {
      "app_stuck::db" => {}
    }
  }->
  solution::cluster { "web":
    domain => "vms.cloud.bob.sh",
    nodes => $web_servers,
    cpu => 1,
    memory => 384,
    classes => {
      "app_stuck::web" => {},
    }
  }->
  solution::cluster { "lb":
    domain => "vms.cloud.bob.sh",
    nodes => $lb_servers,
    cpu => 1,
    memory => 256,
    classes => {
      "app_stuck::lb" => {},
    }
  }
}
