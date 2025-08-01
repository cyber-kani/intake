<cfsetting showdebugoutput="false">
<cfheader name="Access-Control-Allow-Origin" value="*">
<cfheader name="Access-Control-Allow-Methods" value="GET, OPTIONS">
<cfheader name="Access-Control-Allow-Headers" value="Content-Type">
<cfcontent type="application/json">

<!--- Handle OPTIONS request --->
<cfif cgi.request_method EQ "OPTIONS">
    <cfheader statuscode="204" statustext="No Content">
    <cfabort>
</cfif>

<cfparam name="url.id" default="">

<cftry>
    <!--- Validate input --->
    <cfif NOT len(trim(url.id))>
        <cfthrow message="Form ID is required">
    </cfif>
    
    <!--- Query for form --->
    <cfquery name="qForm" datasource="clitools">
        SELECT f.*, u.email as user_email
        FROM IntakeForms f
        INNER JOIN Users u ON f.user_id = u.user_id
        WHERE 
            <cfif isNumeric(url.id)>
                f.form_id = <cfqueryparam value="#url.id#" cfsqltype="cf_sql_integer">
            <cfelse>
                f.reference_id = <cfqueryparam value="#url.id#" cfsqltype="cf_sql_varchar">
            </cfif>
            AND f.user_id = <cfqueryparam value="#session.user.userId#" cfsqltype="cf_sql_integer">
            AND f.is_finalized = 0
    </cfquery>
    
    <cfif qForm.recordCount EQ 0>
        <cfthrow message="Form not found or access denied">
    </cfif>
    
    <!--- Return form data --->
    <cfset response = {
        "success" = true,
        "form" = {
            "form_id" = qForm.form_id,
            "reference_id" = qForm.reference_id,
            "service_type" = qForm.service_type,
            "first_name" = qForm.first_name,
            "last_name" = qForm.last_name,
            "email" = qForm.email,
            "form_data" = qForm.form_data,
            "created_at" = qForm.created_at
        }
    }>
    
    <cfoutput>#serializeJSON(response)#</cfoutput>
    
    <cfcatch>
        <cfset response = {
            "success" = false,
            "error" = cfcatch.message,
            "detail" = structKeyExists(cfcatch, "detail") ? cfcatch.detail : ""
        }>
        <cfoutput>#serializeJSON(response)#</cfoutput>
    </cfcatch>
</cftry>