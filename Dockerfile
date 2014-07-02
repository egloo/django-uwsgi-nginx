# Copyright 2013 Thatcher Peskens
# Copyright 2014 George Cooper (modifications)
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

FROM ubuntu:14.04

MAINTAINER eGloo

# RUN echo "deb http://archive.ubuntu.com/ubuntu trusty main universe" > /etc/apt/sources.list

# RUN echo "deb http://security.ubuntu.com/ubuntu trusty-security main restricted" >> /etc/apt/sources.list
# RUN echo "deb-src http://security.ubuntu.com/ubuntu trusty-security main restricted" >> /etc/apt/sources.list
# RUN echo "deb http://security.ubuntu.com/ubuntu trusty-security universe" >> /etc/apt/sources.list
# RUN echo "deb-src http://security.ubuntu.com/ubuntu trusty-security universe" >> /etc/apt/sources.list
# RUN echo "deb http://security.ubuntu.com/ubuntu trusty-security multiverse" >> /etc/apt/sources.list
# RUN echo "deb-src http://security.ubuntu.com/ubuntu trusty-security multiverse" >> /etc/apt/sources.list

RUN echo "deb ftp://10.10.14.248/ubuntu/ trusty main universe" > /etc/apt/sources.list

RUN echo "deb ftp://10.10.14.248/ubuntu/ trusty-security main restricted" >> /etc/apt/sources.list
RUN echo "deb-src ftp://10.10.14.248/ubuntu/ trusty-security main restricted" >> /etc/apt/sources.list
RUN echo "deb ftp://10.10.14.248/ubuntu/ trusty-security universe" >> /etc/apt/sources.list
RUN echo "deb-src ftp://10.10.14.248/ubuntu/ trusty-security universe" >> /etc/apt/sources.list
RUN echo "deb ftp://10.10.14.248/ubuntu/ trusty-security multiverse" >> /etc/apt/sources.list
RUN echo "deb-src ftp://10.10.14.248/ubuntu/ trusty-security multiverse" >> /etc/apt/sources.list


RUN apt-get update
RUN apt-get -y upgrade
RUN apt-get install -y build-essential git
RUN apt-get install -y python-software-properties software-properties-common
RUN apt-get install -y python python-dev python-setuptools
RUN apt-get install -y nginx supervisor
RUN easy_install pip

# install uwsgi now because it takes a little while
RUN pip install uwsgi

# install nginx
RUN apt-get install -y python-software-properties
RUN apt-get update
RUN add-apt-repository -y ppa:nginx/stable
RUN apt-get install -y sqlite3

RUN apt-get install -y postgresql-client-9.3 postgresql-contrib-9.3 libpq-dev libssl-dev
RUN apt-get install -y python-psycopg2

# install our code
ADD . /home/docker/code/

# setup all the configfiles
RUN echo "daemon off;" >> /etc/nginx/nginx.conf
RUN rm /etc/nginx/sites-enabled/default
RUN ln -s /home/docker/code/nginx-app.conf /etc/nginx/sites-enabled/
RUN ln -s /home/docker/code/supervisor-app.conf /etc/supervisor/conf.d/

# RUN pip install
RUN pip install -r /home/docker/code/app/requirements.txt

RUN pip install djangorestframework
RUN pip install markdown       # Markdown support for the browsable API.
RUN pip install django-filter  # Filtering support

# install django, normally you would remove this step because your project would already
# be installed in the code/app/ directory
# RUN django-admin.py startproject tutorials /home/docker/code/app/

# RUN cd /home/docker/code/app/ && python ./manage.py startapp quickstart

# RUN python /home/docker/code/app/manage.py runserver

# Just initial run!
# RUN cd /home/docker/code/app && echo "yes" | python ./manage.py syncdb

RUN cd /home/docker/code/app && echo "yes" | python ./manage.py collectstatic

expose 80
expose 8000

# cmd ["/bin/sh"]

cmd ["supervisord", "-n"]
