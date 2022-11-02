#!/bin/bash

eval $(grep -E '^ENV ' Dockerfile | grep -v 'REQUIREMENTS' | sed 's/ \+/=/g' | sed 's/^ENV=/export /')
./download_releases.sh --test
