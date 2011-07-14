class my_puppetmaster {
  class { "apache::passenger": }
  apache::a2site { "puppetmaster": }

  # Mysql database for stored configurations and oned
  class { 'mysql::server':
    config_hash => {
      root_password => "myrootpassword",
    }
  }
}
