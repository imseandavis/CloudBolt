#This script is written for those who have been hit by the bug in 7.0 RC4 to 7.1 A1 that writes events For disk changes on every
#resource handler sync, even if no changes were made. This can lead to some huge server event histories. This script will clean
#up all those entries.

#Test Print The History of 10 GCE Servers Event History For Verification First
for server in Server.objects.filter(environment__resource_handler__in=GCEHandler.objects.all())[:10]:
    for serverhistory in server.serverhistory_set.filter(event_message__contains="Size of disk"):
        print history

#Delete All GCE Events Histories Mentioning Disk Size Changes
for server in Server.objects.filter(environment__resource_handler__in=GCEHandler.objects.all()):
    server.serverhistory_set.filter(event_message__contains="Size of disk").delete()
