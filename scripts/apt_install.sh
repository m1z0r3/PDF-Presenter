export APT_CACHE_DIR=`pwd`/vendor/apt && mkdir -pv $APT_CACHE_DIR

apt-get update -yqqq \
  && apt-get -o dir::cache::archives="$APT_CACHE_DIR" install -yqqq --no-install-recommends \
    nodejs \
  && rm -rf /var/lib/apt/lists/*
