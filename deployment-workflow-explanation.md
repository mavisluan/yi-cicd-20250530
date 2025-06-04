# GitHub Pages Deployment Workflow Explained

This document explains the GitHub Actions workflow used for deploying your React application to GitHub Pages using Docker.

## Workflow Overview

The workflow in `deploy.yml` uses Docker to build your application in a consistent environment, extracts the build artifacts, and deploys them to GitHub Pages. Below is a detailed explanation of each step in the process.

## Sequence Diagram Explanation

### Step 1: Checkout Repository Code
- **Trigger**: The workflow is initiated either by a push to the main branch or manually through the GitHub Actions UI
- **Action**: GitHub Actions checks out your repository code to make it available to the workflow
- **Purpose**: Makes your source code available to the build process

### Step 2: Set up Docker Buildx
- **Action**: Sets up Docker Buildx, an enhanced builder for Docker
- **Purpose**: Provides improved build capabilities compared to standard Docker build
- **Benefit**: Faster, more efficient builds with better caching

### Step 3: Build Docker Image
- **Action**: Uses `docker/build-push-action@v5` to build a Docker image according to your Dockerfile
- **Parameters**:
  - `context: .` - Uses the current directory as the build context
  - `push: false` - Does not push the image to any external registry
  - `load: true` - Loads the image into the local Docker daemon
  - `tags: my-react-app:latest` - Tags the image for identification
- **Process**: 
  - Docker builds the image layer by layer according to your Dockerfile
  - The image contains your application code, dependencies, and the built artifacts
- **Output**: A Docker image named `my-react-app:latest` in the local Docker daemon

### Step 4: Extract Build Artifacts
- **Process**: This step involves multiple commands to extract the build artifacts from the Docker image
  
  1. **Create Container**:
     - **Command**: `container_id=$(docker create my-react-app:latest)`
     - **Purpose**: Creates a container from the image without starting it
     - **Explanation**: A container is needed to access the filesystem of the image

  2. **Create Local Directory**:
     - **Command**: `mkdir -p dist`
     - **Purpose**: Creates a directory on the GitHub Actions runner to store the build files
     - **Explanation**: The `-p` flag ensures parent directories are created if needed and prevents errors if the directory already exists

  3. **Copy Build Artifacts**:
     - **Command**: `docker cp $container_id:/output/. ./dist/`
     - **Purpose**: Copies files from the container's `/output` directory to the local `dist` directory
     - **Explanation**: The build artifacts were placed in `/output` by the Dockerfile and now need to be accessible to GitHub Actions

  4. **Remove Container**:
     - **Command**: `docker rm $container_id`
     - **Purpose**: Removes the temporary container as it's no longer needed
     - **Explanation**: Good practice to clean up resources once they've served their purpose

### Step 5: Deploy to GitHub Pages
- **Action**: Uses `peaceiris/actions-gh-pages@v4` to deploy the build artifacts to GitHub Pages
- **Parameters**:
  - `github_token: ${{ secrets.GITHUB_TOKEN }}` - Authentication token automatically provided by GitHub
  - `publish_dir: ./dist` - The directory containing the files to deploy
- **Process**: 
  - Takes the files from the `dist` directory
  - Commits them to the `gh-pages` branch of your repository
  - GitHub Pages serves these files as a static website
- **Output**: Your application is deployed and accessible via your GitHub Pages URL (https://mavisluan.github.io/yi-cicd-20250530/)

## Key Benefits of This Approach

1. **Consistent Builds**: Docker ensures your application is built in the same environment every time
2. **Isolated Environment**: The build process runs in an isolated container, preventing dependency conflicts
3. **Reproducible**: Anyone can reproduce the exact same build by using the same Dockerfile
4. **Efficient**: Only the necessary build artifacts are deployed to GitHub Pages, not the entire Docker image
5. **Automated**: The entire process runs automatically on code changes or manual triggers

## Next Steps

- Monitor your deployments in the "Actions" tab of your GitHub repository
- Consider adding build caching to speed up the Docker build process
- Add status badges to your README.md to show deployment status
