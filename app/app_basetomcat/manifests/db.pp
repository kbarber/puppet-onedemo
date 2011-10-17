class app_basetomcat::db {
  $app_basetomcat_config = hiera("app_basetomcat")

  class { "mysql::server":
    config_hash => {
      root_password => $app_basetomcat_config["mysql_root_password"],
      bind_address => "0.0.0.0",
    }
  } 
}
