<cftry>

<cfif not isdefined("client.sms_user_phone")>abort<cfabort></cfif>

<cfif isdefined("send_sms_body")>
	<cfset request.local_phone="813-465-2165">
	<cfset request.remote_phone="#remote_phone#">
	<cfset request.local_only="0">
	<cf_send_sms sms_body="<#client.at_name#> #send_sms_body#" sms_user_id="#client.sms_user_id#" virtual="1">
	<cflocation url="phonebank_send.cfm?remote_phone=#remote_phone#&hashtag=#hashtag#" addtoken="no">
</cfif>

<cfquery name="queue" datasource="democratbbs">
	select *
	from queue
	left outer join view_user_phones
	on queue.remote_phone=view_user_phones.sms_user_phone
	where remote_phone=<cfqueryparam cfsqltype="cf_sql_varchar" value="#remote_phone#">
	and virtual=1
	and insertdatetime >= #createodbcdate(now())#
	order by insertdatetime
</cfquery>

<html>
<head>
	<cfoutput>
		<title>#sms_user_name_16# ###hashtag# #remote_phone#</title>
	</cfoutput>
</head>

<body>

<table border="1" width="300">
<tr><td>

<cfoutput>
	<h2>#remote_phone# #sms_user_name_16#</h2>
</cfoutput>

<cfif sms_user_name_16 eq "">
	<form action="phonebank_adduser.cfm" method="post">
		<cfoutput>
			<input type="hidden" name="remote_phone" value="#remote_phone#">
			<input type="hidden" name="hashtag" value="#hashtag#">
		</cfoutput>
		Name:
		<input type="text" name="sms_user_name_16" max="16"><br>
		<input type="submit" value=" &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; ADD USER &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; ">
	</form>
<cfelse>
	<cfif queue.last_location neq "52">
		<h3>User is not currently logged into Virtual Outreach</h3>
		<cfoutput>
			<input type="button" value="Move User to Virtual Outreach" onclick="self.location.href='phonebank_moveuser.cfm?hashtag=#hashtag#&remote_phone=#remote_phone#'">
		</cfoutput>
	<cfelse>
		<h3>User is in Virtual Outreach</h3>
	</cfif>
</cfif>

<cfoutput query="queue">
	<tr>
		<cfif direction eq "in">
			<td align="left">#replace(replace(sms_body,"<","&lt;","all"),chr(10),"<br>","all")#</td>
		<cfelse>
			<td align="right">#replace(replace(sms_body,"<","&lt;","all"),chr(10),"<br>","all")#</td>
		</cfif>
	</tr>
</cfoutput>

<tr><td>
	<form name="phonebankform" action="phonebank_send.cfm" method="post">
		<cfoutput>
			<input type="hidden" name="remote_phone" value="#remote_phone#">
			<input type="hidden" name="hashtag" value="#hashtag#">
		</cfoutput>
		<textarea name="send_sms_body" rows="4" cols="40"></textarea><br>
		<input type="submit" value=" &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; SEND &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; ">
	</form>
</td></tr>

</table>

<!---
<h3>FORM</h3>
<cfdump var="#form#">
<h3>URL</h3>
<cfdump var="#url#">
<h3>REQUEST</h3>
<cfdump var="#request#">
--->

<script>
	window.scrollTo(0,document.body.scrollHeight);
	document.phonebankform.send_sms_body.focus();
</script>

</body>
</html>

<cfcatch type="any">
	<cfsavecontent variable="error">
		<cfdump var="#cfcatch#">
	</cfsavecontent>
	<cfdump var="#cfcatch#">
	<cffile action="write" file="#getdirectoryfrompath(getcurrenttemplatepath())#\phonebank_send_errorlog.htm" output="#error#">
	<cfabort>
</cfcatch>

</cftry>