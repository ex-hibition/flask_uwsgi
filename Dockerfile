# 公式centos7イメージを利用 
FROM centos:7

## python設定
# IUSリポジトリ利用
RUN yum install -y https://centos7.iuscommunity.org/ius-release.rpm

# python36インストール
RUN yum install -y python36u python36u-devel python36u-libs python36u-pip

## oracle client設定
# oracleクライアント用ディレクトリを作成してコンテナにコピー
RUN mkdir -p /opt/oracle/
ADD oracle/instantclient-basic-linux.x64-12.2.0.1.0.zip /opt/oracle/
ADD oracle/instantclient-sdk-linux.x64-12.2.0.1.0.zip /opt/oracle/

# unzip,libaio, supervisorインストール
RUN yum install -y unzip libaio make gcc supervisor pcre-devel

RUN unzip /opt/oracle/instantclient-basic-linux.x64-12.2.0.1.0.zip -d /opt/oracle/
RUN unzip /opt/oracle/instantclient-sdk-linux.x64-12.2.0.1.0.zip -d /opt/oracle/

RUN ln -s /opt/oracle/instantclient_12_2 /opt/oracle/instantclient
RUN ln -s /opt/oracle/instantclient/libclntsh.so.12.1 /opt/oracle/instantclient/libclntsh.so

ENV LD_LIBRARY_PATH=/opt/oracle/instantclient \
    ORACLE_HOME=/opt/oracle/instantclient

# アプリケーションディレクトリ作成
RUN mkdir -p /usr/local/app/routeapi/
ADD routeapi.py /usr/local/app/routeapi/
ADD requirements.txt /usr/local/app/routeapi/

# cx_Oracle, flask, uwsgiインストール
RUN pip3.6 install --upgrade pip
RUN pip3.6 install -r /usr/local/app/routeapi/requirements.txt

# nginxインストール
RUN yum install -y nginx

# 設定ファイルをコンテナにコピー
ADD uwsgi.conf /etc/nginx/conf.d/
ADD routeapi.ini /usr/local/app/routeapi/
ADD supervisord.conf /etc/supervisord.d/
RUN mkdir -p /var/log/uwsgi/

# 複数プロセス実行(uwsgi, nginx)
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.d/supervisord.conf"]
