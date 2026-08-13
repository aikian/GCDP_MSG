FROM nginx:1.27-alpine

LABEL org.opencontainers.image.title="GCDP Heat Risk Alert — MSG Demo"
LABEL org.opencontainers.image.source="https://github.com/aikian/GCDP_MSG"

RUN rm -f /etc/nginx/conf.d/default.conf
COPY nginx.conf /etc/nginx/conf.d/default.conf

COPY index.html          /usr/share/nginx/html/index.html
COPY manifest.json       /usr/share/nginx/html/manifest.json
COPY icon.svg            /usr/share/nginx/html/icon.svg
COPY icon-maskable.svg   /usr/share/nginx/html/icon-maskable.svg

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget -qO- http://127.0.0.1/health || exit 1

CMD ["nginx", "-g", "daemon off;"]
