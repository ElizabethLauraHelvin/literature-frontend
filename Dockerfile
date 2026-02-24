FROM node:18-alpine

WORKDIR /apps

COPY package*.json ./
RUN npm install

COPY . .

RUN npm install pm2 -g

ENV NODE_OPTIONS=--openssl-legacy-provider

EXPOSE 3000

CMD ["pm2-runtime", "ecosystem.config.js"]
