<cfsetting showdebugoutput="false">
<cfheader name="Content-Type" value="application/json">

<!--- Check if user is logged in --->
<cfif NOT structKeyExists(session, "user") OR NOT structKeyExists(session.user, "isLoggedIn") OR NOT session.user.isLoggedIn>
    <cfoutput>#serializeJSON({
        "success": false,
        "error": "Not authenticated"
    })#</cfoutput>
    <cfabort>
</cfif>

<cftry>
    <!--- Get JSON data from request --->
    <cfset requestData = getHTTPRequestData()>
    <cfset jsonData = deserializeJSON(toString(requestData.content))>
    
    <!--- Extract form data --->
    <cfset formData = structKeyExists(jsonData, "formData") ? jsonData.formData : {}>
    <cfset formId = structKeyExists(jsonData, "formId") ? jsonData.formId : 0>
    
    <!--- Set default values if not provided --->
    <cfif NOT structKeyExists(formData, "project_type")>
        <cfset formData.project_type = "">
    </cfif>
    <cfif NOT structKeyExists(formData, "service_type")>
        <cfset formData.service_type = "">
    </cfif>
    <cfif NOT structKeyExists(formData, "email")>
        <cfset formData.email = session.user.email>
    </cfif>
    
    <!--- Serialize form data for storage --->
    <cfset serializedData = serializeJSON(formData)>
    
    <cfif formId GT 0>
        <!--- Update existing draft --->
        <cfquery datasource="clitools">
            UPDATE IntakeForms
            SET project_type = <cfqueryparam value="#formData.project_type#" cfsqltype="cf_sql_varchar" null="#NOT structKeyExists(formData, 'project_type')#">,
                service_type = <cfqueryparam value="#formData.service_type#" cfsqltype="cf_sql_varchar" null="#NOT structKeyExists(formData, 'service_type')#">,
                first_name = <cfqueryparam value="#structKeyExists(formData, 'first_name') ? formData.first_name : ''#" cfsqltype="cf_sql_varchar" null="#NOT structKeyExists(formData, 'first_name') OR NOT len(formData.first_name)#">,
                last_name = <cfqueryparam value="#structKeyExists(formData, 'last_name') ? formData.last_name : ''#" cfsqltype="cf_sql_varchar" null="#NOT structKeyExists(formData, 'last_name') OR NOT len(formData.last_name)#">,
                email = <cfqueryparam value="#structKeyExists(formData, 'email') ? formData.email : session.user.email#" cfsqltype="cf_sql_varchar">,
                phone_number = <cfqueryparam value="#structKeyExists(formData, 'phone_number') ? formData.phone_number : ''#" cfsqltype="cf_sql_varchar" null="#NOT structKeyExists(formData, 'phone_number') OR NOT len(formData.phone_number)#">,
                company_name = <cfqueryparam value="#structKeyExists(formData, 'company_name') ? formData.company_name : ''#" cfsqltype="cf_sql_varchar" null="#NOT structKeyExists(formData, 'company_name') OR NOT len(formData.company_name)#">,
                form_data = <cfqueryparam value="#serializedData#" cfsqltype="cf_sql_longvarchar">,
                updated_at = GETDATE()
            WHERE form_id = <cfqueryparam value="#formId#" cfsqltype="cf_sql_integer">
                AND user_id = <cfqueryparam value="#session.user.userId#" cfsqltype="cf_sql_integer">
                AND is_finalized = 0
        </cfquery>
    <cfelse>
        <!--- Generate form code --->
        <cfset formCode = "">
        <cfset chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789">
        <cfloop from="1" to="8" index="i">
            <cfset formCode &= mid(chars, randRange(1, len(chars)), 1)>
        </cfloop>
        
        <!--- Create new draft --->
        <cfquery datasource="clitools" result="newForm">
            INSERT INTO IntakeForms (
                user_id,
                form_code,
                project_type,
                service_type,
                first_name,
                last_name,
                email,
                phone_number,
                company_name,
                form_data,
                is_finalized,
                created_at,
                updated_at
            ) VALUES (
                <cfqueryparam value="#session.user.userId#" cfsqltype="cf_sql_integer">,
                <cfqueryparam value="#formCode#" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="#formData.project_type#" cfsqltype="cf_sql_varchar" null="#NOT structKeyExists(formData, 'project_type')#">,
                <cfqueryparam value="#formData.service_type#" cfsqltype="cf_sql_varchar" null="#NOT structKeyExists(formData, 'service_type')#">,
                <cfqueryparam value="#structKeyExists(formData, 'first_name') ? formData.first_name : ''#" cfsqltype="cf_sql_varchar" null="#NOT structKeyExists(formData, 'first_name') OR NOT len(formData.first_name)#">,
                <cfqueryparam value="#structKeyExists(formData, 'last_name') ? formData.last_name : ''#" cfsqltype="cf_sql_varchar" null="#NOT structKeyExists(formData, 'last_name') OR NOT len(formData.last_name)#">,
                <cfqueryparam value="#structKeyExists(formData, 'email') ? formData.email : session.user.email#" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="#structKeyExists(formData, 'phone_number') ? formData.phone_number : ''#" cfsqltype="cf_sql_varchar" null="#NOT structKeyExists(formData, 'phone_number') OR NOT len(formData.phone_number)#">,
                <cfqueryparam value="#structKeyExists(formData, 'company_name') ? formData.company_name : ''#" cfsqltype="cf_sql_varchar" null="#NOT structKeyExists(formData, 'company_name') OR NOT len(formData.company_name)#">,
                <cfqueryparam value="#serializedData#" cfsqltype="cf_sql_longvarchar">,
                0,
                GETDATE(),
                GETDATE()
            )
        </cfquery>
        <cfset formId = newForm.generatedKey>
    </cfif>
    
    <cfoutput>#serializeJSON({
        "success": true,
        "formId": formId,
        "message": "Draft saved successfully"
    })#</cfoutput>
    
    <cfcatch>
        <cfoutput>#serializeJSON({
            "success": false,
            "error": cfcatch.message,
            "detail": cfcatch.detail ?: "",
            "type": cfcatch.type ?: ""
        })#</cfoutput>
    </cfcatch>
</cftry>