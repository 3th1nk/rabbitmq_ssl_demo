#!/bin/bash
addr=$1

openssl s_client -connect $addr -cert ./client/demo.cert.pem -key ./client/demo.key.pem -CAfile ./ca/cacert.pem