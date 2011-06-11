node /cloudnode/ {
  Class <<| tag == $fqdn |>>
}


class { "solution::ldap":
  hostname => "ldap.bob.sh",
}

# Solution ldap
class "solution::ldap" (
  $hostname,
  ) {

  cluster { "ldap":
    nodes => 2,
    cpu => 1,
    memory => 256,
    role => "ldap",
  }

}

solution { "openerp":
  hostname => "erp.bob.sh",
  ldap => {
    server => Solution['ldap'],
  },
}

# Solution openerp
solution openerp (
  $hostname,
  $ldap = undef,
  ) {

  cluster { "openerp::db": }
  cluster { "openerp::openobject": 
    ldap => $ldap,
  }
  cluster { "openerp::web": }

}

class "cluster::openerp::db" {
  class { postgresql::server: 
    port => 5432,
  } 

  class { "nodes":
    
  }
}

cluster "openerp::openobject" (
  $ldap = undef
  ) {
  class { "openerp::openobject": 
    ldap => $ldap,
  }
  class { apache:
    modules => "python",
    ssl => true,
  }
}

cluster openerp::web {
  class { apache:
    modules => "python",
  }
  class { "openerp::web":
  }
}


