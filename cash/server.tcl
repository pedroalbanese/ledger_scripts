#!/usr/bin/wish
exec sh /storage/sdcard0/PortoDB/export/cash/CSV2Ledger
exec /storage/sdcard0/PortoDB/export/cash/ledger -f /storage/sdcard0/PortoDB/export/Journal.txt -q /storage/sdcard0/PortoDB/export/cash/quickview.txt -r /storage/sdcard0/PortoDB/export/cash/quickview.txt web
exit 0