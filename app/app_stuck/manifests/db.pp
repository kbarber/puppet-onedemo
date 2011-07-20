class app_stuck::db {
  class { "mysql::server":
    config_hash => {
      root_password => "stupidgit",
      bind_address => "0.0.0.0",
    }
  } 

  mysql::db { 'stuck':
    user     => 'stuck',
    password => 'stuck',
    host     => '10.1.2.%',
    grant    => ['all'],
  }
  database_grant { "stuck@localhost/stuck":
    privileges => "all",
  }

  # Load stuck database
  file { "/var/lib/puppet/stuck.sql":
    content => template("${module_name}/mysql.sql"),
    require => [ Mysql::Db["stuck"], Class["mysql::server"] ],
  }->
  exec { "load_stuck_sql":
    command => "/usr/bin/mysql stuck < /var/lib/puppet/stuck.sql && touch /var/lib/puppet/stuck.sql.done",
    creates => "/var/lib/puppet/stuck.sql.done",
  }
}
