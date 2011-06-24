#!/bin/bash

puppet doc --outputdir api/ --mode rdoc --all --modulepath modules/ --manifest manifests/site.pp
