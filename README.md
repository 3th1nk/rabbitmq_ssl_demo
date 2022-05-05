## RabbitMQ 配置SSL、开启EXTERNAL认证方式

### 生成证书
* 脚本：ssl/gencert.sh，可按需调整脚本和openssl.cnf
```
    cd ssl
    ./gencert.sh clean
    ./gencert.sh ca 'demo.com'
    ./gencert.sh server demo 'demo@pass'
    ./gencert.sh client demo 'demo@pass'
```


### 调整配置
* 详见rabbitmq.conf

### 启动容器
```
    docker run -p 5671:5671 -p 15672:15672 --name rabbitmq_ssl \
    -v $PWD/data/rabbitmq:/var/lib/rabbitmq \
    -v $PWD/rabbitmq.conf:/etc/rabbitmq/rabbitmq.conf \
    -v $PWD/ssl:/etc/rabbitmq/ssl \
    -e TZ=Asia/Shanghai -d rabbitmq:3.7
```

### 开启插件
```
    docker exec -it rabbitmq_ssl bash
    rabbitmq-plugins enable rabbitmq_auth_mechanism_ssl
    rabbitmq-plugins enable rabbitmq_management 
    rabbitmq-plugins list
```

### 验证服务是否正常开启
* 脚本：ssl/verify_ssl.sh

### 验证客户端连接
* 详见client代码