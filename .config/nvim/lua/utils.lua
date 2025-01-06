local M = {}

-- Get the running container for dynamic lsp handling
function M.get_container_name()
  local container_column_display = ".Image"
  local handler =  io.popen('docker ps --format "{{' .. container_column_display .. '}}" | grep -v "_db"')
  local container = handler:read()
  handler:close()

  return container
end

function M.get_docker_service_ips()
  local handle = io.popen("docker ps -q | xargs -n 1 docker inspect --format '{{ .Name }} {{range .NetworkSettings.Networks}} {{.IPAddress}}{{end}}' | sed 's#^/##';")
  local service_ip_str = handle:read("*a")
  handle:close()
  local res = {}
  for line in service_ip_str:gmatch("[^\r\n]+") do
    local service_ip = {}
    for w in line:gmatch("%S+") do
      service_ip[#service_ip + 1] = w
    end
    res[service_ip[1]] = service_ip[2]
  end
  return res
end

return M
