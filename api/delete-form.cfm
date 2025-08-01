<cfsetting showdebugoutput="false">
<cfheader name="Content-Type" value="application/json">

<!--- Check if user is logged in --->
<cfif NOT structKeyExists(session, "isLoggedIn") OR NOT session.isLoggedIn>
    <cfoutput>#serializeJSON({
        "success": false,
        "error": "Not authenticated"
    })#</cfoutput>
    <cfabort>
</cfif>

<!--- Get user ID from session --->
<cfset userId = 0>
<cfif structKeyExists(session, "user") AND structKeyExists(session.user, "userId")>
    <cfset userId = session.user.userId>
<cfelseif structKeyExists(session, "user") AND structKeyExists(session.user, "user_id")>
    <cfset userId = session.user.user_id>
<cfelseif structKeyExists(session, "userId")>
    <cfset userId = session.userId>
</cfif>

<cfif userId EQ 0>
    <cfoutput>#serializeJSON({
        "success": false,
        "error": "User ID not found in session"
    })#</cfoutput>
    <cfabort>
</cfif>

<cftry>
    <!--- Get JSON data from request --->
    <cfset requestData = getHTTPRequestData()>
    <cfset jsonData = deserializeJSON(toString(requestData.content))>
    
    <!--- Determine if using formId or formCode --->
    <cfif structKeyExists(jsonData, "formId")>
        <cfset formId = jsonData.formId>
        <!--- Verify the form belongs to the user and is a draft --->
        <cfquery name="qForm" datasource="clitools">
            SELECT form_id, user_id, is_finalized
            FROM IntakeForms
            WHERE form_id = <cfqueryparam value="#formId#" cfsqltype="cf_sql_integer">
            AND user_id = <cfqueryparam value="#userId#" cfsqltype="cf_sql_integer">
        </cfquery>
    <cfelseif structKeyExists(jsonData, "formCode")>
        <!--- Get form by reference_id (8-character code) --->
        <cfquery name="qForm" datasource="clitools">
            SELECT form_id, user_id, is_finalized
            FROM IntakeForms
            WHERE reference_id = <cfqueryparam value="#jsonData.formCode#" cfsqltype="cf_sql_varchar">
            AND user_id = <cfqueryparam value="#userId#" cfsqltype="cf_sql_integer">
        </cfquery>
        <cfif qForm.recordCount GT 0>
            <cfset formId = qForm.form_id>
        </cfif>
    <cfelse>
        <cfthrow message="No form identifier provided">
    </cfif>
    
    <cfif NOT isDefined("qForm") OR qForm.recordCount EQ 0>
        <cflog file="delete-form-debug" text="Form not found - FormId: #structKeyExists(jsonData, 'formId') ? jsonData.formId : 'N/A'#, FormCode: #structKeyExists(jsonData, 'formCode') ? jsonData.formCode : 'N/A'#, UserId: #userId#">
        <cfthrow message="Form not found or access denied">
    </cfif>
    
    <cfif qForm.is_finalized>
        <cfthrow message="Cannot delete submitted forms">
    </cfif>
    
    <!--- Delete the form --->
    <cfquery datasource="clitools">
        DELETE FROM IntakeForms
        WHERE form_id = <cfqueryparam value="#formId#" cfsqltype="cf_sql_integer">
        AND user_id = <cfqueryparam value="#session.user.userId#" cfsqltype="cf_sql_integer">
        AND is_finalized = 0
    </cfquery>
    
    <cfoutput>#serializeJSON({
        "success": true,
        "message": "Form deleted successfully"
    })#</cfoutput>
    
    <cfcatch>
        <cfoutput>#serializeJSON({
            "success": false,
            "error": cfcatch.message
        })#</cfoutput>
    </cfcatch>
</cftry>