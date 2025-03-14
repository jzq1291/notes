# Docker Installation and Configuration

## Install Docker
> apt-get install docker-ce docker-ce-cli containerd.io

## Check Docker Version
> docker version

## Check Docker Status
> sudo systemctl status docker

## Check Docker Config
> docker info

## Docker Config File location
> /etc/docker/daemon.json

## Use docker to set dev-env
1. check docker 
    sudo docker pull hello-world
    sudo docker run hello-world
2. craete dockerfiel
   DemoDockerFile
3. build docker image
   sudo docker build [-f dockerfile] -t my-dev-env .`
4. check image build succeeds
   sudo docker images
5. remove image(option)
    sudo docker stop f2389983c5f1(container)
    sudo docker rm f2389983c5f1
    sudo docker rmi openjdk:17-jdk
    docker image prune(删除所有未使用的image)
6. 运行Docker容器
   docker run -p 8081:8080 -d --name dev-env-container my-dev-env
   docker run -P -d --name dev-env-container my-dev-env 
   -p 指定端口
   -P(大写) 随机端口
7. 查看容器状态
   docker ps [-a]
8. 进入容器
   docker exec -it my-env2-c /bin/bash
9. 检查容器内service
   echo $CATALINA_HOME
   java -version
   service postgresql status

10. 重新启动已有容器
   docker start[stop][restart] mydenv_container

11. 在windows 中访问tomcat


# Docker knowledge
## docker vs vm
   Ⅰ. Docker 更轻量级, docker与宿主机公用操作系统, 无性能损耗

## image command
   docker images
   docker images -q
   docker images -a
   docker images --digests    摘要

   docker search tomcat                      from hub.docker.com
   docker search --filter=stars=30 tomcat    点赞数超过30
   docker pull tomcat 
   docker rmi image1 [image2...]
   docker image prune                        删除所有未使用的image
   docker rmi -f $(docker images -qa)        删除所有


## container command
   docker run -d --name XXX image           分离模式运行 (redis,tomcat)
   docker run -it --name XXX image          交互模式运行 (centos), 会直接进入到容器    -i(需要输入), -t(需要终端)
   docker exec -it container /bin/bash      进入容器
   docker start[stop][restart] mydenv_container     启动/停止/重启容器
   docker kill container                    强制停止容器
   docker rm $(docker ps -aq)            
   docker ps -aq | xargs docker rm          删除所有容器


   docker logs -f -t --tail 20              查看容器日志  -t(显示时间) -f(一直追加) --tail(显示n条)
   docker top container                     查看容器内的所有进程
   docker inspect container                 查看容器详细信息

   docker attach container                  进入容器(连接已经运行的进程)
   docker exec -it container /bin/bash(/bin/sh)   进入到容器 (会启动新的进程)
   docker exec -it container ls             在容器外部直接操作容器内部的内容

   docker cp myhhh.txt c4750ce92f00:myhhh   copy文件从宿主机到容器
   docker cp c4750ce92f00:myhhh myhhh.txt   copy文件从容器到宿主机


# Docker 镜像原理
UnionFS 联合文件系统
一个tomcat = kernel > centos > jdk > tomcat
Redis = kernel > centos > redis
首先pull了tomcat, 那么下次pull redis的时候就可以共享centos


# Docker commit
概念:一个image运行成容器之后, 在容器中做了修改, 可以将这个容器commit成一个新的image
命令:
docker commit -a="zhiqiang" -m="comments" containerId zhiqiang/mytomcat:1.1


# Docker 数据卷
Volume
1. 数据持久化, 容器被删除之后, Volume中数据还在,可以在新容器中再次使用
2. 数据共享:不同容器可以挂载同一个数据卷, 实现数据共享
3. 高性能: 性能优于直接使用容器的文件系统
4. 运行容器并挂载Volume
docker run -it -v ./docker/myVolumeData:/containerVolumeData centos
5. 使Volume在容器中只读 - :ro
docker run -it -v ./docker/myVolumeData:/containerVolumeData:ro centos
6. 无法让文件在宿主机只读, 要达到只能通过chmod权限控制

# 用Dockerfile 添加数据卷
1. 写dockerfile
   VOLUME /var/docker/postgresql/data
2. build image
   docker build -t my-env2 -f dockerfile .
3. run image
   docker run -it image
4. 容器中会生成一个数据卷, 宿主机的数据卷会在默认目录,名字自动生成
   docker inspect container 产看宿主机数据卷位置
5. 直接通过dockerfile挂在数据卷无法直接让数据卷在容器中只读, 可以通过 docker-compose.yaml实现
6. 也无法让多个容器公用一个数据卷, 可以通过容器数据卷或者 docker-compose.yaml实现
   

# 数据卷容器 Volumes-from
  容器间数据传递共享,env1, env2实现数据共享
  docker run -it --name env2 myimage /bin/bash
  docker run -it --name env2 --volumes-from env1 myimage[newimage] /bin/bash
  note: myimage可以是不一样的


# Dockerfile 解析
FROM: base image
RUN: 容器构建时需要用到的命令 (下载)
EXPOSE: 暴露端口
WORKDIR: 默认工作目录
ENV: 设置环境变量
COPY: 复制文件从宿主机到镜像
   note: 不是到容器(cp),而是成为镜像永久的一部分
ADD:复制文件从宿主机到镜像, 并且可以解压, 或者从url下载

VOLUME: 数据卷, 用于数据持久化
CMD: 容器启动时默认执行的命令, 会被Docker run 后面的命令替换
ENTRYPOINT:CMD功能的增强, 但是run后面的命令会被追加到dockerfile指定的命令后
LABEL:添加Author, description等
ONBUILD: 定义在BaseImage中的trigger, 当build一个子Image时会执行.


# install redis
docker pull redis
docker run
通过redis-cli连上redis
docker exec -it container redis-cli

指定redis的配置文件和数据卷位置
docker run -d -p 6379:6379 --name my-redis
-v ./docker/myredis:/data 
-v ./docker/config/redis.conf:/usr/local/etc/redis/redis.conf  
redis:latest 
redis-server /usr/local/etc/redis/redis.conf


## Push image to dockerhub
docker login --username=zhiqiang1291 crpi-vp7bgl5paq0d6lym.cn-shanghai.personal.cr.aliyuncs.com

docker tag eb208efd97ba crpi-vp7bgl5paq0d6lym.cn-shanghai.personal.cr.aliyuncs.com/zhiqiangimages/test:1.3.1

docker push crpi-vp7bgl5paq0d6lym.cn-shanghai.personal.cr.aliyuncs.com/zhiqiangimages/test:1.3.1