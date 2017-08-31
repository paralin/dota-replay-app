FROM node:0.10.42-wheezy

ENV METEOR_ALLOW_SUPERUSER yes
ADD ./bundle/bundle /app
RUN ls /app && cd /app/programs/server/ && npm install && rm -rf /root/.meteor/

WORKDIR /app/

ENV PORT=80
CMD export MONGO_URL=$MONGODB_URL && node main.js
EXPOSE 80 10304
