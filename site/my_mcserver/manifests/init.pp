class my_mcserver {
  # Mcollective
  class { "rabbitmq::server":
    delete_guest_user => true,
  }
  class { "mcollective":
    mc_security_psk => 'abc123',
    client => true,
  }
}
