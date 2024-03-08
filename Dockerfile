# Stage 1: Node.js stage for npm dependencies and potential build processes
FROM node:18 AS node-base
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .

# Stage 2: Foundry stage to include Foundry in the final image
FROM ghcr.io/foundry-rs/foundry as foundry-base
# Copy over the node modules and build artifacts from the Node.js stage
COPY --from=node-base /app /ozel-vn/contracts
WORKDIR /ozel-vn/contracts

# Now, your final image has both Foundry and the npm dependencies installed
COPY start.sh /ozel-vn/contracts/start.sh
CMD ["/ozel-vn/contracts/start.sh"]

