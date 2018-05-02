#! /bin/sh

set -e

is_comment() {
  case "$1" in
  \#*)
    return 0
    ;;
  esac

  return 1
}

is_env_key() {
  if [ -z "$1" ]; then
    return 0
  fi

  value=$(printenv "$1")
  if [ -n "$value" ]; then
    return 0
  fi

  return 1
}

copy_env() {
  if [ -z "$1" -o -z "$2" ]; then
    return 1
  fi

  value=$(printenv "$1")
  if [ -n "$value" ]; then
    eval export "$2='$value'";
  fi
}

load_env() {
  while IFS=$'= \t' read -r key tmp; do
    if is_comment "$key"; then
      continue
    fi

    if is_env_key "$key"; then
      continue
    fi

    value=$(eval echo "$tmp")
    eval export "$key='$value'";
  done < "$1"
}

# load $ENV_FILE
if [ -f "${ENV_FILE:=.env}" ]; then
  load_env "$ENV_FILE"
else
  echo "$ENV_FILE" not exist
fi

# then run command
if [ $# -gt 0 ]; then
  exec "$@"
fi
