<cftry>

<cfif not isdefined("client.sms_user_phone")>abort<cfabort></cfif>

<cfset request.remote_phone=remote_phone>
<cfset request.local_phone="813-465-2165">
<cfset request.local_only="0">

<cf_send_sms
		direction	="in"
		sms_user_id	="#client.sms_user_id#"
		virtual		="1"
		sms_body	="##signup813 #sms_user_name_16#">

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