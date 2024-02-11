# เชื่อมต่อกับ MSSQL Server
$serverName = "ชื่อเซิร์ฟเวอร์"
$username = "ชื่อผู้ใช้"
$password = "รหัสผ่าน"

$connectionString = "Server=$serverName;User ID=$username;Password=$password;"
$connection = New-Object System.Data.SqlClient.SqlConnection($connectionString)
$connection.Open()

# สร้างคำสั่ง SQL เพื่อดึงรายการฐานข้อมูลทั้งหมด
$sql = "SELECT name FROM sys.databases WHERE database_id > 4"  # ข้ามฐานข้อมูลระบบที่มีรหัสน้อยกว่า 5
$command = $connection.CreateCommand()
$command.CommandText = $sql

# ประมวลผลคำสั่ง SQL และแสดงรายการฐานข้อมูลทั้งหมด
$reader = $command.ExecuteReader()
$databases = @()
while ($reader.Read()) {
    $databases += $reader["name"]
}
$reader.Close()

Write-Host "รายการฐานข้อมูลทั้งหมด:"
for ($i=0; $i -lt $databases.Count; $i++) {
    Write-Host "$($i+1). $($databases[$i])"
}

# ให้ผู้ใช้เลือกฐานข้อมูล
$selectedDatabaseIndex = Read-Host "โปรดเลือกหมายเลขฐานข้อมูลที่ต้องการ Dump (1-$($databases.Count))"

if ($selectedDatabaseIndex -ge 1 -and $selectedDatabaseIndex -le $databases.Count) {
    $selectedDatabase = $databases[$selectedDatabaseIndex - 1]
    Write-Host "คุณเลือกฐานข้อมูล: $selectedDatabase"

    # ระบุตำแหน่งที่ต้องการเก็บไฟล์ Dump
    $outputDirectory = "เส้นทางเก็บไฟล์ Dump"
    $timestamp = Get-Date -Format "yyyyMMddHHmmss"
    $outputFile = "$outputDirectory\$selectedDatabase-$timestamp.bak"

    # สร้างคำสั่ง SQL สำหรับ Dump ฐานข้อมูลที่เลือก
    $dumpCommand = "BACKUP DATABASE [$selectedDatabase] TO DISK='$outputFile' WITH FORMAT, MEDIANAME='DatabaseBackup', MEDIADESCRIPTION='Backup';"
    $command.CommandText = $dumpCommand

    # ประมวลผลคำสั่ง SQL
    $command.ExecuteNonQuery()

    Write-Host "การสำรองข้อมูลฐานข้อมูล $selectedDatabase เสร็จเรียบร้อยแล้วที่ $outputFile"
} else {
    Write-Host "เบอร์ที่คุณเลือกไม่ถูกต้อง"
}

# ปิดการเชื่อมต่อ
$connection.Close()
