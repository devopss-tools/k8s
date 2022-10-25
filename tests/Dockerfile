FROM github.com/devopss-tools/k8s-deployment:nginx-alpine
WORKDIR /var/www

RUN rm -fv /etc/nginx/dconf.d/*.conf
COPY k8s-deployment/tests/nginx.conf /etc/nginx/conf.d/default.conf

# Default port exposure
EXPOSE 8080

CMD ["nginx", "-g", "daemon off;"]
