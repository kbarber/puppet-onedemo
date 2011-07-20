class my_puppet (
  $master = false
  ) {

  case $master {
    true: {
      class { "apache::passenger": }
      apache::a2site { "puppetmaster": }
    
      # Mysql database for stored configurations and oned
      class { 'mysql::server':
        config_hash => {
          root_password => "myrootpassword",
        }
      }

      file { "/etc/puppet/puppet.conf":
        content => template("${module_name}/puppet.conf.master"),
        owner => "root",
        group => "root",
        mode => "0644",
        notify => Service["apache2"],
      }
    }
    false: {
      file { "/etc/puppet/puppet.conf":
        content => template("${module_name}/puppet.conf.agent"),
        owner => "root",
        group => "root",
        mode => "0644",
      }
    }
  }

}