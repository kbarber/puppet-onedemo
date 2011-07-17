class my_mc {
  class { "mcollective":
    mc_security_psk => 'abc123',
    client_config => template("${module_name}/client.cfg"),
    server_config => template("${module_name}/server.cfg"),
    client => true,
  }

  mcollective::plugins::plugin { 'puppetd':
    ensure      => present,
    type        => 'agent',
    ddl         => true,
    application => true,
  }
}
