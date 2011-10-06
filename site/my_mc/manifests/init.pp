class my_mc {
  class { "mcollective":
    mc_security_provider => "ssl",
#    mc_security_psk => 'abc123',
    stomp_server => "10.1.2.254",
    client => true,
  }

  mcollective::plugins::plugin { 'puppetd':
    ensure      => present,
    type        => 'agent',
    ddl         => true,
    application => true,
  }
}
