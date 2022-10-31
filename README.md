# alpine xfce rdp

## 概要

X と RDP を利用できる最低限の環境を作成する。

### 解放ポート

- 3389 - Remote Desktop

### ログイン情報

- root
  - ログイン不可能
- 一般ユーザ
  - user / user (パスワードはビルド時 ARG - ARG_PASSWORD で指定可能)

## 詳細

### 環境について

- OS - alpine 3.16
- X - Xfce4
- RDP - xrdp

### ビルドコマンド

```sh
# デフォルトで作成
docker build -t alpine-xfce-rdp .

# パスワード指定
docker build -t alpine-xfce-rdp --build-arg ARG_PASSWORD=password .
```

#### その他のビルド時引数

1. ARG_TZ
   1. タイムゾーン指定（デフォルト値： `Asia/Tokyo` ）
2. ARG_USER 
   1. ログインユーザ（デフォルト値： `user` ）
3. ARG_PASSWORD
   1. ユーザパスワード（デフォルト値： `user` ）

### 実行コマンド

```sh
# 3389のバインド先は実行環境に合わせて設定すること
docker run -p 3389:3389 alpine-xfce-rdp:latest
```

### 設定

#### ./etc

- supervisord.conf
  - supervisor の起動設定を定義。
    - supervisorctl を使用しないため unix_http_server を削除。
    - /etc/supervisor.d の読み取りファイルを \*.conf に変更
    - .org ファイルは修正前の定義ファイル

#### ./etc/X11

root 以外のログインを許可する設定を追加したファイル。

#### ./etc/xrdp

sesman, xrdp の設定変更

- root ユーザのログイン不可能
- ログレベルの変更（INFO -> WARNING）

#### ./etc/supervisor.d

supervisor によって実行するアプリケーションの設定。
他のアプリケーションを実行したい場合は、本ディレクトリにファイルを追加することで設定が可能となる。

- 00-system.conf
  - udev, dbus 等、システム構成に必要なプロセス起動
- 01-rdp.conf
  - RDP 利用に必要な xrdp, sesman の実行を定義している

## License

[MIT](./LICENSE)

Copyright (c) 2022 BizLink Co.,Ltd.
