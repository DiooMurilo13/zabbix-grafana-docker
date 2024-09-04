
#!/bin/bash

# Espera o Grafana estar pronto
sleep 60

# Define as variáveis
if [ -f .env ]; then
  export $(grep -v '^#' .env | xargs)
fi


# Gera o token de API
TOKEN=$(curl -s -X POST "$DEFAULT_URL:$GRAFANA_PORT/api/auth/keys" \
  -H "Content-Type: application/json" \
  -d '{"name": "api_key", "role": "Admin"}' \
  -u "$ADMIN_USER:$ADMIN_PASSWORD" | jq -r '.key')

# Verifica se o token foi obtido corretamente
if [ -z "$TOKEN" ]; then
  echo "Falha ao obter o token de API."
  exit 1
fi

echo "API Token: $TOKEN"


curl -s -X POST "$DEFAULT_URL:$GRAFANA_PORT/api/plugins/alexanderzobnin-zabbix-app/settings" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d '{"enabled": true}'


# Configura o datasource do plugin Zabbix
curl -X POST "$DEFAULT_URL:$GRAFANA_PORT/api/datasources" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d "{
        \"name\": \"Zabbix\",
        \"type\": \"alexanderzobnin-zabbix-datasource\",
        \"access\": \"proxy\",
        \"url\": \"$DEFAULT_URL/api_jsonrpc.php\",
        \"jsonData\": {
          \"server\": \"$DEFAULT_URL\",
          \"username\": \"admin\",
          \"password\": \"zabbix\"
        }
      }"

echo "Datasource for Zabbix has been created."

# valida se ta tudo ok
curl -X GET "$DEFAULT_URL:$GRAFANA_PORT/api/datasources/ID" \
  -H "Authorization: Bearer $TOKEN"
