<!--- Admin access check is done in Application.cfc --->

<cfheader name="Content-Type" value="application/json">

<cftry>
    <!--- Get JSON data --->
    <cfset requestData = getHTTPRequestData()>
    <cfset jsonData = deserializeJSON(toString(requestData.content))>
    
    <!--- Validate form ID --->
    <cfif NOT structKeyExists(jsonData, "formId") OR NOT isNumeric(jsonData.formId)>
        <cfthrow message="Invalid form ID">
    </cfif>
    
    <!--- Delete the form --->
    <cfquery datasource="clitools">
        DELETE FROM IntakeForms
        WHERE form_id = <cfqueryparam value="#jsonData.formId#" cfsqltype="cf_sql_integer">
    </cfquery>
    
    <!--- Return success --->
    <cfoutput>#serializeJSON({
        "success" = true,
        "message" = "Form deleted successfully"
    })#</cfoutput>
    
    <cfcatch>
        <cfoutput>#serializeJSON({
            "success" = false,
            "error" = cfcatch.message
        })#</cfoutput>
    </cfcatch>
</cftry>