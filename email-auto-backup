# Autobackup via email with looping if failed
# Recommeded minimal scheduler interval 1d 00:00:00

# backup config
:local saveBackup true
:local encryptBackup false
:local saveRscExport true
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
    :if ($encryptBackup = true) do={
        /system backup save name=($filename.".backup") 
    }
    :if ($encryptBackup = false) do={ 
        /system backup save dont-encrypt=yes name=($filename.".backup") 
    }
} 
if ($saveRscExport) do={
    /export file=($filename.".rsc")
}

# do sent email
:local attempts 0;
:local email [/tool e-mail get user]
:local status [/tool e-mail get last-status]
:log info "Mengirim <$filename> =>> $email"
:delay 60s
/tool e-mail send to=$email subject=$filename body=$filename file=[:file find where name~"Backup-"] start-tls=yes
:delay 60s
if ($status != "succeeded") do={
    :log error "Gagal <$backupFileName> =>> $email"
} else {
    :log warning "Sukses <$filename> =>> $email"
}
:delay 5s
# jika gagal mengirim email, akan mengulang sebanyak 5x
while ($status != "succeeded" and $attempts < 5) do={
    :set attempts ($attempts+1);
    :log warning "Akan mencoba mengirim kembali..."
    :delay 3s
    :log info "[$attempts] Mengirim <$filename> =>> $email"
    :delay 60s
    /tool e-mail send to=$email subject=$filename body=$filename file=[:file find where name~"Backup-"] start-tls=yes
    :delay 60s
    if ($status != "succeeded") do={
        :log error "Gagal <$backupFileName> =>> $email"
    } else {
        :log warning "Sukses <$filename> =>> $email"
    }
} 

# remove created backup
:foreach backupFile in=[/file find] do={
    :if ([:typeof [:find [/file get $backupFile name] "Backup-"]]!="nil") do={
        /file remove $backupFile
    }
}
