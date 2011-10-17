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
          root_password => hiera("puppet_mysql_password"),
        }
      }

      file { "/etc/puppet/puppet.conf":
        content => template("${module_name}/puppet.conf.master"),
        owner => "root",
        group => "root",
        mode => "0644",
        notify => Service["apache2"],
      }

      # Setup hiera
      file { "/etc/puppet/hiera.yaml":
        content => template("my_puppet/hiera.yaml"),
      }
      file { "/etc/hiera.yaml":
        ensure => link,
        target => "/etc/puppet/hiera.yaml",
      }
      file { "/etc/puppet/gpg":
        ensure => directory,
        owner => root,
        group => puppet,
        mode => "6770",
      }
      package { ["hiera","hiera-gpg", "hiera-puppet"]:
        provider => "gem",
        require => [ File["/etc/puppet/hiera.yaml"], File["/etc/puppet/gpg"], ],
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
