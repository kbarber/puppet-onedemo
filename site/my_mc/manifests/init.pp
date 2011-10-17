class my_mc {
  class { "mcollective":
    mc_security_provider => "psk",
    mc_security_psk => hiera("mc_security_psk"),
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
