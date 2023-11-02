# 平台对异构设备的支持
本项目支持对异构设备的支持，需要平台适配不同的插件。
Kubernetes 支持对节点上的 AMD 和 NVIDIA GPU （图形处理单元）进行管理。
Kubernetes 实现了设备插件（Device Plugins） 以允许 Pod 访问类似 GPU 这类特殊的硬件功能特性。
作为集群管理员，你要在节点上安装来自对应硬件厂商的 GPU 驱动程序，并运行来自 GPU 厂商的对应的设备插件。
当以上条件满足时，Kubernetes 将暴露 amd.com/gpu 或 nvidia.com/gpu 为 可调度的资源。
异构设备的管理机制，得益于平台的机制，平台允许用户自定义资源名称，用户可以定义包括 RDMA、FPGA、AMD GPU 等等设备。
你可以通过请求 <vendor>.com/gpu 资源来使用 GPU 设备，就像你为 CPU 和内存所做的那样。
部署 AMD GPU 设备插件
官方的 AMD GPU 设备插件 有以下要求：
Kubernetes 节点必须预先安装 AMD GPU 的 Linux 驱动。
如果你的集群已经启动并且满足上述要求的话，可以这样部署 AMD 设备插件：
kubectl create -f https://raw.githubusercontent.com/RadeonOpenCompute/k8s-device-plugin/r1.10/k8s-ds-amdgpu-dp.yaml

## 部署 NVIDIA GPU 设备插件
官方的 NVIDIA GPU 设备插件 有以下要求:
Kubernetes 的节点必须预先安装了 NVIDIA 驱动
Kubernetes 的节点必须预先安装 nvidia-docker 2.0
Docker 的默认运行时必须设置为 nvidia-container-runtime，而不是 runc
NVIDIA 驱动版本 ~= 384.81
Kubernetes 版本 >= 1.10
准备 GPU 节点
具体参考 https://github.com/NVIDIA/k8s-device-plugin
