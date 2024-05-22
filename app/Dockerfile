FROM python:3.9
ARG arg_bv
ARG arg_mode
ENV build_version=$arg_bv
ENV mode=$arg_mode

RUN apt-get update \
    && apt-get install -y \
    apt-utils \
    build-essential \
    curl \
    git \
    nginx \
    supervisor \
    && pip install -U pip

WORKDIR /app
COPY . /app

RUN pip install -r /app/requirements.txt
RUN useradd nginx
RUN mv nginx.conf /etc/nginx
RUN mkdir /etc/uwsgi
RUN mv uwsgi.ini /etc/uwsgi
RUN mv supervisord.conf /etc

CMD ["/usr/bin/supervisord"]
