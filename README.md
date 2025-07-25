# phystwin

- このレポジトリでは、phystwinをdockerコンテナ上で動かせるようにしている。
  - dockerを動かすマシンは、ヘッドレス（ディスプレイがない）サーバでもよい（SSHで接続して使用する）
  - phystwinはコンテナ上で動作し、読み書きするデータはホスト上の下記ディレクトリを使用する
    - `(このレポジトリをcloneした場所)/mount/ws`

## 使い方

### 学習（最適化）の実行
1. 入力データを用意する。下記のいずれか。
  - `(このレポジトリをcloneした場所)/mount/ws/data`の位置に前処理済み入力データを配置する事
  - 方法１：公式の前処理済み入力データをダウンロードして使用する。
    - [data](https://drive.google.com/file/d/1A6X7X6yZFYJ8oo6Bd5LLn-RldeCKJw5Z/view?usp=sharing)
  - 方法２：自分で撮影した動画に前処理を行い入力データを生成する。
    - 後述の「動画の前処理」を実行して入力データを生成する
2. 入力データを処理して学習結果（最適化結果）を生成する
  - docker/optimize.shを実行する。
  ```
  cd docker
  optimize.sh ケース名
  ```

#### optimizeのステージを別々に実行したい場合

optimize.shでは下記を順番に実行している。個別に実行したい場合は下記の通り。
※physicsデータの生成とappearanceデータの生成は依存関係がなく独立に実行可能。

1. 入力データを処理して疎なphysicsデータを生成する。
  ```
  cd docker/main/script
  _optimize_physics_sparse.sh ケース名
  ```
2. 疎なphysicsデータを処理して密なphysicsデータを生成する。
  ```
  cd docker/main/script
  _optimize_physics_dense.sh ケース名
  ```
3. 入力データを処理してappearanceデータを生成する。
  ```
  cd docker/main/script
  _optimize_appearance.sh ケース名
  ```

#### optimizeで生成されるデータの場所

optimizeで生成される全てのデータは下記の場所にできる
- `(このレポジトリをcloneした場所)/mount/ws/**/*`

**のサブディレクトリ名称は下記表の通り

|最適化処理|サブディレクトリ名|
|--|--|
|optimize_physics_sparse|`experiments_optimization/ケース名`|
|optimize_physics_dense|`experiments/ケース名/train`|
|optimize_appearance|`gaussian_output/ケース名/実験名（固定）`|

### 学習結果（最適化結果）からの推論

下記が可能
- インタラクティブシミュレーション（UIで外力を与えられる）
    ```
    cd docker/main/script
    play.sh ケース名 力点の数（1 or 2）
    ```
- 既定条件でのシミュレーション
    ```
    cd docker/main/script
    inference.sh ケース名
    ```

#### inferenceのステージを別々に実行したい場合

inference.shでは下記を順番に実行している。個別に実行したい場合は下記の通り。

1. physicsデータに基づくレンダリング
  ```
  cd docker/main/script
  _inference_physics_dense.sh ケース名
  ```
2. appearanceデータに基づくレンダリング
  ```
  cd docker/main/script
  _inference_appearance.sh ケース名
  ```
3. physicsデータとappearanceデータに基づくレンダリング。
  - 先に_inference_physics_denseを実行しておく必要がある。
  ```
  cd docker/main/script
  _inference_dynamic.sh ケース名
  ```
4. physicsデータとappearanceデータに基づくレンダリング。
  ```
  cd docker/main/script
  _visualize_force.sh ケース名
  ```
5. physicsデータとappearanceデータに基づくレンダリング。
  ```
  cd docker/main/script
  _visualize_material.sh ケース名
  ```

#### inferenceで生成されるデータの場所

inferenceで生成される全てのデータは下記の場所にできる
- `(このレポジトリをcloneした場所)/mount/ws/render/**/*`

**のサブディレクトリ名称は下記表の通り

|推論処理|サブディレクトリ名|
|--|--|
|inference_physics_dense|`ケース名/physics`|
|inference_appearance|`ケース名/appearance`|
|inference_dynamic|`ケース名/dynamic`|
|visualize_force|`ケース名/force`|
|visualize_material|`ケース名/material`|

### シミュレーション結果の評価

- 評価
    - 既定条件でのシミュレーションを実行してから実行する必要がある
    ```
    cd docker/main/script
    eval.sh ケース名
    ```

#### evalで生成されるデータの場所

evalで生成される全てのデータは下記の場所にできる
- `(このレポジトリをcloneした場所)/mount/ws/**/*`


|評価処理|データ生成場所|
|--|--|
|export_render_eval_data|`eval/ケース名/render_eval_data`|
|visualize_render_results|`render/ケース名/dynamic`|
|evaluate|`eval/ケース名/results`|

## 動画の前処理

動画ファイルから、前処理済み入力データを作成するには少なくとも下記の環境が必要
- GPU メモリ16GB以上（※TRELLISの動作条件）


動画ファイルから、前処理済み入力データを作成するには下記を実行する
1. 動画データの用意
  - `(このレポジトリをcloneした場所)/mount/ws/raw/ケース名`の位置に動画データを配置する事
  - 必要なファイルは下記
    - `color/{カメラ番号（0 or 1 or 2）}.mp4`
      - カメラのカラー動画
    - `color/{カメラ番号（0 or 1 or 2）}/{frame番号}.png`
      - カメラのカラー画像
    - `depth/{カメラ番号（0 or 1 or 2）}/{frame番号}.npy`
      - カメラの深度画像
    - data_config.csv
      - 「GroundingDINOを実行する時のテキストプロンプト」及び「shape_priorを作成するかのフラグ」
      - ファイル例:
        ```
        sloth,True
        ```
    - metadata.json
      - カメラの内部パラメータ
    - calibrate.pkl
      - カメラの外部パラメータ
2. 前処理の実行
    ```
    cd docker/process_data/script
    process_data.sh ケース名
    ```

### process_dataの処理ステップ

下記の順序で実行される。
★はdata_config.csvにおいてshape_priorがTrueになっている場合のみ実行する。

1. Video Segmentation
  - 使用ソフトウェア
    - GroundedSAM2(GroundingDINO+SAM2)
  - 使用データ
    - カメラのカラー動画：`{camera_idx}.mp4`
  - 生成
    - マスク画像： `{cemera_idx}/{obj\idx}/{frame_idx}.png`
    - オブジェクト辞書： `mask_info_{cemera_idx}.json`
  - 後続処理は、ここでオブジェクトが下記の個数検出されることを前提としている
    - ハンドが１～２個
    - 操作対象物１個
2. Dense Tracking
  - 使用ソフトウェア
    - CoTracker3(torch hubを通して利用) 
  - 使用データ
    - カメラのカラー動画：`{camera_idx}.mp4`
    - フレーム0のマスク画像：`{camera_idx}/{obj_idx}/0.png`
  - 生成
    - 対象物&ハンドのトラッキング結果： `{camera_idx}.npz`
    - （確認用）対象物&ハンドのトラッキング動画： `{camera_idx}.mp4`
3. Lift to 3D
  - 使用データ
    - カラー画像：`{camera_idx}/{frame_idx}.png`
    - 対象物のマスク画像：`{camera_idx}/{対象物のobj_idx}/{frame_idx}.png`
  - 生成
    - 全カメラ統合対象物点群：`{frame_idx}.npz`
4. Mask Post-Processing
  - 使用データ
    - 全カメラ統合対象物点群：`{frame_idx}.npz`
    - マスク画像：`{camera_idx}/{obj_idx}/{frame_idx}.png`
    - オブジェクト辞書：`mask_info_{cemera_idx}.json`
  - 生成
    - 全カメラ統合対象物点群に対するマスク：`processed_masks.pkl`
5. Data Tracking
  - 使用データ
    - 全カメラ統合対象物点群：`{frame_idx}.npz`
    - 全カメラ統合対象物点群に対するマスク：`processed_masks.pkl`
    - 対象物&ハンドのトラッキング結果： `{camera_idx}.npz`
  - 生成
    - トラッキングデータ：`track_process_data.pkl`
6. (★)1視点からの3Dモデル予測
  - 下記の処理を順に行う
    1. Image Upscale
      - 使用ソフトウェア
        - Stable Diffusion XL
      - 使用データ
        - カメラ0のフレーム0のカラー画像：`0/0.png`
        - カメラ0のフレーム0の対象物のマスク画像：`0/{対象物のobj_idx}/0.png`
      - 生成
        - 対象物クロップ高解像度画像： `high_resolution.png`
    2. Image Segmentation
      - 使用ソフトウェア
        - GroundedSAM2(GroundingDINO+SAM2)
      - 使用データ
        - 対象物クロップ高解像度画像：`high_resolution.png`
      - 生成
        - 対象物クロップ高解像セグメンテーション画像： `masked_image.png`
    3. Shape Prior Generation
      - 使用ソフトウェア
        - TRELLIS（GPU メモリ16GB以上）
      - 使用データ
        - 対象物クロップ高解像度セグメンテーション画像`masked_image.png`
      - 生成
        - 対象物モデル glb形式： `object.glb`
        - （確認用）対象物モデル ply形式： `object.ply`
        - （確認用）対象物可視化動画： `visualization.mp4`
7. (★)Alignment
  - 使用ソフトウェア
    - pytorch3d
  - 使用データ
    - 対象物モデル glb形式： `object.glb`
    - フレーム0のカラー画像：`{camera_idx}/0.png`
    - フレーム0の対象物のマスク画像：`{camera_idx}/{対象物のobj_idx}/0.png`
    - 全カメラ統合対象物点群：`{frame_idx}.npz`
    - 全カメラ統合対象物点群に対するマスク：`processed_masks.pkl`
  - 生成
    - アライン済み対象物モデル glb形式：`final_mesh.glb`
    - (中間ファイル)マッチング結果：`best_match.pkl`
    - （確認用）：`mesh_matching.png`
    - （確認用）：`render_matching.png`
    - （確認用）：`raw_matching.png`
    - （確認用）：`pnp_results.png`
    - （確認用）：`raw_matching_valid.png`
    - （確認用）：`final_matching.mp4`
8. Final Data Generation
  - 使用データ
    - shape priorを使用しない場合
      - トラッキングデータ：`track_process_data.pkl`
    - shape priorを使用する場合
      - アライン済み対象物モデル glb形式：`final_mesh.glb`
      - トラッキングデータ：`track_process_data.pkl`
  - 生成
    - 前処理済みデータ：`final_data.pkl`
    - （確認用）対象物&ハンドの点群のトラッキング動画：`final_data.mp4`
    - （確認用）対象物の点群の360度動画：`final_pcd.mp4`


- `final_data.pkl`は下記辞書が保存されている
  ```
  {
      "object_points":TBD,
      "object_colors":TBD,
      "object_visibilities":TBD,
      "object_motions_valid":TBD,
      "controller_points":TBD,
      "surface_points":TBD,
      "interior_points":TBD,
  }
  ```

#### process_dataで生成されるデータの場所

process_dataで生成される全てのデータは下記の場所にできる
- `(このレポジトリをcloneした場所)/mount/ws/data/different_types/**/*`

**のサブディレクトリ名称は下記表の通り

|前処理|サブディレクトリ名|
|--|--|
|Video Segmentation|`ケース名/mask`|
|Dense Tracking|`ケース名/cotracker`|
|Lift to 3D|`ケース名/pcd`|
|Mask Post-Processing|`ケース名/mask`|
|Data Tracking|`ケース名`|
|1視点からの3Dモデル予測|`ケース名/shape`|
|Alignment|`ケース名/shape/matching`|
|Final Data Generation|``|

#### (未対応事項)

- export_gaussian_data.py
```
# Further get the data for first-frame Gaussian
python export_gaussian_data.py
```
これが前処理で必要。できてないとoptimize_appearanceができない

- export_video_human_mask
```
# Get human mask data for visualization and rendering evaluation
python export_video_human_mask.py
```


## 処理時間とGPUメモリ使用量

RTX 3060 12G環境で確認

- optimize処理
|case|optimize_physics_sparse|optimize_physics_dense(200iter)|optimize_appearance|
|--|--|--|--|
|double_lift_sloth|13min/0.9G|30min/0.9G|4min/0.9G|
|double_stretch_sloth|30min/1.5G|75min/0.9G|5min/1.5G|

- inference処理
|case|inference_physics_dense|inference_appearance|inference_dynamic|
|--|--|--|--|
|double_lift_sloth|1min/0.9G|0min/1.1G|1min/8.4G|
|double_stretch_sloth|9min/0.9G|||

## phystwin実装の参考情報

- 入力データ（dataディレクトリ）
    - optimize処理で使用（必須）
        - `final_data.pkl`
        - カメラ外部パラメータ：`calibrate.pkl`
        - カメラ内部パラメータ：`metadata.json`
    - optimize処理で使用（任意）
        - color/配下の各カメラのフレーム
            - 疎なphysicsデータ生成処理でoptimizeCMA/init.mp4を生成する時に使用する。
            - 密なphysicsデータ生成処理でinference.mp4を生成する時に使用する。
- 疎なphysicsデータ（experiment_optimizationフォルダ）
    - optimize処理で使用（必須）
        - optimal_params.pkl
            - 密なphysicsデータ生成処理で使用
    - 確認用
        - *.mp4, *.log

## 環境構築参考情報
このレポジトリでは、phystwinをSSHで接続するリモートマシンのdocker上で動かせるように下記の仕組みを利用している

- phystwinのoptiaizeとtrainはGPUを使用したOpenGL環境を要求する（CPUでのソフトウェアレンダリング不可？）のでセットアップに注意が必要
    - optimizeとtrainの実装中で結果確認用の動画を吐き出しているのが原因の様子。
    - qqtt/utils/visualize.pyの実装部分
    - visualizeをOFFにすればGPUでのOpenGL環境は不要になるかもしれないが未確認

### リモートGPUを利用した描画

- docker未使用の場合におけるリモートGPUを利用した描画
    - NVidia GPUのあるUbuntuマシンにリモートSSH接続し、OpenGLアプリでリモートのGPUを使用する方法。
        - x11転送やturboVNCだけだと描画はCPUで行われてしまう。
        - 下記のいずれかでできるがVNC(turboVNC)を推奨
        1. VNC+VirtualGL
        2. x11転送+VirtualGL

    - 事前設定
        - VirtualGLをインストール
            - ホスト側でvglrunコマンドが使えるようにする
            - `sudo /opt/VirtualGL/bin/vglserver_config`も実行しておくこと
              - 実行結果でエラーがでてないかよく確認すること。下記エラーなど。
                ```
                modprobe: FATAL: Module nvidia_uvm is in use.
                ```
              - 設定後Xを再起動すること
        - Ubuntuマシン上でXorgが起動している状態にする
            - ホスト側でnvidia-smiコマンドを実行した時に「/usr/lib/xorg/Xorg」が存在すること
            - 存在しない場合は、下記で起動
            ```bash
            1. 設定ファイル作成
            sudo nvidia-xconfig --enable-all-gpus --allow-empty-initial-configuration --virtual=1920x1080

            2. Xorgが起動していない場合はDISPLAY=:0でバックグランド起動する（なお、ディスプレイマネージャーは不要でXorgだけあればOK。startxする必要はない。）
            sudo X :0 &
            ```
    - 確認
        - 下記コマンドを実行してGPU名が表示されればOK
        ```bash
        vglrun -d :0 glxinfo|grep "OpenGL renderer"    
        ```
    - 使い方
        - GPU上で動かしたいアプリを下記のように起動
        ```bash
        vglrun -d :0 glmark2    
        ```
- さらにリモートマシン上でdockerコンテナを動かし、dockerコンテナ中でOpenGLを使用するアプリを使用する場合にはさらに設定が必要になる。
    - コンテナ作成時には下記オプションが必要
        - --net host
        - x11転送を使用する場合は必須。これは、x11転送用のxhost（sshクライアント側、windows上でxLaunch等）がsshサーバマシン以外のIPアドレスからのアクセスを許可していない為。
        - turboVNCを使用する場合は、turboVNCを起動している環境上でxhostの設定を緩めれば--net hostとする必要はない。
        - -e NVIDIA_DRIVER_CAPABILITIES=all
    - 必要なかった設定
        - コンテナ作成時に　--device /dev/dri　は不要
        - ホスト上でvglclientの起動は不要
        - Xdummyは不要。普通のXで設定ファイルをnvidia-xconfigで生成すれば大丈夫だった。

#### 描画性能測定

glmark2を使用して測定
- リモート：RTX3060

1. ローカル回線80Mbps(fast.com)
    |条件|glmark2スコア|
    |--|--|
    |turboVNC+VirtualGL|2608|
    |turboVNC|1563|
    |x11+VirtualGL|7|
    |x11|2|
2. ローカル回線220Mbps(fast.com)
    |条件|glmark2スコア|
    |--|--|
    |turboVNC+VirtualGL|2578|
    |turboVNC|1477|
    |x11+VirtualGL|15|
    |x11|9|

- x11は負荷が高い描画をする時にとても遅い、かつ回線速度の影響を強く受ける。VirtualGLすると改善するがそれでも遅い。
- turboVNCは回線速度の影響なく速い。turboVNCするとさらに速くなる。

#### トラブルシューティング

コンテナ上で下記を実行してエラーがでる場合の対処方法
```
vglrun -d :0 glxgears
```

1. VGL client接続エラー
    ```
    [VGL] ERROR: Could not connect to VGL client.  Make sure that vglclient is
    [VGL]    running and that either the DISPLAY or VGL_CLIENT environment
    [VGL]    variable points to the machine on which vglclient is running.
    ```
    - 出力先のDISPLAYの設定がおかしくない確認。
    - SSHで接続している場合、DISPLAYがlocalhost:10となっている場合あるが、vglrunする場合はDISPLAY=:10のようにする必要がある。
        ```
        DISPLAY=:10 vglrun -d :0 glxgears
        ```
2. libGL error
    ```
    libGL error: glx: failed to create dri3 screen
    ```
    - コンテナを起動するときに下記オプションつけているか確認
        - -e NVIDIA_DRIVER_CAPABILITIES=all
3. 認証エラー(x11転送時の手元PC側ディスプレイ. 例:10)
    ```
    X11 connection rejected because of wrong authentication.
    ```
    - xhostやxauthの設定を疑うこと。
        - コンテナ作成時に--net hostをつけるか、xhostの設定を適切におこなうことでコンテナ内からXserverにアクセスできるようにすること。
        - コンテナ起動時にマウントで下記のいずれかでxauthの設定を引き継ぐこと。
          - コンテナ内でrootを使用する場合：--volume=/home/$USER/.Xauthority:/root/.Xauthority
          - コンテナ内でユーザを使用する場合：--volume=/home/$USER/.Xauthority:/home/$USER/.Xauthority
    - ホスト上でvglrunできるのに、コンテナ上でこのエラーが出る場合、xauthのクッキーがホスト内とコンテナ内で異なっていることを疑うこと
      - `/home/${USER}/.Xauthority`をマウントしているのに異なっていた場合、再度dockerを軌道しなおすと治る

4. 認証エラー(x11転送時のホスト側仮想ディスプレイ側. 例:0)
    ```
    Invalid MIT-MAGIC-COOKIE-1 key[VGL] ERROR: Could not open display :0.
    ```
    - 下記をリモートホストで実行してx11転送時の手元PC側ディスプレイ(例:10)のcookieを調べる
    ```
    xauth list :10
    ```
    - 下記をリモートホストで実行してcookieを想ディスプレイ側（例:0）にも設定する
    ```
    xauth add :0 MIT-MAGIC-COOKIE-1 {xauth listで表示されたcookie}
    ```
