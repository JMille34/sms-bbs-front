<cftry>

<cfif not isdefined("client.sms_user_phone")>abort<cfabort></cfif>

<cfquery name="getuser" datasource="democratbbs">
	select sms_user_id
	from user_phones
	where sms_user_phone=<cfqueryparam cfsqltype="cf_sql_varchar" value="#remote_phone#">
</cfquery>
<cfquery name="move_to_virtual_outreach" datasource="democratbbs">
	update sms_users
	set last_location=52
	where sms_user_id=#getuser.sms_user_id#
</cfquery>

<cfset request.remote_phone=remote_phone>
<cfset request.local_phone="813-465-2165">
<cfset request.local_only="0">

<cf_send_sms
		sms_user_id	="#client.sms_user_id#"
		virtual		="1"
		sms_body	="=Virtual Outreach=#chr(10)##chr(10)##client.sms_user_name_16# has initiated chat#chr(10)##chr(10)#Send * to exit">

<cflocation url="phonebank_send.cfm?hashtag=#hashtag#&remote_phone=#remote_phone#" addtoken="no">

<cfcatch type="any">
	<cfsavecontent variable="error">
		<cfdump var="#cfcatch#">
	</cfsavecontent>
	<cfdump var="#cfcatch#">
	<cffile action="write" file="#getdirectoryfrompath(getcurrenttemplatepath())#\phonebank_adduser_errorlog.htm" output="#error#">
	<cfabort>
</cfcatch>

</cftry>