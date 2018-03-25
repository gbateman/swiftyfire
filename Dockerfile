FROM node:carbon

WORKDIR /usr/src/app
COPY package*.json ./
RUN npm install
COPY . .
COPY swift/SwiftyFire/linux-SwiftyFire /swift/SwiftyFire/linux-SwiftyFire
COPY swift/SwiftyFire/linux-libs/ /swift/SwiftyFire/linux-libs/*

EXPOSE 8080

CMD ["npm", "start"]
