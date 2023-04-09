FROM ruby:3.0.6-alpine

RUN apk update
RUN apk add build-base git --virtual build-dependencies

RUN mkdir /stack_trace
WORKDIR /stack_trace

ENV BUNDLE_PATH=/bundle \
    BUNDLE_BIN=/bundle/bin \
    GEM_HOME=/bundle
ENV PATH="${BUNDLE_BIN}:${PATH}"

COPY . ./

RUN gem install bundler
RUN bundle install --jobs 20 --retry 5
