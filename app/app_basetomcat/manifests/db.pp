class app_basetomcat::db {
  class { "mysql::server":
    config_hash => {
      root_password => "stupidgit",
      bind_address => "0.0.0.0",
    }
  } 

#  mysql::db { 'sample':
#    user     => 'sample',
#    password => 'sample',
#    host     => '10.1.2.%',
#    grant    => ['all'],
#  }
#  database_grant { "sample@localhost/sample":
#    privileges => "all",
#  }

  # Load stuck database
#  file { "/var/lib/puppet/stuck.sql":
#    content => template("${module_name}/mysql.sql"),
#    require => [ Mysql::Db["stuck"], Class["mysql::server"] ],
#  }->
#  exec { "load_stuck_sql":
#    command => "/usr/bin/mysql stuck < /var/lib/puppet/stuck.sql && touch /var/lib/puppet/stuck.sql.done",
#    creates => "/var/lib/puppet/stuck.sql.done",
#  }
}
