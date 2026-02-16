#!/bin/bash

source source.sh
export COCOTEX_SRC=$(dirname $(readlink -f $0))
export CUR_PWD=`pwd`
cd $COCOTEX_SRC/lib/ruby

bundle config --local without development
bundle config set --local frozen 'true'
bundle check > /dev/null || bundle install
bundle exec ruby frontend.rb $*
