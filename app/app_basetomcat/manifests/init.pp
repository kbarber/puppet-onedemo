define app_basetomcat (
  $web_servers = 1,
  $db_servers = 1,
  $lb_servers = 1
  ) {

  cluster { "tcdb":
    domain => "vms.cloud.bob.sh",
    nodes => $db_servers,
    cpu => 1,
    memory => 512,
    classes => {
      "app_basetomcat::db" => {}
    }
  }->
  cluster { "tcweb":
    domain => "vms.cloud.bob.sh",
    nodes => $web_servers,
    cpu => 1,
    memory => 384,
    classes => {
      "app_basetomcat::web" => {},
    }
  }->
  cluster { "tclb":
    domain => "vms.cloud.bob.sh",
    nodes => $lb_servers,
    cpu => 1,
    memory => 256,
    classes => {
      "app_basetomcat::lb" => {},
    }
  }
}
