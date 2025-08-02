<cfsetting showdebugoutput="false">
<cfheader name="Access-Control-Allow-Origin" value="*">
<cfheader name="Access-Control-Allow-Methods" value="POST, OPTIONS">
<cfheader name="Access-Control-Allow-Headers" value="Content-Type">
<cfcontent type="application/json">

<!--- Handle OPTIONS request --->
<cfif cgi.request_method EQ "OPTIONS">
    <cfheader statuscode="204" statustext="No Content">
    <cfabort>
</cfif>

<!--- Check if user is logged in --->
<cfif NOT structKeyExists(session, "isLoggedIn") OR NOT session.isLoggedIn>
    <cfset response = {
        "success": false,
        "error": "Not authenticated"
    }>
    <cfoutput>#serializeJSON(response)#</cfoutput>
    <cfabort>
</cfif>

<cftry>
    <!--- Parse JSON input --->
    <cfset requestData = getHTTPRequestData()>
    <cfset jsonData = deserializeJSON(toString(requestData.content))>
    
    <!--- Extract data --->
    <cfset formId = structKeyExists(jsonData, "formId") ? jsonData.formId : "">
    <cfset referenceId = structKeyExists(jsonData, "referenceId") ? jsonData.referenceId : "">
    
    <!--- Get the form data to ensure all fields are populated --->
    <cfset db = createObject("component", "intake.components.Database")>
    
    <!--- Find the form --->
    <cfif len(formId) AND isNumeric(formId)>
        <cfset qForm = db.getFormById(formId, session.user.userId)>
    <cfelseif len(referenceId)>
        <cfset qForm = db.getFormByReferenceId(referenceId, session.user.userId)>
    <cfelse>
        <cfthrow message="No form identifier provided">
    </cfif>
    
    <cfif qForm.recordCount EQ 0>
        <cfthrow message="Form not found">
    </cfif>
    
    <!--- Parse the form data --->
    <cfset formData = deserializeJSON(qForm.form_data)>
    
    <!--- Extract AI conversation data if present --->
    <cfif structKeyExists(formData, "ai_conversation") AND isSimpleValue(formData.ai_conversation)>
        <cfset aiData = deserializeJSON(formData.ai_conversation)>
        <cfif structKeyExists(aiData, "projectInfo")>
            <cfset projectInfo = aiData.projectInfo>
            
            <!--- Ensure all fields are properly populated in formData --->
            <!--- Top level fields --->
            <cfif structKeyExists(projectInfo, "project_type") AND len(projectInfo.project_type)>
                <cfset formData.project_type = projectInfo.project_type>
            </cfif>
            <cfif structKeyExists(projectInfo, "service_type") AND len(projectInfo.service_type)>
                <cfset formData.service_type = projectInfo.service_type>
            </cfif>
            <cfif structKeyExists(projectInfo, "service_category") AND len(projectInfo.service_category)>
                <cfset formData.service_category = projectInfo.service_category>
            </cfif>
            
            <!--- Basic info --->
            <cfif structKeyExists(projectInfo, "basicInfo") AND isStruct(projectInfo.basicInfo)>
                <!--- Explicitly handle first_name and last_name first --->
                <cfif structKeyExists(projectInfo.basicInfo, "first_name") AND len(trim(projectInfo.basicInfo.first_name))>
                    <cfset formData.first_name = projectInfo.basicInfo.first_name>
                </cfif>
                <cfif structKeyExists(projectInfo.basicInfo, "last_name") AND len(trim(projectInfo.basicInfo.last_name))>
                    <cfset formData.last_name = projectInfo.basicInfo.last_name>
                </cfif>
                
                <!--- Handle other fields --->
                <cfloop collection="#projectInfo.basicInfo#" item="key">
                    <cfset mappedKey = key>
                    <cfif key EQ "phone">
                        <cfset mappedKey = "phone_number">
                    <cfelseif key EQ "company">
                        <cfset mappedKey = "company_name">
                    <cfelseif key EQ "contact_method">
                        <cfset mappedKey = "preferred_contact_method">
                    <cfelseif key EQ "website">
                        <cfset mappedKey = "current_website">
                    </cfif>
                    <cfif structKeyExists(projectInfo.basicInfo, key) AND len(trim(projectInfo.basicInfo[key]))>
                        <cfset formData[mappedKey] = projectInfo.basicInfo[key]>
                    </cfif>
                </cfloop>
            </cfif>
            
            <!--- Project details --->
            <cfif structKeyExists(projectInfo, "projectDetails") AND isStruct(projectInfo.projectDetails)>
                <cfloop collection="#projectInfo.projectDetails#" item="key">
                    <cfset mappedKey = key>
                    <cfif key EQ "description">
                        <cfset mappedKey = "project_description">
                    <cfelseif key EQ "budget">
                        <cfset mappedKey = "budget_range">
                    </cfif>
                    <cfif len(trim(projectInfo.projectDetails[key]))>
                        <cfset formData[mappedKey] = projectInfo.projectDetails[key]>
                    </cfif>
                </cfloop>
            </cfif>
            
            <!--- Design features --->
            <cfif structKeyExists(projectInfo, "designFeatures") AND isStruct(projectInfo.designFeatures)>
                <cfloop collection="#projectInfo.designFeatures#" item="key">
                    <cfset mappedKey = key>
                    <cfif key EQ "style">
                        <cfset mappedKey = "design_style">
                    <cfelseif key EQ "colors">
                        <cfset mappedKey = "color_preferences">
                    </cfif>
                    <cfset formData[mappedKey] = projectInfo.designFeatures[key]>
                </cfloop>
            </cfif>
            
            <!--- Additional info --->
            <cfif structKeyExists(projectInfo, "additionalInfo") AND isStruct(projectInfo.additionalInfo)>
                <cfloop collection="#projectInfo.additionalInfo#" item="key">
                    <cfset formData[key] = projectInfo.additionalInfo[key]>
                </cfloop>
            </cfif>
        </cfif>
    </cfif>
    
    <!--- Update the form with the complete data --->
    <cfset db.updateForm(qForm.form_id, formData, session.user.userId)>
    
    <!--- Now finalize the form --->
    <cfset db.finalizeForm(qForm.form_id, session.user.userId)>
    
    <!--- Return success response --->
    <cfset response = {
        "success" = true,
        "formId" = qForm.form_id,
        "referenceId" = qForm.reference_id,
        "message" = "Form finalized successfully"
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