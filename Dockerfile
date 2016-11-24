FROM node:0.10.42-wheezy
RUN apt-get update && apt-get install build-essential -y && apt-get clean
RUN curl https://install.meteor.com/ | sh

ADD . /build/
RUN cd /build && rm -rf /build/packages/npm-container/.npm/package && meteor build --directory /bundle/ && \
    rm -rf /build && mkdir /app/ && mv /bundle/bundle/* /app/ && rm -rf /bundle/ && \
    cd /app/programs/server/ && npm install && rm -rf /root/.meteor/

WORKDIR /app/

ENV PORT=80
CMD export MONGO_URL=$MONGODB_URL && node main.js
EXPOSE 80 10304
