<cfif not isdefined("hashtag")>
	<cflocation url="phonebank.cfm?hashtag=pdttb" addtoken="no">
</cfif>

<cfif not isdefined("client.sms_user_phone")>
	<cfif isdefined("remote_phone") and isdefined("remote_auth")>
		<cfquery name="getuser" datasource="democratbbs">
			select *
			from organizers o
			inner join view_user_phones v
			on o.sms_user_id=v.sms_user_id
			where sms_user_phone=<cfqueryparam cfsqltype="cf_sql_varchar" value="#remote_phone#">
			and remote_auth=<cfqueryparam cfsqltype="cf_sql_integer" value="#remote_auth#">
		</cfquery>
		<cfloop list="#getuser.columnlist#" index="field">
			<cfset "client.#field#"=evaluate("getuser.#field#")>
		</cfloop>
		<cflocation url="phonebank.cfm?hashtag=#hashtag#" addtoken="no">
	</cfif>
	<cfif not isdefined("remote_phone")>
		<form action="phonebank.cfm" method="get">
			<cfoutput>
				<input type="hidden" name="hashtag" value="#hashtag#">
			</cfoutput>
			Your phone number:<br>
			<input type="text" name="remote_phone"><br>
			<input type="submit">
		</form>
		<cfabort>
	</cfif>
	<cfquery name="getuser" datasource="democratbbs">
		select remote_auth
		from organizers o
		inner join view_user_phones v
		on o.sms_user_id=v.sms_user_id
		where sms_user_phone=<cfqueryparam cfsqltype="cf_sql_varchar" value="#remote_phone#">
	</cfquery>
	<cfif getuser.recordcount eq 1>
		<cfset request.local_phone="813-465-2165">
		<cfset request.remote_phone="#remote_phone#">
		<cfset request.local_only="0">
		<cf_send_sms sms_user_id="-20" sms_body="Enter the code [ #getuser.remote_auth# ] to log in via the web">
	</cfif>
	<form action="phonebank.cfm" method="get">
		<cfoutput>
			<input type="hidden" name="remote_phone" value="#remote_phone#">
			<input type="hidden" name="hashtag" value="#hashtag#">
		</cfoutput>
		Enter code from text message:<br>
		<input type="text" name="remote_auth">
		<input type="submit">
	</form>
	<cfabort>
</cfif>

<cfquery name="phones" datasource="democratbbs">
	select *
	from hashtag_submit h
	left outer join view_user_phones u
	on h.remote_phone=u.sms_user_phone
	where h.hashtag_text=<cfqueryparam cfsqltype="cf_sql_varchar" value="###hashtag#">
	order by remote_phone, insertdatetime
</cfquery>
<cfquery name="queue" datasource="democratbbs">
	select *
	from queue
	where remote_phone in (<cfqueryparam cfsqltype="cf_sql_varchar" list="yes" value="#valuelist(phones.remote_phone)#">)
	and virtual=1
	order by insertdatetime
</cfquery>

<html>
<head>
	<cfoutput>
		<title>###hashtag# - Phone Bank</title>
	</cfoutput>
</head>

<body>

<table width="100%" border="1">
<cfoutput query="phones" group="remote_phone">
	<tr>
		<td colspan="2">
			<h2>
				#remote_phone#
				<a href="sms:#remote_phone#">Text Message</a>
			</h2>
		</td>
	<tr>
	<cfif sms_user_name_16 neq "">
		<tr>
			<td colspan="2">
				<h2>#sms_user_name_16#</h2>
			</td>
		</tr>
	</cfif>
	<tr>
		<td nowrap width="10%">
			#dateformat(insertdatetime,"mm/dd/yy")#<br>
			#timeformat(insertdatetime,"hh:mm tt")#
		</td>
		<td width="90%">
			#hashtag_text# #replace(replace(sms_body,"<","&lt;","all"),chr(10),"<br>","all")#
		</td>
	</tr>
	<cfquery name="queue3" dbtype="query" maxrows="5">
		select *
		from queue
		where remote_phone='#remote_phone#'
		order by sms_queue_id desc
	</cfquery>
	<cfquery name="queue2" dbtype="query">
		select *
		from queue3
		order by sms_queue_id
	</cfquery>
	<cfif queue2.recordcount gt 0>
		<cfloop query="queue2">
			<tr>
				<td nowrap width="10%">
					#dateformat(insertdatetime,"mm/dd/yy")#<br>
					#timeformat(insertdatetime,"hh:mm tt")# (#direction#)
				</td>
				<td width="90%">
					#replace(replace(sms_body,"<","&lt;","all"),chr(10),"<br>","all")#
				</td>
			</tr>
		</cfloop>
	</cfif>
	<tr>
		<td colspan="2">
			<form action="phonebank_send.cfm" method="get" target="sms_#remote_phone#">
			<input type="hidden" name="hashtag" value="#hashtag#">
			<input type="hidden" name="remote_phone" value="#remote_phone#">
			<input type="hidden" name="sms_user_name_16" value="#sms_user_name_16#">
			<input type="submit" value=" &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; SEND &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; ">
			</form>
		</td>
	</tr>
</cfoutput>
</table>

</body></html>
