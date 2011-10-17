# Setup firewall resource
resources { "firewall": purge => true }
filebucket { main:
  server => puppet,
  path => false,
}

# Send file backups to main
File { backup => main }

# Stages
stage { "pre": before => Stage["main"] }
stage { "post": require => Stage["main"] }
