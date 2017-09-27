# ==============================================================================
# Dockerfile
# ==============================================================================
FROM ruby:2.4
ENV LANG C.UTF-8

ENV APP_HOME /usr/local/pdf_presenter
WORKDIR $APP_HOME

# Install apt package
COPY scripts/apt_install.sh scripts/apt_install.sh
COPY vendor/apt vendor/apt
RUN /bin/sh scripts/apt_install.sh

ARG RAILS_ENV
ENV RAILS_ENV ${RAILS_ENV:-production}

# Install gems
WORKDIR $APP_HOME
COPY vendor/bundle vendor/bundle
COPY Gemfile Gemfile

# Prepare App
COPY . $APP_HOME
WORKDIR $APP_HOME

# Remove Cache
RUN rm -rf vendor/apt
