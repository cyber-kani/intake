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
    <cfset conversationHistory = jsonData.conversationHistory>
    <cfset projectInfo = jsonData.projectInfo>
    <cfset formId = structKeyExists(jsonData, "formId") ? jsonData.formId : "">
    
    <!--- Create form data structure with AI conversation data --->
    <cfset formData = {
        "project_type" = structKeyExists(projectInfo, "project_type") ? projectInfo.project_type : "",
        "service_type" = structKeyExists(projectInfo, "service_type") ? projectInfo.service_type : "",
        "service_category" = structKeyExists(projectInfo, "service_category") ? projectInfo.service_category : "",
        "first_name" = "",
        "last_name" = "",
        "email" = structKeyExists(session, "user") AND structKeyExists(session.user, "email") ? session.user.email : "",
        "phone_number" = "",
        "company_name" = "",
        "industry" = "",
        "preferred_contact_method" = "",
        "current_website" = "",
        "project_description" = "",
        "target_audience" = "",
        "geographic_target" = "",
        "timeline" = "",
        "budget_range" = "",
        "design_style" = "",
        "color_preferences" = [],
        "features" = [],
        "reference_websites" = [],
        "reference_descriptions" = [],
        "has_branding" = "no",
        "need_content_writing" = "no",
        "need_maintenance" = "no",
        "additional_comments" = "",
        "referral_source" = "",
        "ai_conversation" = serializeJSON({
            "conversationHistory" = conversationHistory,
            "projectInfo" = projectInfo,
            "lastUpdated" = now()
        }),
        "ai_draft" = true,
        "from_ai" = true
    }>
    
    <!--- Extract basic info --->
    <cfif structKeyExists(projectInfo, "basicInfo") AND isStruct(projectInfo.basicInfo)>
        <cfif structKeyExists(projectInfo.basicInfo, "first_name") AND len(projectInfo.basicInfo.first_name)>
            <cfset formData.first_name = projectInfo.basicInfo.first_name>
        </cfif>
        <cfif structKeyExists(projectInfo.basicInfo, "last_name") AND len(projectInfo.basicInfo.last_name)>
            <cfset formData.last_name = projectInfo.basicInfo.last_name>
        </cfif>
        <cfif structKeyExists(projectInfo.basicInfo, "phone") AND len(projectInfo.basicInfo.phone)>
            <cfset formData.phone_number = projectInfo.basicInfo.phone>
        </cfif>
        <cfif structKeyExists(projectInfo.basicInfo, "email") AND len(projectInfo.basicInfo.email)>
            <cfset formData.email = projectInfo.basicInfo.email>
        </cfif>
        <cfif structKeyExists(projectInfo.basicInfo, "company") AND len(projectInfo.basicInfo.company)>
            <cfset formData.company_name = projectInfo.basicInfo.company>
        </cfif>
        <cfif structKeyExists(projectInfo.basicInfo, "contact_method") AND len(projectInfo.basicInfo.contact_method)>
            <cfset formData.preferred_contact_method = projectInfo.basicInfo.contact_method>
        </cfif>
        <cfif structKeyExists(projectInfo.basicInfo, "website") AND len(projectInfo.basicInfo.website)>
            <cfset formData.current_website = projectInfo.basicInfo.website>
        </cfif>
    </cfif>
    
    <!--- Extract project details --->
    <cfif structKeyExists(projectInfo, "projectDetails") AND isStruct(projectInfo.projectDetails)>
        <cfif structKeyExists(projectInfo.projectDetails, "description") AND len(projectInfo.projectDetails.description)>
            <cfset formData.project_description = projectInfo.projectDetails.description>
        </cfif>
        <cfif structKeyExists(projectInfo.projectDetails, "target_audience") AND len(projectInfo.projectDetails.target_audience)>
            <cfset formData.target_audience = projectInfo.projectDetails.target_audience>
        </cfif>
        <cfif structKeyExists(projectInfo.projectDetails, "geographic_target") AND len(projectInfo.projectDetails.geographic_target)>
            <cfset formData.geographic_target = projectInfo.projectDetails.geographic_target>
        </cfif>
        <cfif structKeyExists(projectInfo.projectDetails, "timeline") AND len(projectInfo.projectDetails.timeline)>
            <cfset formData.timeline = projectInfo.projectDetails.timeline>
        </cfif>
        <cfif structKeyExists(projectInfo.projectDetails, "budget") AND len(projectInfo.projectDetails.budget)>
            <cfset formData.budget_range = projectInfo.projectDetails.budget>
        </cfif>
    </cfif>
    
    <!--- Extract design features --->
    <cfif structKeyExists(projectInfo, "designFeatures") AND isStruct(projectInfo.designFeatures)>
        <cfif structKeyExists(projectInfo.designFeatures, "style") AND len(projectInfo.designFeatures.style)>
            <cfset formData.design_style = projectInfo.designFeatures.style>
        </cfif>
        <cfif structKeyExists(projectInfo.designFeatures, "colors") AND isArray(projectInfo.designFeatures.colors)>
            <cfset formData.color_preferences = projectInfo.designFeatures.colors>
        </cfif>
        <cfif structKeyExists(projectInfo.designFeatures, "features") AND isArray(projectInfo.designFeatures.features)>
            <cfset formData.features = projectInfo.designFeatures.features>
        </cfif>
    </cfif>
    
    <!--- Extract additional info --->
    <cfif structKeyExists(projectInfo, "additionalInfo") AND isStruct(projectInfo.additionalInfo)>
        <cfif structKeyExists(projectInfo.additionalInfo, "reference_websites")>
            <cfif isArray(projectInfo.additionalInfo.reference_websites)>
                <cfset formData.reference_websites = projectInfo.additionalInfo.reference_websites>
            <cfelseif isSimpleValue(projectInfo.additionalInfo.reference_websites) AND len(projectInfo.additionalInfo.reference_websites)>
                <!--- Convert string to array for backward compatibility --->
                <cfset formData.reference_websites = listToArray(projectInfo.additionalInfo.reference_websites, ",")>
            </cfif>
        </cfif>
        <cfif structKeyExists(projectInfo.additionalInfo, "reference_descriptions")>
            <cfif isArray(projectInfo.additionalInfo.reference_descriptions)>
                <cfset formData.reference_descriptions = projectInfo.additionalInfo.reference_descriptions>
            <cfelseif isSimpleValue(projectInfo.additionalInfo.reference_descriptions) AND len(projectInfo.additionalInfo.reference_descriptions)>
                <!--- Convert string to array for backward compatibility --->
                <cfset formData.reference_descriptions = listToArray(projectInfo.additionalInfo.reference_descriptions, ",")>
            </cfif>
        </cfif>
        <cfif structKeyExists(projectInfo.additionalInfo, "has_branding") AND len(projectInfo.additionalInfo.has_branding)>
            <cfset formData.has_branding = projectInfo.additionalInfo.has_branding>
        </cfif>
        <cfif structKeyExists(projectInfo.additionalInfo, "need_content_writing") AND len(projectInfo.additionalInfo.need_content_writing)>
            <cfset formData.need_content_writing = projectInfo.additionalInfo.need_content_writing>
        </cfif>
        <cfif structKeyExists(projectInfo.additionalInfo, "need_maintenance") AND len(projectInfo.additionalInfo.need_maintenance)>
            <cfset formData.need_maintenance = projectInfo.additionalInfo.need_maintenance>
        </cfif>
        <cfif structKeyExists(projectInfo.additionalInfo, "additional_comments") AND len(projectInfo.additionalInfo.additional_comments)>
            <cfset formData.additional_comments = projectInfo.additionalInfo.additional_comments>
        </cfif>
        <cfif structKeyExists(projectInfo.additionalInfo, "referral_source") AND len(projectInfo.additionalInfo.referral_source)>
            <cfset formData.referral_source = projectInfo.additionalInfo.referral_source>
        </cfif>
    </cfif>
    
    
    <!--- Create database component --->
    <cftry>
        <cfset db = createObject("component", "intake.components.Database")>
        <cfcatch>
            <!--- Try alternate path --->
            <cfset db = createObject("component", "clitools.app.wwwroot.intake.components.Database")>
        </cfcatch>
    </cftry>
    
    <!--- Save or update form --->
    <cfset userId = 0>
    <cfif structKeyExists(session, "user") AND structKeyExists(session.user, "userId")>
        <cfset userId = session.user.userId>
    <cfelseif structKeyExists(session, "user") AND structKeyExists(session.user, "id")>
        <cfset userId = session.user.id>
    <cfelseif structKeyExists(session, "userId")>
        <cfset userId = session.userId>
    </cfif>
    
    
    <cfif userId EQ 0>
        <cfthrow message="User ID not found in session">
    </cfif>
    
    <cfif len(formId) AND isNumeric(formId)>
        <!--- Update existing form --->
        <cfset db.updateForm(formId, formData, userId)>
        <cfset savedFormId = formId>
    <cfelse>
        <!--- Create new form --->
        <cfset savedFormId = db.createForm(formData, userId)>
    </cfif>
    
    <!--- Get the reference_id --->
    <cfquery name="qForm" datasource="clitools">
        SELECT reference_id
        FROM IntakeForms
        WHERE form_id = <cfqueryparam value="#savedFormId#" cfsqltype="cf_sql_integer">
    </cfquery>
    
    <!--- Return success response --->
    <cfset response = {
        "success" = true,
        "formId" = savedFormId,
        "referenceId" = qForm.reference_id,
        "message" = "Chat saved as draft"
    }>
    
    <cfoutput>#serializeJSON(response)#</cfoutput>
    
    <cfcatch>
        <cfset response = {
            "success" = false,
            "error" = cfcatch.message,
            "detail" = structKeyExists(cfcatch, "detail") ? cfcatch.detail : "",
            "type" = structKeyExists(cfcatch, "type") ? cfcatch.type : "",
            "tagcontext" = structKeyExists(cfcatch, "tagcontext") AND arrayLen(cfcatch.tagcontext) ? cfcatch.tagcontext[1] : {}
        }>
        <cfoutput>#serializeJSON(response)#</cfoutput>
    </cfcatch>
</cftry>