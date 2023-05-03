FROM ubuntu:22.04
RUN apt-get update
RUN apt-get install nginx -y
EXPOSE 80/tcp
CMD ["/usr/sbin/nginx", "-g", "daemon off;"]