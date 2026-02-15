#!/bin/bash
find -mindepth 2 -type f -not -path '*/.*' -exec md5sum '{}' + > .checksum

