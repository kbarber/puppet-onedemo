class my_db {
  class { "mysql::server":
    config_hash => {
      root_password => "stupidgit",
      bind_address => "0.0.0.0",
    }
  } 

  mysql::db { 'stikked':
    user     => 'stikked',
    password => 'mypassword',
    host     => '10.1.2.%',
    grant    => ['all'],
  }
}
