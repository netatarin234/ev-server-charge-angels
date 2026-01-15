FROM node:18.20.4 as builder

ARG build

WORKDIR /usr/builder

COPY package.json package-lock.json ./

RUN apt-get update && apt-get install -y git && rm -rf /var/lib/apt/lists/*

RUN npm set progress=false && npm config set depth 0 && npm cache clean --force

RUN rm -rf node_modules && npm install

COPY LICENSE NOTICE ./
COPY src ./src
COPY types ./types
COPY build ./build
COPY *.json ./
COPY docker/config-standalone.json ./src/assets/config.json
COPY webpack.config.js ./

RUN npm run build:${build}

FROM node:18.20.4

WORKDIR /usr/app
COPY --from=builder /usr/builder/node_modules ./node_modules
COPY --from=builder /usr/builder/dist ./dist

EXPOSE 80

COPY docker/bin/wait /wait
RUN chmod +x /wait

COPY docker/autoconfig.sh /autoconfig.sh
RUN chmod +x /autoconfig.sh

RUN npm install -g pm2

# For Profiler
RUN npm install -g clinic
RUN npm install -g autocannon

#CMD /autoconfig.sh && node -r source-map-support/register --stack-trace-limit=1024 dist/start.js
CMD /autoconfig.sh && pm2-runtime dist/start.js
