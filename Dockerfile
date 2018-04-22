FROM elixir:1.6.4-alpine

# force install hex locally (used to install deps)
RUN mix local.hex --force

WORKDIR /opt/app
COPY . /opt/app

# install deps
RUN mix deps.get

CMD ["mix", "run"]