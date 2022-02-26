### Auto Backup Konfigurasi Mikrotik RouterOS

Silahkan atur backup config sesuai kebutuhan, misalnya jika ingin backup file rsc saja set `saveBackup false`, dan `saveRscExport true`

    :local saveBackup false
    :local encryptBackup false
    :local saveRscExport true
Untuk mengtur total looping jika gagal backup dan mengulangi backup silahkan atur line` :while ` dan ubah total attemptsnya  `$attempts < 5` misalnya menjadi 10x ulang jika gagal berarti menjadi  `$attempts < 10` atau sesuai yang anda inginkan.
