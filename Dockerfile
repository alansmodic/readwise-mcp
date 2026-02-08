FROM node:20-alpine

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install all dependencies (including dev for TypeScript build)
RUN npm ci

# Copy source and build
COPY tsconfig.json ./
COPY src ./src

# Build TypeScript and remove dev dependencies
RUN npm run build && npm prune --production

# Expose port (Railway/Smithery will set PORT env var)
EXPOSE 8081

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
  CMD node -e "require('http').get('http://localhost:' + (process.env.PORT || 8081) + '/health', (r) => { process.exit(r.statusCode === 200 ? 0 : 1) }).on('error', () => process.exit(1))"

# Run with SSE transport for hosted deployment
# PORT is set by Railway/Smithery automatically
CMD ["node", "dist/index.js", "--transport", "sse"]
