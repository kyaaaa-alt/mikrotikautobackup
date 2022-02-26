# Autobackup via ftp with looping if failed
# Recommeded minimal scheduler interval 1d 00:00:00

# backup config
:local saveBackup true
:local encryptBackup false
:local saveRscExport true
# ftp config
:local FTPServer "ftp.smoofil.com"
:local FTPPort 21
:local FTPUser "mikrotikbackup@smoofil.com"
:local FTPPass "mikrotikbackup"
# date config
:local date [/system clock get date];
:local months {"jan"="01";"feb"="02";"mar"="03";"apr"="04";"may"="05";"jun"="06";"jul"="07";"aug"="08";"sep"="09";"oct"=10;"nov"=11;"dec"=12};
:local day [:tonum [:pick $date 4 6]];:local year [:tonum [:pick $date 7 11]];:local month [:pick $date 0 3];:local mm (:$months->$month);
:local d "$day-$mm-$year";
# time config
:local time [/system clock get time]
:local t ( [:pick $time 0 2]."-".[:pick $time 3 5]."-".[:pick $time 6 8] )
# file name
:local filename ("Backup-".[/system identity get name]."-".$d."-".$t)

# create backup
:if ($saveBackup) do={
:if ($encryptBackup = true) do={ /system backup save name=($filename.".backup") }
:if ($encryptBackup = false) do={ /system backup save dont-encrypt=yes name=($filename.".backup") }
}
if ($saveRscExport) do={/export file=($filename.".rsc") }

# do ftp upload
:local backupFileName ""
:delay 60s
:foreach backupFile in=[/file find] do={
    :set backupFileName ([/file get $backupFile name])
    :if ([:typeof [:find $backupFileName $filename]] != "nil") do={
        :log info "Memulai upload <$backupFileName>"
        :local attempts 0;
        :local logftp "ftp.log"
        :local cmd "/tool fetch mode=ftp upload=yes user=\"$FTPUser\" password=\"$FTPPass\" port=\"$FTPPort\" src-path=\"$backupFileName\" address=\"$FTPServer\" dst-path=\"$backupFileName\""
        :execute file=$logftp script=$cmd
        :delay 60s
        :local logres [/file get [find name="$logftp.txt"] contents]
        :if ($logres~"finished") do={
            :log warning "<$backupFileName> Berhasil diupload."
        } else {
            :log error "<$backupFileName> Gagal diupload."
        }
        # jika gagal upload, akan mengulang sebanyak 5x
        while ($logres~"failed" and $attempts < 5) do={
            :set attempts ($attempts+1);
            :local newcmd "/tool fetch mode=ftp upload=yes user=\"$FTPUser\" password=\"$FTPPass\" port=\"$FTPPort\" src-path=\"$backupFileName\" address=\"$FTPServer\" dst-path=\"$attempts-$backupFileName\""
            /file remove $logftp
            :delay 3s
            :log warning "Akan mencoba upload kembali..."
            :delay 3s
            :log info "[$attempts] Uploading <$backupFileName>"
            :execute file=$logftp script=$newcmd
            :delay 60s
            :if ($logres~"finished") do={
                :log warning "[$attempts] <$backupFileName> Berhasil diupload."
            } else {
                :log error "[$attempts] <$backupFileName> Gagal diupload."
            }
        }
    } 
}

# remove created backup
:foreach backupFile in=[/file find] do={
    :if ([:typeof [:find [/file get $backupFile name] "Backup-"]]!="nil") do={
        /file remove $backupFile
    }
}
/file remove ftp.log.txt
