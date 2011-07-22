class app_basetomcat::lb {
  class { "lvs::keepalived":
  }

  resources { ["keepalived_global_defs","keepalived_vrrp_instance","keepalived_vrrp_sync_group","keepalived_static_routes","keepalived_virtual_server","keepalived_real_server"]:
    purge => true
  }

  sysctl::value { "net.ipv4.ip_forward":
    value => 1,
  }

  Keepalived_real_server {
    notify => Service["keepalived"],
  }

  keepalived_global_defs { 'router_id':
    value => $fqdn,
  }

  keepalived_vrrp_instance { 'vi_basetomcat':
    ensure                    => 'present',
    interface                 => 'eth0',
    lvs_sync_daemon_interface => 'eth0',
    priority                  => 100,
    virtual_ipaddress         => ['10.1.2.201/24'],
    virtual_router_id         => 52,
  }

  keepalived_static_routes { '0.0.0.0/0|224.0.0.0/4':
    ensure => 'present',
    dev    => 'eth0',
    via    => '0.0.0.0',
  }

  keepalived_vrrp_sync_group { 'vg_basetomcat':
    ensure => 'present',
    group => ['vi_basetomcat'],
  }

  keepalived_virtual_server { '10.1.2.201|80|TCP':
    ensure              => 'present',
    delay_loop          => 1,
    lb_algo             => 'rr',
    persistence_timeout => 60,
    lb_kind             => 'DR',
  }

  Keepalived_real_server <<| tag == "app_basetomcat_lb" |>> 

}
