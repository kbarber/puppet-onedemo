class my_db {
  class { "mysql::server":
    config_hash => {
      root_password => "stupidgit",
    }
  } 
}
