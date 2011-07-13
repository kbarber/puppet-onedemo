# Class to setup an apt-mirror for the opennebula demo
class my_aptmirror {
  file { "/etc/apt/mirror.list":
    content => template("${module_name}/mirror.list"),
    mode => "0644",
    owner => "root",
    group => "root",
    notify => Exec["apt-mirror"],
  }
  exec { "apt-mirror":
    command => "/usr/bin/apt-mirror",
    timeout => 2400,
    refreshonly => true,
  }

  # Web
  file { "/etc/apache2/sites-available/mirror":
    content => template("${module_name}/mirror.httpd.conf"),
    owner => "root",
    group => "root",
    mode => "0644",
    notify => Apache::A2site["mirror"],
  }
  apache::a2site { "mirror": }
}
