FROM mcr.microsoft.com/devcontainers/javascript-node:22

# setup the location of the Scratch code
WORKDIR /usr/app
RUN chown node:node /usr/app

# switch to the Scratch developer user account
USER node

# get the base Scratch code
RUN git clone --depth=1 https://github.com/scratchfoundation/scratch-editor.git

# build Scratch
WORKDIR /usr/app/scratch-editor
RUN npm install

# location of the Scratch source code
ENV SCRATCH_SRC_HOME=/usr/app/scratch-editor

# copy extension development files
WORKDIR /usr/app
COPY 2-build.sh .
COPY 3-run-private.sh .

# initial default build
RUN ./2-build.sh
