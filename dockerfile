# ---- base ----
FROM node:20-alpine AS base
WORKDIR /app
COPY package*.json ./

# ---- deps ----
FROM base AS deps
RUN npm ci --omit=dev

# ---- build ----
FROM base AS build
RUN npm ci            
COPY tsconfig.json ./
COPY src ./src
RUN npm run build

# ---- runner ----
FROM node:20-alpine AS runner
WORKDIR /app
ENV NODE_ENV=production
COPY --from=deps /app/node_modules ./node_modules
COPY --from=build /app/dist ./dist
COPY package.json ./
EXPOSE 3000
CMD ["node", "dist/index.js"]
