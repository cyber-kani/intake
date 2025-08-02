<cfparam name="form.action" default="save">
<cfparam name="form.from_ai" default="false">
<cfparam name="form.is_complete" default="false">


<cftry>
    <!--- Create form data structure --->
    <cfset formData = {
        "project_type" = structKeyExists(form, "project_type") ? form.project_type : "",
        "service_type" = structKeyExists(form, "service_type") ? form.service_type : "",
        "first_name" = structKeyExists(form, "first_name") ? form.first_name : "",
        "last_name" = structKeyExists(form, "last_name") ? form.last_name : "",
        "middle_name" = structKeyExists(form, "middle_name") ? form.middle_name : "",
        "date_of_birth" = structKeyExists(form, "date_of_birth") ? form.date_of_birth : "",
        "phone_number" = structKeyExists(form, "phone_number") ? form.phone_number : "",
        "email" = structKeyExists(form, "email") ? form.email : "",
        "street_address" = structKeyExists(form, "street_address") ? form.street_address : "",
        "city" = structKeyExists(form, "city") ? form.city : "",
        "state_province" = structKeyExists(form, "state_province") ? form.state_province : "",
        "postal_code" = structKeyExists(form, "postal_code") ? form.postal_code : "",
        "country" = structKeyExists(form, "country") ? form.country : "",
        "company_name" = structKeyExists(form, "company_name") ? form.company_name : "",
        "job_title" = structKeyExists(form, "job_title") ? form.job_title : "",
        "preferred_contact_method" = structKeyExists(form, "preferred_contact_method") ? form.preferred_contact_method : "",
        "emergency_contact_name" = structKeyExists(form, "emergency_contact_name") ? form.emergency_contact_name : "",
        "emergency_contact_phone" = structKeyExists(form, "emergency_contact_phone") ? form.emergency_contact_phone : "",
        "serviceFields" = {},
        "service_category" = structKeyExists(form, "service_category") ? form.service_category : "",
        "current_website" = structKeyExists(form, "current_website") ? form.current_website : "",
        "project_description" = structKeyExists(form, "project_description") ? form.project_description : "",
        "target_audience" = structKeyExists(form, "target_audience") ? form.target_audience : "",
        "geographic_target" = structKeyExists(form, "geographic_target") ? form.geographic_target : "",
        "timeline" = structKeyExists(form, "timeline") ? form.timeline : "",
        "budget_range" = structKeyExists(form, "budget_range") ? form.budget_range : "",
        "design_style" = structKeyExists(form, "design_style") ? form.design_style : "",
        "color_preferences" = structKeyExists(form, "color_preferences") ? form.color_preferences : [],
        "features" = structKeyExists(form, "features") ? form.features : [],
        "reference_websites" = structKeyExists(form, "reference_websites") ? form.reference_websites : [],
        "reference_descriptions" = structKeyExists(form, "reference_descriptions") ? form.reference_descriptions : [],
        "has_branding" = structKeyExists(form, "has_branding") ? form.has_branding : "no",
        "need_content_writing" = structKeyExists(form, "need_content_writing") ? form.need_content_writing : "no",
        "need_maintenance" = structKeyExists(form, "need_maintenance") ? form.need_maintenance : "no",
        "additional_comments" = structKeyExists(form, "additional_comments") ? form.additional_comments : "",
        "referral_source" = structKeyExists(form, "referral_source") ? form.referral_source : "",
        "ai_conversation" = structKeyExists(form, "ai_conversation") ? form.ai_conversation : "",
        "from_ai" = structKeyExists(form, "from_ai") AND form.from_ai EQ "true" ? true : false,
        "ai_draft" = false
    }>
    
    <!--- Handle AI form fields if from_ai is true --->
    <cfif form.from_ai EQ "true">
        <!--- Map AI form fields to the correct formData structure --->
        <cfif structKeyExists(form, "project_type")>
            <cfset formData.project_type = form.project_type>
        </cfif>
        <cfif structKeyExists(form, "service_type")>
            <cfset formData.service_type = form.service_type>
        </cfif>
        <cfif structKeyExists(form, "service_category")>
            <cfset formData.service_category = form.service_category>
        </cfif>
        <cfif structKeyExists(form, "current_website")>
            <cfset formData.current_website = form.current_website>
        </cfif>
        <cfif structKeyExists(form, "project_description")>
            <cfset formData.project_description = form.project_description>
        </cfif>
        <cfif structKeyExists(form, "target_audience")>
            <cfset formData.target_audience = form.target_audience>
        </cfif>
        <cfif structKeyExists(form, "geographic_target")>
            <cfset formData.geographic_target = form.geographic_target>
        </cfif>
        <cfif structKeyExists(form, "timeline")>
            <cfset formData.timeline = form.timeline>
        </cfif>
        <cfif structKeyExists(form, "budget_range")>
            <cfset formData.budget_range = form.budget_range>
        </cfif>
        <cfif structKeyExists(form, "design_style")>
            <cfset formData.design_style = form.design_style>
        </cfif>
        <cfif structKeyExists(form, "color_preferences")>
            <cfset formData.color_preferences = form.color_preferences>
        </cfif>
        <cfif structKeyExists(form, "features")>
            <cfset formData.features = form.features>
        </cfif>
        <cfif structKeyExists(form, "reference_websites")>
            <cftry>
                <!--- Try to deserialize if it's JSON --->
                <cfif isSimpleValue(form.reference_websites) AND isJSON(form.reference_websites)>
                    <cfset formData.reference_websites = deserializeJSON(form.reference_websites)>
                <cfelseif isArray(form.reference_websites)>
                    <cfset formData.reference_websites = form.reference_websites>
                <cfelse>
                    <cfset formData.reference_websites = form.reference_websites>
                </cfif>
                <cfcatch>
                    <cfset formData.reference_websites = form.reference_websites>
                </cfcatch>
            </cftry>
        </cfif>
        <cfif structKeyExists(form, "reference_descriptions")>
            <cftry>
                <!--- Try to deserialize if it's JSON --->
                <cfif isSimpleValue(form.reference_descriptions) AND isJSON(form.reference_descriptions)>
                    <cfset formData.reference_descriptions = deserializeJSON(form.reference_descriptions)>
                <cfelseif isArray(form.reference_descriptions)>
                    <cfset formData.reference_descriptions = form.reference_descriptions>
                <cfelse>
                    <cfset formData.reference_descriptions = form.reference_descriptions>
                </cfif>
                <cfcatch>
                    <cfset formData.reference_descriptions = form.reference_descriptions>
                </cfcatch>
            </cftry>
        </cfif>
        
        <!--- Map additional AI form fields --->
        <cfif structKeyExists(form, "has_branding")>
            <cfset formData.has_branding = form.has_branding>
        </cfif>
        <cfif structKeyExists(form, "need_content_writing")>
            <cfset formData.need_content_writing = form.need_content_writing>
        </cfif>
        <cfif structKeyExists(form, "need_maintenance")>
            <cfset formData.need_maintenance = form.need_maintenance>
        </cfif>
        <cfif structKeyExists(form, "additional_comments")>
            <cfset formData.additional_comments = form.additional_comments>
        </cfif>
        <cfif structKeyExists(form, "referral_source")>
            <cfset formData.referral_source = form.referral_source>
        </cfif>
        
        <!--- Store AI conversation data if provided --->
        <cfif structKeyExists(form, "ai_conversation")>
            <cfset formData.ai_conversation = form.ai_conversation>
        </cfif>
        
        <!--- Set flags --->
        <cfset formData.from_ai = true>
        <cfset formData.ai_draft = false>
        
        <!--- If is_complete is true, set action to submit --->
        <cfif form.is_complete EQ "true">
            <cfset form.action = "submit">
        </cfif>
    </cfif>
    
    
    <!--- Collect all other service-specific fields --->
    <cfloop collection="#form#" item="fieldName">
        <cfif NOT listFindNoCase("action,service_type,first_name,last_name,middle_name,date_of_birth,phone_number,email,street_address,city,state_province,postal_code,country,company_name,job_title,preferred_contact_method,emergency_contact_name,emergency_contact_phone,fieldnames,from_ai,is_complete,form_id,reference_id,service_category,current_website,project_description,target_audience,geographic_target,timeline,budget_range,design_style,color_preferences,features,reference_websites,reference_descriptions,has_branding,need_content_writing,need_maintenance,additional_comments,referral_source,ai_conversation,project_name", fieldName)>
            <cfset formData.serviceFields[fieldName] = form[fieldName]>
        </cfif>
    </cfloop>
    
    <!--- Create database component --->
    <cfset db = createObject("component", "components.Database")>
    
    <!--- Check if updating existing form --->
    <cfif structKeyExists(form, "form_id") AND isNumeric(form.form_id) AND form.form_id GT 0>
        <!--- Update existing form --->
        <cffile action="append" 
            file="/var/www/sites/clitools.app/wwwroot/intake/debug-form-save.txt" 
            output="Updating form by form_id: #form.form_id#"
            addnewline="yes">
        <cfset db.updateForm(form.form_id, formData, session.user.userId)>
        <cfset savedFormId = form.form_id>
    <cfelseif structKeyExists(form, "reference_id") AND len(form.reference_id)>
        <!--- Try to find form by reference_id --->
        <cfquery name="qFindForm" datasource="clitools">
            SELECT form_id
            FROM IntakeForms
            WHERE reference_id = <cfqueryparam value="#form.reference_id#" cfsqltype="cf_sql_varchar">
            AND user_id = <cfqueryparam value="#session.user.userId#" cfsqltype="cf_sql_integer">
        </cfquery>
        
        <cffile action="append" 
            file="/var/www/sites/clitools.app/wwwroot/intake/debug-form-save.txt" 
            output="Looking for form by reference_id: #form.reference_id#, Found: #qFindForm.recordCount# records"
            addnewline="yes">
        
        <cfif qFindForm.recordCount GT 0>
            <!--- Update existing form found by reference_id --->
            <cffile action="append" 
                file="/var/www/sites/clitools.app/wwwroot/intake/debug-form-save.txt" 
                output="Updating form by reference_id, form_id: #qFindForm.form_id#"
                addnewline="yes">
            <cfset db.updateForm(qFindForm.form_id, formData, session.user.userId)>
            <cfset savedFormId = qFindForm.form_id>
        <cfelse>
            <!--- Create new form if reference_id not found --->
            <cffile action="append" 
                file="/var/www/sites/clitools.app/wwwroot/intake/debug-form-save.txt" 
                output="Reference ID not found, creating new form"
                addnewline="yes">
            <cfset savedFormId = db.createForm(formData, session.user.userId)>
        </cfif>
    <cfelse>
        <!--- Create new form --->
        <cffile action="append" 
            file="/var/www/sites/clitools.app/wwwroot/intake/debug-form-save.txt" 
            output="No form_id or reference_id provided, creating new form"
            addnewline="yes">
        <cfset savedFormId = db.createForm(formData, session.user.userId)>
    </cfif>
    
    <!--- Handle action --->
    <cfif form.action EQ "submit">
        <!--- Finalize the form --->
        <cffile action="append" 
            file="/var/www/sites/clitools.app/wwwroot/intake/debug-form-save.txt" 
            output="About to finalize form ID: #savedFormId# for user: #session.user.userId#"
            addnewline="yes">
            
        <cfset db.finalizeForm(savedFormId, session.user.userId)>
        
        <!--- Get the reference_id for the form --->
        <cfquery name="qCheck" datasource="clitools">
            SELECT is_finalized, submitted_at, reference_id
            FROM IntakeForms
            WHERE form_id = <cfqueryparam value="#savedFormId#" cfsqltype="cf_sql_integer">
        </cfquery>
        
        <cffile action="append" 
            file="/var/www/sites/clitools.app/wwwroot/intake/debug-form-save.txt" 
            output="After finalize - is_finalized: #qCheck.is_finalized#, submitted_at: #qCheck.submitted_at#, reference_id: #qCheck.reference_id#"
            addnewline="yes">
        
        <cfif qCheck.is_finalized NEQ 1>
            <cfthrow message="Form was not finalized. is_finalized=#qCheck.is_finalized#">
        </cfif>
        
        <!--- Log the redirect URL --->
        <cffile action="append" 
            file="/var/www/sites/clitools.app/wwwroot/intake/debug-form-save.txt" 
            output="Redirecting to: #application.basePath#/form-view.cfm?id=#qCheck.reference_id#&success=submitted"
            addnewline="yes">
        
        <!--- Redirect to dashboard after successful submission --->
        <cflocation url="#application.basePath#/dashboard.cfm?success=submitted" addtoken="false">
    <cfelse>
        <!--- Save as draft - Get reference_id --->
        <cfquery name="qDraft" datasource="clitools">
            SELECT reference_id
            FROM IntakeForms
            WHERE form_id = <cfqueryparam value="#savedFormId#" cfsqltype="cf_sql_integer">
        </cfquery>
        
        <cffile action="append" 
            file="/var/www/sites/clitools.app/wwwroot/intake/debug-form-save.txt" 
            output="Draft save - Form ID: #savedFormId#, Reference ID: #qDraft.reference_id#"
            addnewline="yes">
        
        <cfif NOT len(qDraft.reference_id)>
            <!--- This should not happen, but just in case --->
            <cflocation url="#application.basePath#/form-edit.cfm?id=#savedFormId#&success=saved" addtoken="false">
        <cfelse>
            <cflocation url="#application.basePath#/form-edit.cfm?id=#qDraft.reference_id#&success=saved" addtoken="false">
        </cfif>
    </cfif>
    
    <cfcatch>
        <cflocation url="#application.basePath#/form-new.cfm?error=#urlEncodedFormat(cfcatch.message)#" addtoken="false">
    </cfcatch>
</cftry>