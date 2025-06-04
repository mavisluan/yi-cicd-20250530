FROM oven/bun:latest

WORKDIR /app

COPY package.json bun.lock ./
RUN bun install

COPY . .
RUN bun run build

# Create an output directory and copy the build artifacts
RUN mkdir -p /output && cp -r dist/* /output/

# Just to keep the container running if needed for docker cp
CMD ["tail", "-f", "/dev/null"]
