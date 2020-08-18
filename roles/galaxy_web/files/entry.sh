#!/usr/bin/env sh
echo "set \$master_api_key '$master_api_key';" > /etc/nginx/master_api_key
nginx -g "daemon off;"