FROM node:20-alpine AS builder

WORKDIR /app

# Copy package files
COPY package*.json ./
COPY web/package*.json ./web/

# Install dependencies
RUN npm install
RUN cd web && npm install

# Copy source code
COPY . .

# Build frontend
RUN cd web && npm run build

# Production stage
FROM node:20-alpine

WORKDIR /app

# Copy package files and install production dependencies
COPY package*.json ./
RUN npm install --production

# Copy built files
COPY --from=builder /app/web/dist ./web/dist
COPY --from=builder /app/server ./server
COPY --from=builder /app/prisma ./prisma

# Generate Prisma client
RUN npx prisma generate

EXPOSE 8080

CMD ["node", "server/index.js"]