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

      # Setup hiera
      file { "/etc/puppet/hieradata":
        ensure => directory,
      }
      file { "/etc/puppet/hiera.yaml":
        content => template("my_puppet/hiera.yaml"),
        require => File["/etc/puppet/hieradata"],
      }
      package { ["hiera","hiera-gpg", "hiera-puppet"]:
        provider => "gem",
        require => File["/etc/puppet/hiera.yaml"],
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
