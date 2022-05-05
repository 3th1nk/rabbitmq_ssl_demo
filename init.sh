#!/bin/bash
docker run -p 5671:5671 -p 15672:15672 --name rabbitmq_ssl \
-v $PWD/data/rabbitmq:/var/lib/rabbitmq \
-v $PWD/rabbitmq.conf:/etc/rabbitmq/rabbitmq.conf \
-v $PWD/ssl:/etc/rabbitmq/ssl \
-e TZ=Asia/Shanghai -d rabbitmq:3.7
