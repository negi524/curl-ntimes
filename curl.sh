#!/bin/bash

set -eu

# リクエストする間隔
INTERVAL_SEC=2

# $1: リクエストするURL
# $2: リクエストする回数
# $3: リクエストする間隔
function main() {
  local url=$1
  local times=$2
  local interval_sec=$3

  echo "interval: ${interval_sec} sec"

  for i in $(seq 1 ${times})
  do
    echo "${i}: ${url}"
    curl -XGET ${url} > result-${i}.json
    sleep ${interval_sec}
  done
}

# オプションの処理を行う

# リクエスト回数のデフォルト値
n_times=1

while getopts "n:" option
do
  case ${option} in
    n)
      n_times=${OPTARG}
      ;;
    \?)
      echo "Usage: curl.sh [-n request_tmes] target_url" 1>&2
      exit 1
      ;;
  esac
done

# オプション位指定を一パラメータから削除する
shift $(expr ${OPTIND} - 1)

# urlを変数に格納する
url=$1

main ${url} ${n_times} ${INTERVAL_SEC}

exit 0
