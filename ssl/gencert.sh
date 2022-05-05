#!/bin/bash

export OPENSSL_CONF=../openssl.cnf

length=2048
# 证书有效期，单位：天
valid=3650

function genCACert () {
    # Common Name 域名或IP
    local CommonName=$1

    if [ ! -d ./ca/ ]; then
        mkdir ca
        mkdir ca/private
        mkdir ca/certs
        echo "01" > ca/serial
        touch ca/index.txt
    fi

    cd ca
    # TODO：按需修改OrganizationName、OrganizationUnitName
    openssl req -x509 -newkey rsa:$length -days $valid -out cacert.pem -outform PEM -subj "/C=CN/ST=GuangDong/L=ShenZhen/O=OrganizationName/OU=OrganizationUnitName/CN=$CommonName/" -nodes
    openssl x509 -in cacert.pem -out cacert.cer -outform DER
    cd ..
}

function genServerCert () {
    # server name
    local sname=$1
    # PKCS12 password
    local password=$2

    if [ ! -d ./server/ ]; then
        mkdir server
    fi

    cd server

    echo "Generating key.pem"
    openssl genrsa -out $sname.key.pem $length

    echo "Generating req.pem"
    openssl req -new -key $sname.key.pem -out $sname.req.pem -outform PEM -subj /CN=$sname/O=server/ -nodes

    cd ../ca
    echo "Generating cert.pem"
    openssl ca -in ../server/$sname.req.pem -out ../server/$sname.cert.pem -notext -batch -extensions server_ca_extensions

    cd ../server
    echo "Generating keycert.p12"
    openssl pkcs12 -export -out $sname.keycert.p12 -in $sname.cert.pem -inkey $sname.key.pem -passout pass:$password

    cd ..
}

function genClientCert () {
    # client name
    local cname=$1
    # PKCS12 password
    local password=$2

    if [ ! -d ./client/ ]; then
        mkdir client
    fi

    cd client

    echo "Generating key.pem"
    openssl genrsa -out $cname.key.pem $length

    echo "Generating req.pem"
    openssl req -new -key $cname.key.pem -out $cname.req.pem -outform PEM -subj /CN=$cname/O=client/ -nodes

    cd ../ca
    echo "Generating cert.pem"
    openssl ca -in ../client/$cname.req.pem -out ../client/$cname.cert.pem -notext -batch -extensions client_ca_extensions

    cd ../client
    echo "Generating keycert.p12"
    openssl pkcs12 -export -out $cname.keycert.p12 -in $cname.cert.pem -inkey $cname.key.pem -passout pass:$password

    cd ..
}

function clean() {
    rm -rf ca
    rm -rf server
    rm -rf client
}


case "$1" in
    ca)
        if [ $# -ne 2 ]; then
            echo "Usage:  $0 ca [common name]"
            exit 1
        fi
        genCACert $2
    ;;
    server)
        if [ $# -ne 3 ]; then
            echo "Usage:  $0 server [server name] [PKCS12 password]"
            exit 1
        fi
        genServerCert $2 $3
    ;;
    client)
        if [ $# -ne 3 ]; then
            echo "Usage:  $0 client [client name] [PKCS12 password]"
            exit 1
        fi
        genClientCert $2 $3
    ;;
    clean)
        clean
    ;;
    *)
        echo "Usage:  "
        echo "  Generate CA Cert:      $0 ca [common name]"
        echo "  Generate Server Cert:  $0 server [server name] [PKCS12 password]"
        echo "  Generate Client Cert:  $0 client [client name] [PKCS12 password]"
        echo "  Remove Cert Dirs:      $0 clean"
    ;;
esac
