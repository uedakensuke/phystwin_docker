########################## baseステージのbuild ##########################
FROM nvidia/cuda:12.1.1-devel-ubuntu22.04 as base
# hostマシンのNVIDIAドライバは535以上を使用すること。
# NVIDIAドライバが古い場合、torch.cuda.is_available()がエラーになる

ARG USER
ARG UID
ARG GID
ARG ENV_NAME=phystwin-main
ARG OPT_DIR=/home/$USER/opt

# condaが.bashrcを使用するので-iをつける
SHELL ["/bin/bash", "-i", "-c"]

# userの作成
RUN groupadd -g $GID $USER && \
    useradd -m -s /bin/bash -u $UID -g $GID $USER


#### openGLのインストール
RUN apt update
RUN apt install -y \
    libx11-xcb1 \
    libxcb1 \
    libxcb-glx0 \
    libxcb-keysyms1 \
    libxcb-image0 \
    libxcb-shm0 \
    libxcb-icccm4 \
    libxcb-sync1 \
    libxcb-xfixes0 \
    libxcb-shape0 \
    libxcb-randr0 \
    libxcb-render-util0 \
    libxrender1 \
    libxkbcommon-x11-0 \
    libxext6 \
    libglu1-mesa \
    libgl1-mesa-glx \
    libglib2.0-0

#### その他ツールのインストール
RUN apt install -y --no-install-recommends \
    sudo \
    wget \
    nano \
    x11-apps \
    git

RUN apt install -y mesa-utils    

# ユーザー切り替え
USER $USER

# condaのインストール
# - pythonのversion変更が必要（pytorch3dのprebuildバイナリが3.10を要求する為）
# - conda環境を使用して導入する

RUN mkdir $OPT_DIR
WORKDIR $OPT_DIR
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
    sh Miniconda3-latest-Linux-x86_64.sh -b -p ./miniconda3 && \
    rm -r Miniconda3-latest-Linux-x86_64.sh
ENV PATH $OPT_DIR/miniconda3/bin:$PATH


RUN conda update -n base -c defaults conda && \
    conda create -y -n ${ENV_NAME} python=3.10 && \
    conda init bash && \
    /bin/bash -c "echo 'conda activate ${ENV_NAME}' >> /home/$USER/.bashrc" && \
    source /home/$USER/.bashrc

# #### virtualglのインストール
WORKDIR $OPT_DIR
USER $USER
RUN wget https://sourceforge.net/projects/virtualgl/files/3.1/virtualgl_3.1_amd64.deb/download -O virtualgl_3.1_amd64.deb
USER root
RUN apt install -y ./virtualgl_3.1_amd64.deb

# vglrunでpytorchのpythonを実行する際に下記が必要だった。
ENV LD_LIBRARY_PATH=/home/$USER/opt/miniconda3/envs/$ENV_NAME/lib/python3.10/site-packages/torch/lib:$LD_LIBRARY_PATH

########################## phystwin-commonステージのbuild ##########################
FROM base as phystwin-common

ARG USER

# condaが.bashrcを使用するので-iをつける
SHELL ["/bin/bash", "-i", "-c"]

# ユーザー切り替え
USER $USER

# numpy2系に対応していないライブラリが多いので
RUN conda install -y "numpy==1.26.4"

# pytorchの導入
RUN conda install -y pytorch==2.4.0 torchvision==0.19.0 torchaudio==2.4.0 pytorch-cuda=12.1 -c pytorch -c nvidia
# 使用するGPUに合わせて値を設定すること。RTX3060は8.6
ENV TORCH_CUDA_ARCH_LIST "8.6"

# Install the packages
RUN pip install open3d
RUN conda install -y opencv

# download temporal phystwin
WORKDIR /home/$USER
RUN git clone -b refactor2 https://github.com/uedakensuke/PhysTwin.git

########################## phystwin-mainステージのbuild ##########################
FROM phystwin-common as phystwin-main

ARG USER
ARG ENV_NAME=phystwin-main
ARG OPT_DIR=/home/$USER/opt
ARG PHYSTWIN_DIR=/home/$USER/PhysTwin

# condaが.bashrcを使用するので-iをつける
SHELL ["/bin/bash", "-i", "-c"]

# ユーザー切り替え
USER $USER

#### phystwinの依存ライブラリの導入
RUN pip install warp-lang
RUN pip install usd-core matplotlib
RUN pip install "pyglet<2"
RUN pip install trimesh
RUN pip install rtree 
RUN pip install pyrender

RUN pip install stannum
RUN pip install termcolor
RUN pip install fvcore
RUN pip install wandb
RUN pip install moviepy imageio
RUN pip install cma
RUN pip install --no-index --no-cache-dir pytorch3d -f https://dl.fbaipublicfiles.com/pytorch3d/packaging/wheels/py310_cu121_pyt240/download.html

#### phystwinの初期化

# playgroundの動作に必要だった
USER $USER
RUN pip install pynput einops

# gsplat 1.5だとPhysTwin/gaussian_splatting/gaussian_rendererの
# __init__.pyで定義されているrender_gsplatが失敗する
RUN pip install jaxtyping==0.3.1 rich==14.0.0 ninja==1.11.1.4 fsspec==2025.3.2
# RUN pip install git+https://github.com/nerfstudio-project/gsplat.git
RUN pip install gsplat==1.4.0+pt24cu121 --index-url https://docs.gsplat.studio/whl
RUN pip install kornia

WORKDIR $PHYSTWIN_DIR/gaussian_splatting

# RUN pip install submodules/diff-gaussian-rasterization/
# RUN pip install submodules/simple-knn/
