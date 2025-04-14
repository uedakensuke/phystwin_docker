FROM nvidia/cuda:12.1.1-devel-ubuntu22.04
# hostマシンのNVIDIAドライバは535以上を使用すること。
# NVIDIAドライバが古い場合、torch.cuda.is_available()がエラーになる

ARG USER
ARG UID
ARG GID
ARG ENV_NAME=phystwin
ARG OPT_DIR=/home/$USER/opt

# condaが.bashrcを使用するので-iをつける
SHELL ["/bin/bash", "-i", "-c"]

# userの作成
RUN groupadd -g $GID $USER && \
    useradd -m -s /bin/bash -u $UID -g $GID $USER

RUN apt update \
 && apt install -y --no-install-recommends \
    sudo \
    wget \
    nano \
    x11-apps \
    git

# ユーザー切り替え
USER $USER
RUN mkdir $OPT_DIR

WORKDIR $OPT_DIR

# condaのインストール
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
    sh Miniconda3-latest-Linux-x86_64.sh -b -p ./miniconda3 && \
    rm -r Miniconda3-latest-Linux-x86_64.sh
ENV PATH $OPT_DIR/miniconda3/bin:$PATH

RUN conda update -n base -c defaults conda && \
    conda create -y -n ${ENV_NAME} python=3.10 && \
    conda init bash && \
    /bin/bash -c "echo 'conda activate ${ENV_NAME}' >> /home/$USER/.bashrc" && \
    source /home/$USER/.bashrc

########################### phystwinの依存ライブラリの導入

##############################################################
# pythonのversion変更が必要（pytorch3dのprebuildバイナリが3.10を要求する為）
# conda環境を使用して導入する
##############################################################

# numpy2系に対応していないライブラリが多いので
RUN conda install -y "numpy==1.26.4"

# pytorchの導入
RUN conda install -y pytorch==2.4.0 torchvision==0.19.0 torchaudio==2.4.0 pytorch-cuda=12.1 -c pytorch -c nvidia

# Install the packages
# If you only want to explore the interactive playground, you can skip installing Trellis, Grounding-SAM-2, RealSense, and SDXL.
RUN pip install warp-lang
RUN pip install usd-core matplotlib
RUN pip install "pyglet<2"
RUN pip install open3d
RUN pip install trimesh
RUN pip install rtree 
RUN pip install pyrender

RUN pip install stannum
RUN pip install termcolor
RUN pip install fvcore
RUN pip install wandb
RUN pip install moviepy imageio
RUN conda install -y opencv
RUN pip install cma
RUN pip install --no-index --no-cache-dir pytorch3d -f https://dl.fbaipublicfiles.com/pytorch3d/packaging/wheels/py310_cu121_pyt240/download.html

# # Install the env for realsense camera
# pip install Cython
# pip install pyrealsense2
# pip install atomics
# pip install pynput

# Install the env for grounded-sam-2
RUN pip install git+https://github.com/IDEA-Research/Grounded-SAM-2.git
RUN pip install git+https://github.com/IDEA-Research/GroundingDINO.git

# Install the env for image upscaler using SDXL
RUN pip install diffusers
RUN pip install accelerate

########################## phystwinの初期化

# download phystwin
WORKDIR /home/$USER/
RUN git clone https://github.com/Jianghanxiao/PhysTwin.git

# Install the env for trellis
WORKDIR /home/$USER/PhysTwin/data_process
RUN git clone --recurse-submodules https://github.com/microsoft/TRELLIS.git
WORKDIR /home/$USER/PhysTwin/data_process/TRELLIS
RUN . ./setup.sh --basic --xformers --flash-attn --diffoctreerast --spconv --mipgaussian --kaolin --nvdiffrast

RUN pip install gsplat
RUN pip install kornia

WORKDIR /home/$USER/PhysTwin/gaussian_splatting

# diff-gaussian-rasterizationに必要な設定。使用するGPUに合わせて値を設定すること。RTX3060は8.6
ENV TORCH_CUDA_ARCH_LIST "8.6"

RUN pip install submodules/diff-gaussian-rasterization/
RUN pip install submodules/simple-knn/

WORKDIR /home/$USER/PhysTwin

# Download the necessary pretrained models for data processing
RUN bash env_install/download_pretrained_models.sh

# playgroundの動作に必要だった
RUN apt install -y \
    libgl1 \
    libglu1-mesa \
    libgl1-mesa-glx \
    libglib2.0-0
RUN pip install pynput einops
