# 生成新的 UUID 并转换为小写
$new_machine_id = [guid]::NewGuid().ToString().ToLower()
$new_dev_device_id = [guid]::NewGuid().ToString().ToLower()
# 生成 64 字节的随机十六进制字符串
$new_mac_machine_id = -join ((1..64) | ForEach-Object { "{0:x}" -f (Get-Random -Max 16) })
$new_machine_id = -join ((1..64) | ForEach-Object { "{0:x}" -f (Get-Random -Max 16) })
 
# 定义文件路径
$machine_id_path = "C:\Users\12917\AppData\Roaming\Cursor\machineid"
$storage_json_path = "C:\Users\12917\AppData\Roaming\Cursor\User\globalStorage\storage.json"
 
# 备份原始文件
Copy-Item $machine_id_path "$machine_id_path.backup" -ErrorAction SilentlyContinue
Copy-Item $storage_json_path "$storage_json_path.backup" -ErrorAction SilentlyContinue
 
# 更新 machineid 文件
$new_machine_id | Out-File -FilePath $machine_id_path -Encoding UTF8 -NoNewline
 
# 读取并更新 storage.json 文件
$content = Get-Content $storage_json_path -Raw | ConvertFrom-Json
$content.'telemetry.devDeviceId' = $new_dev_device_id
$content.'telemetry.macMachineId' = $new_mac_machine_id
$content.'telemetry.machineId' = $new_machine_id
 
# 保存更新后的 storage.json 文件
$content | ConvertTo-Json -Depth 100 | Out-File $storage_json_path -Encoding UTF8