#node /cloudnode/ {
#  Class <<| tag == $fqdn |>>
#}

# Solution ldap

class solution::ldap {

  class { "cluster::ldap":
    nodes => 2,
    cpu => 1,
    memory => 256,
    role => "ldap",
  }
  
}


class { "solution::ldap":
  hostname => "ldap.bob.sh",
}



#solution { "openerp":
#  hostname => "erp.bob.sh",
#  ldap => {
#    server => Solution['ldap'],
#  },
#}

# Solution openerp
class solution::openerp (
  $hostname,
  $ldap = undef,
  ) {

  class { "openerp::db": }
  class { "openerp::openobject": 
    ldap => $ldap,
  }
  class { "openerp::web": }

}

class cluster::openerp::db {
  class { postgresql::server: 
    port => 5432,
  } 

  class { "nodes":
    
  }
}

class cluster::openerp::openobject (
  $ldap = undef
  ) {
    
  class { openerp::openobject: 
    ldap => $ldap,
  }
  class { apache:
    modules => "python",
    ssl => true,
  }
}

class cluster::openerp::web {
  class { apache:
    modules => "python",
  }
  class { "openerp::web":
  }
}


