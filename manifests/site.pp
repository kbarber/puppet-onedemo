import 'globals.pp'
import 'solutions.pp'
import 'nodes.pp'

file { "/tmp/foo": content => "barfoo" }

notice("$swapsize")
