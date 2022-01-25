FROM library/node:14-buster as stage1

ENV METEOR_ALLOW_SUPERUSER yes
RUN curl https://install.meteor.com/ | sh
ADD ./ /src
RUN cd /src && \
    meteor build --directory ./bundle/ && \
    mv ./bundle/bundle /app && \
    cd / && rm -rf /src


FROM library/node:14-slim as stage2
COPY --from=stage1 /app /app
RUN ls /app && cd /app/programs/server/ && npm install && rm -rf /root/.meteor/

WORKDIR /app/

ENV PORT=80
CMD export MONGO_URL=$MONGODB_URL && node main.js
EXPOSE 80 10304
