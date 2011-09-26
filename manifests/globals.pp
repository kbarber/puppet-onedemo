resources { "firewall": purge => true }
filebucket { main:
  server => puppet,
  path => false,
}
File { backup => main }


# Stages
stage { "pre": before => Stage["main"] }
stage { "post": require => Stage["main"] }
