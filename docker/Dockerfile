ARG BASE_REGISTRY=registry1.dso.mil
ARG BASE_IMAGE=ironbank/opensource/fluentd/fluentd
ARG BASE_TAG=1.12.1

FROM ${BASE_REGISTRY}/${BASE_IMAGE}:${BASE_TAG}

USER 0

COPY downloads/*.gem \ 
     /tmp/

COPY scripts/entrypoint.sh /fluentd/entrypoint.sh   

RUN gem install --force --local -N /tmp/*.gem && \
    rm -rf /tmp/*.gem /usr/lib/ruby/gems/*/cache/*.gem && \
    chmod a+rx /fluentd/entrypoint.sh && \
    find /usr/local/bundle/gems/fluentd-1.11.5/test/plugin_helper/data/cert/cert_chains -name "*.pem" | xargs rm -f && \
    mkdir /var/log/fluentd-buffers && \
    fix-permissions /var/log/fluentd-buffers 

EXPOSE 24224 5140

USER 1000

HEALTHCHECK CMD curl -I http://localhost:24224/api/plugins.json

ENTRYPOINT ["tini", "--", "/fluentd/entrypoint.sh"]

CMD ["fluentd"]
