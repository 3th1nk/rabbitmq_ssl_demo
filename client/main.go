package main

import (
	"crypto/tls"
	"crypto/x509"
	"fmt"
	"io/ioutil"

	amqp "github.com/rabbitmq/amqp091-go"
)

func main() {
	addr := "amqps://demo@127.0.0.1:5671/"

	CAPath := "../ssl/ca/cacert.pem"
	CertPath := "../ssl/client/demo.cert.pem"
	KeyPath := "../ssl/client/demo.key.pem"

	pool := x509.NewCertPool()
	ca, err := ioutil.ReadFile(CAPath)
	if err != nil {
		panic(err)
	}
	pool.AppendCertsFromPEM(ca)

	cert, err := tls.LoadX509KeyPair(CertPath, KeyPath)
	if err != nil {
		panic(err)
	}

	// 生产环境建议指定InsecureSkipVerify=false, 此时需要同时指定ServerName，ServerName值需要和证书的IP、域名匹配，详见ssl/openssl.cnf的server_ca_extensions.subjectAltName配置
	conn, err := amqp.DialTLS_ExternalAuth(addr, &tls.Config{
		Certificates:       []tls.Certificate{cert},
		RootCAs:            pool,
		ClientCAs:          pool,
		InsecureSkipVerify: true,
		// InsecureSkipVerify: false,
		// ServerName:         "demo.com",
	})
	if err != nil {
		panic(err)
	}
	defer conn.Close()

	if st := conn.ConnectionState(); st.HandshakeComplete {
		fmt.Println("complete TLS handshake")
	}
}
