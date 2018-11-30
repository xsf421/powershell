$starttime = '04/01/2018 23:00'
$endtime = '04/01/2018 23:15'


#region define calendar item text
[string]$bodytext = @" 
                **All Links in this document must be open using Internet Explorer*** 

<a href="\\mi\dfs\shared\Everyone\NOC Maintenance Windows"> Link to Current Maintenance Server List</a>

NOC Responsibilities:

	1.	Before/During maintenance Get Prepared

		a.	<a href="http://ql1sccmdb1/Reports/Pages/Report.aspx?ItemPath=%2fConfigMgr_QL1%2fSoftware+Updates+-+A+Compliance%2fCompliance+1+-+Overall+compliance">See Update compliancy state</a>
            Why: Before maintenance this report will show you how many server are in the group and a pre compliance state this should look bad before maintenance 
            During/After maintenance this report should start updating and more server should be compliant. This report can be delayed so do not panic if it is looking a little out of compliance  

                
                i.	Update Group: All Deployed Update Baseline
                
                ii.	Collection: MW-…

        b.	<a href="http://ql1sccmdb1/Reports/Pages/Report.aspx?ItemPath=%2fConfigMgr_QL1%2fSoftware+Updates+-+A+Compliance%2fCompliance+Status++for+collection&ViewMode=Detail">See server detailed status</a>
            Why: This report will help narrow down potential trouble server. Taking the steps below should get lighter over time as we improve the process and fix some of the more stubborn servers. The more work we put in and better we document the manual work the easer this should be. 
                
                i.	Choose Collection: MW-…

90k Message
 	Maintenance 90k: Production Server Automated Windows Updates / Reboots	Questions? call the NOC:x34770
Maintenance 90k: Production Server Automated Windows Updates / Reboots
For: Technology Infrastructure
Explanation: Production servers in SCCM collections MW-W3-SUN2300-0300, MW-W3-MON0000-0200 and MW-W3-MON0300-0600 will be undergoing automated Windows updates and reboots beginning at 11:00 PM EST, Friday, March 2nd until 06:00 AM EST, Saturday, March 3rd.
Impact: Servers in these groups will be rebooted

"@

$body = get-content '\\mi\dfs\shared\noc team\pmills\bodytext.txt'



<#---------------------------------------------------------------/#>


# create calendar item for maintenance 90k


$outlook = new-object -com Outlook.Application


$calendar = $outlook.Session.folders.Item(2).Folders.Item("maintenance")


$appt = $calendar.Items.Add(1) # == olAppointmentItem


$appt.Start = $starttime


$appt.End = $endtime


$appt.Subject = "Send Maintenance 90k"


$appt.Body = $body


$appt.Categories = "Automated Server Maintenance"


$appt.Save()


<#
sunday apr 1 2300 90k 
sunday apr 2 2300-0300
monday apr 2 0000-0200
monday apr 2 0300-0600
/#>