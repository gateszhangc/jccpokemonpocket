FROM nginx:1.27-alpine

WORKDIR /usr/share/nginx/html

COPY index.html /usr/share/nginx/html/index.html
COPY styles.css /usr/share/nginx/html/styles.css
COPY assets /usr/share/nginx/html/assets
COPY sitemap.xml /usr/share/nginx/html/sitemap.xml
COPY robots.txt /usr/share/nginx/html/robots.txt
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 3000
