FROM nginx:latest

RUN mkdir -p /usr/share/nginx/html/service

RUN mkdir -p /usr/share/nginx/html/api

COPY ./bastion.conf /etc/nginx/conf.d

COPY ./bastion.html /usr/share/nginx/html/service

COPY ./index.html /usr/share/nginx/html/api


