# Jenkins 教程

## 关于作者
10+ 年的研发经验，主要关注云原生、开源等领域。

近期主要维护的项目有：

* [linuxsuren/md-exec](https://github.com/LinuxSuRen/md-exec) 交互式 Markdown 教程
* [linuxsuren/http-downloader](https://github.com/LinuxSuRen/http-downloader) 通用软件包安装工具

更多请访问 https://github.com/linuxsuren

## 项目历史
Jenkins 是 Kohsuke Kawaguchi 于 2004 年[在 Sun Microsystems 工作时发起的开源项目](https://www.cloudbees.com/jenkins/what-is-jenkins)，
当时的项目名为 Hudson。
2019 年时，Jenkins 作为初始项目之一加入了 Continuous Delivery Foundation (CDF，持续交付基金会，属于 Linux 基金会的子基金会)。

## 社区
[Jenkins](https://github.com/jenkinsci/jenkins) 是以 MIT 协议发布的社区性开源项目，
项目采用 Java 语言开发。大家可以通过如下网站了解 Jenkins。

* [官网](https://www.jenkins.io/)
* [插件市场](https://plugins.jenkins.io/)
* [论坛](https://community.jenkins.io/)
* [缺陷库](https://issues.jenkins.io/secure/Dashboard.jspa)

另外，还有一些和 Jenkins 相关的活动：

* DevOps World
* Jenkins User Conference
* Meetup

## 可以做什么
我们为什么需要 Jenkins 呢？我们来假设一个场景，有一个 6 人的团队，分工研发不同的模块，
在没有自动化的持续集成工具的话，可能会遇到如下的一些问题：

* 张三在本地完成功能开发，并将代码提交到代码库中，李四更新代码后却发现无法编译或正常运行
  * 张三为了方便调试，在代码中写入了本地的文件路径，而该路径在其他人的本地不存在导致的错误
  * 张三采用 Java 8 编码，并引入了新特性，而李四则用 Java 7 开发时，发现无法编译
  * 张三在提交代码时，由于疏忽而忘记提交相关配置，导致同样的代码在其他环境中无法运行
* 基于代码交付，研发可能会自行编译、打包代码交由 QA 测试，导致 QA 拿到的测试包可能不一致
* 无法实时地拿到 master 版本的制品包

Jenkins 作为一个自动化服务的工具，可以通过事件（例如：webhook）、定时任务、手动触发等方式完成持续集成工作，从而解决上述等问题。

上面讲的相对比较抽象，有人可能会问到：Jenkins 可以构建 Golang 吗？可以构建 C++ 吗？可以做持续部署吗？虽然 Jenkins 是以持续集成而出名的，但它从本质上来讲，是一个自动化的服务工具，只要是可以自动化的场景 Jenkins 几乎都可以胜任。例如：

* 自动化测试（单元测试、UI、接口、性能等）
* 静态代码分析
* 镜像构建
* 持续部署
* 等等

但也有一些非常容易被误用的场景，由于 Jenkins 的任务执行完成后，
会关闭任务对应的进程，我**非常不推荐**调用需要长期阻塞的命令。例如：

```shell
java -jar sample.war
```

假设 `sample.war` 是 Java 的某个 web 服务的包，就不应该用这种方式来启动服务。你会发现，当 Jenkins 任务执行完成后，对应的 Java 进程也随之消失了。
虽然说，可以通过某些方法可以解决这个问题，但正确的方法是采用启动“服务”的方式
来启动你的应用。例如：`docker run -d xxx/xx`、Linux 的后台服务、Window 服务等方式。

在正式开始前，有一点非常重要，请读者务必谨记：

* Jenkins 几乎所有的功能都是由插件完成的，而你所需要的绝大部分功能应该已经有了对应的插件，通常只需要搜索、安装即可

## Jenkins Core 版本选择

| 版本 | 发布周期 | 适用场景 |
|---|---|---|
| LTS（长期支持） | 每四周发布一次 | 生产环境 |
| Weekly（常规版本）| 每周发布一次 | 学习、体验 |

除场景以外，版本选择还需要注意 JRE（Java Runtime Environment）的版本。例如：

* 2.357+（2022 年 6 月）需要 Java 11、17
* 2.164+（2019 年 2 月）需要 Java 8、11

* 2.361.1+（2022 年 9 月）需要 Java 11、17
* 2.346.1+（2022 年 6 月）需要 Java 8、11、17
* 2.164.1+（2019 年 4 月）需要 Java 8、11

当然，在选择插件时，同样需要注意对 JRE 的依赖。

## 运行方式

| 环境 | 复杂度 | 适用场景 |
|---|---|---|
| JRE | ⭐ | 学习、体验 |
| Tomcat | ⭐⭐ | 生产 |
| Docker | ⭐⭐| 生产 |
| Kubernetes | ⭐⭐⭐ | 生产 |

### JRE
```shell
#!title: Java 直接启动 Jenkins
hd get https://get.jenkins.io/war-stable/2.375.3/jenkins.war -t 10
java -jar jenkins.war
```

这种方式，默认会以目录 `$HOME/.jenkins` 作为 Jenkins 的工作空间。

### Tomcat
```shell
#!title: 下载 Tomcat
k9s
hd get https://dlcdn.apache.org/tomcat/tomcat-10/v10.1.5/bin/apache-tomcat-10.1.5.tar.gz
```

### Docker
```shell
#!title: Docker 中启动 Jenkins
docker run -p 8080:8080 -p 50000:50000 jenkins/jenkins:2.375.3
```

### Kubernetes
```shell
#!title: 创建 K3d
k3d cluster create
k3d node edit --port-add 30002:30002 k3d-k3s-default-serverlb
```

```shell
#!title: 删除 K3d
k3d cluster delete
```

```shell
#!title: Install Jenkins in k8s
cat <<EOF | kubectl apply -n default -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: jenkins
  name: jenkins
spec:
  replicas: 1
  selector:
    matchLabels:
      app: jenkins
  strategy: {}
  template:
    metadata:
      labels:
        app: jenkins
    spec:
      containers:
      - image: jenkins/jenkins:2.375.3
        name: jenkins
        ports:
        - containerPort: 8080
---
apiVersion: v1
kind: Service
metadata:
  labels:
    app: jenkins
  name: jenkins
  namespace: default
spec:
  ipFamilies:
  - IPv4
  ipFamilyPolicy: SingleStack
  ports:
  - nodePort: 30002
    port: 8080
    protocol: TCP
    targetPort: 8080
  selector:
    app: jenkins
  sessionAffinity: None
  type: NodePort
EOF
```

打开 Jenkins 地址：http://localhost:30002

## 概念

* 工作空间（workspace），存放插件、配置信息、任务、任务记录等的根目录
* 视图（view），
* 文件夹（folder），
* 任务（job），
* 流水线（Pipeline），
* 构建（build），指任务的一次执行
* 项（item），泛指：文件夹、视图、任务等
* 插件（plugin），

## 插件安装

* [Kubernetes](https://plugins.jenkins.io/kubernetes/)
* [Configuration as Code](https://plugins.jenkins.io/configuration-as-code/)
* [Blue Ocean](https://plugins.jenkins.io/blueocean/)
* [Pipeline Suite](https://plugins.jenkins.io/workflow-aggregator/)
* [Pipeline Utility Steps](https://plugins.jenkins.io/pipeline-utility-steps/)

## 自由风格
自由风格（free-style）是 Jenkins 非常早期的功能，基本是借助 UI 上插件的配置、shell 脚本来完成所需功能。

```shell
#!title: Start Go Agent
secret=17565475119966173f9e077545eb0c72030b7d441d0035b21eb7672c799ed816
ip=192.168.6.160
docker run surenpi/jenkins-agent-go -url http://${ip}:8080 ${secret} test
```

```shell
#!title: Start Maven Agent
secret=ad867439090256757c5e51e6ea20753fa15925864892c58a3bd1a1e005b41744
ip=192.168.6.160
docker run surenpi/jenkins-agent-maven -url http://${ip}:8080 ${secret} maven
```

```shell
#!title: Start Agent Locally
curl -sO http://localhost:8080/jnlpJars/agent.jar
java -jar agent.jar -jnlpUrl http://localhost:8080/manage/computer/test/jenkins-agent.jnlp -workDir "/tmp/.jenkins/tmp"
```

## 流水线
[Groovy](https://www.groovy-lang.org/)

```groovy
pipeline {
  agent {
    label 'go'
  }

  environment {
    BRANCH = "master"
  }

  parameters {
    string(name: 'PERSON', defaultValue: 'Mr Jenkins', description: 'Who should I say hello to?')
  }

  stages {
    stage('clone') {
      steps {
        sh 'git clone https://gitee.com/linuxsuren/md-exec . --branch ${BRANCH}'
      }
    }

    stage('build') {
      when {
        environment name: 'BRANCH', value: 'master'
      }
      steps {
        sh 'go build .'
      }
    }
  }

  post {
    always {
      echo 'always'
    }
    success {
        archiveArtifacts 'README.md'
    }
  }
}
```

* 申明式、脚本式
* 代码生成器
* 全局变量
* [Step Reference](https://www.jenkins.io/doc/pipeline/steps/)
* 沙盒
* 参数化构建
* 定时构建

## 多分支流水线

通过定时（或 webhook）扫描代码仓库，如果相应分支（或 tag）上有 Jenkinsfile 的话，按照规则来动态管理流水线。
发现新分支会创建流水线，分支被删除后会删除对应的流水线。

扫描规则介绍：

* 分支
* tag
* PR

扫描可以是定时的，也可以是 webhook 触发的

```shell
#!title: Run Jenkins multi-branch Pipeline
jcli center start --setup-wizard=false --image jenkinszh/jenkins-multi-pipeline-zh --version 2.375.3 --c-user root -m docker
```

GitHub 的 webhook 地址为：http://localhost:8080/github-webhook/

在内网测试 webhook 的话，可以借助工具来转发请求：

```shell
hd i ngrok
ngrok http 8080
```

## 角色权限划分


更多查看 https://github.com/jenkinsci/role-strategy-plugin

## Maven

* pom.xml 结构
* settings.xml
* Nexus

## Kubernetes

* 容器与虚拟机的对比介绍
* Docker 的基础介绍
  * Dockerfile
  * Docker 命令基础操作
  * Registry 介绍
* Kubernetes 概述
  * 资源
  * Pod、Namespace
  * Deployment
  * Service
  * ConfigMap、Secret
  * ServiceAccount
  * Role、ClusterRole、RoleBinding、ClusterRoleBinding
* 方便学习的 Kubernetes 发行版
  * kind、k3d、minikube

创建一个临时 Token：

```shell
kubectl create token -n kube-system admin
```

推荐使用的工具：

* k3d
* k9s

基于 Kubernetes 的动态节点，值得注意的点：

* 设置命名空间
* 设置资源限制
* 保留 Pod
* 切换容器

更多请查看 https://github.com/devops-ws/kubernetes-guide

## 共享库

* https://github.com/devops-ws/jenkins-shared-library

## 系统配置

## 工作空间

## 常见问题答疑

* Jenkins 和 JDK 的关系
