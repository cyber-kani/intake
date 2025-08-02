<cfparam name="url.id" default="">

<!--- Check if user is logged in --->
<cfif NOT structKeyExists(session, "isLoggedIn") OR NOT session.isLoggedIn OR NOT structKeyExists(session, "user") OR NOT structKeyExists(session.user, "userId")>
    <cflocation url="#application.basePath#/index.cfm" addtoken="false">
</cfif>

<cftry>
<!--- Get form data --->
<cfset db = createObject("component", "components.Database")>

<!--- Check if ID is numeric (old style) or alphanumeric (form_code) --->
<cfif isNumeric(url.id)>
    <cfset qForm = db.getFormById(url.id, session.user.userId)>
<cfelse>
    <cfset qForm = db.getFormByCode(url.id, session.user.userId)>
</cfif>

<cfif qForm.recordCount EQ 0>
    <cflocation url="#application.basePath#/dashboard.cfm" addtoken="false">
</cfif>

<!--- Parse service fields --->
<cfset serviceFields = {}>
<cfset isAIForm = false>
<cftry>
    <cfset rawData = deserializeJSON(qForm.form_data)>
    
    <!--- Check if this is an AI form --->
    <cfif structKeyExists(rawData, "ai_conversation") OR (structKeyExists(rawData, "ai_draft") AND rawData.ai_draft EQ true) OR structKeyExists(rawData, "from_ai") AND rawData.from_ai EQ true>
        <cfset isAIForm = true>
        
        <!--- Try to extract data from ai_conversation field first --->
        <cfif structKeyExists(rawData, "ai_conversation") AND isSimpleValue(rawData.ai_conversation) AND len(rawData.ai_conversation)>
            <cftry>
                <cfset aiConvoData = deserializeJSON(rawData.ai_conversation)>
                <cfif structKeyExists(aiConvoData, "projectInfo") AND isStruct(aiConvoData.projectInfo)>
                    <cfset aiProjectInfo = aiConvoData.projectInfo>
                    
                    <!--- Extract basic info --->
                    <cfif structKeyExists(aiProjectInfo, "basicInfo") AND isStruct(aiProjectInfo.basicInfo)>
                        <cfloop collection="#aiProjectInfo.basicInfo#" item="key">
                            <cfif len(trim(aiProjectInfo.basicInfo[key]))>
                                <cfset mappedKey = lcase(key)>
                                <cfif mappedKey EQ "phone">
                                    <cfset rawData["phone_number"] = aiProjectInfo.basicInfo[key]>
                                <cfelseif mappedKey EQ "company">
                                    <cfset rawData["company_name"] = aiProjectInfo.basicInfo[key]>
                                <cfelseif mappedKey EQ "contact_method">
                                    <cfset rawData["preferred_contact_method"] = aiProjectInfo.basicInfo[key]>
                                <cfelseif mappedKey EQ "website">
                                    <cfset rawData["current_website"] = aiProjectInfo.basicInfo[key]>
                                <cfelse>
                                    <cfset rawData[mappedKey] = aiProjectInfo.basicInfo[key]>
                                </cfif>
                            </cfif>
                        </cfloop>
                    </cfif>
                    
                    <!--- Extract project details --->
                    <cfif structKeyExists(aiProjectInfo, "projectDetails") AND isStruct(aiProjectInfo.projectDetails)>
                        <cfloop collection="#aiProjectInfo.projectDetails#" item="key">
                            <cfif len(trim(aiProjectInfo.projectDetails[key]))>
                                <cfset mappedKey = lcase(key)>
                                <cfif mappedKey EQ "description">
                                    <cfset rawData["project_description"] = aiProjectInfo.projectDetails[key]>
                                <cfelseif mappedKey EQ "budget">
                                    <cfset rawData["budget_range"] = aiProjectInfo.projectDetails[key]>
                                <cfelse>
                                    <cfset rawData[mappedKey] = aiProjectInfo.projectDetails[key]>
                                </cfif>
                            </cfif>
                        </cfloop>
                    </cfif>
                    
                    <!--- Extract design features --->
                    <cfif structKeyExists(aiProjectInfo, "designFeatures") AND isStruct(aiProjectInfo.designFeatures)>
                        <cfloop collection="#aiProjectInfo.designFeatures#" item="key">
                            <cfset mappedKey = lcase(key)>
                            <cfif mappedKey EQ "style">
                                <cfset rawData["design_style"] = aiProjectInfo.designFeatures[key]>
                            <cfelseif mappedKey EQ "colors" AND isArray(aiProjectInfo.designFeatures[key])>
                                <cfset rawData["color_preferences"] = aiProjectInfo.designFeatures[key]>
                            <cfelseif mappedKey EQ "features" AND isArray(aiProjectInfo.designFeatures[key])>
                                <cfset rawData["features"] = aiProjectInfo.designFeatures[key]>
                            </cfif>
                        </cfloop>
                    </cfif>
                    
                    <!--- Extract additional info (reference websites, etc.) --->
                    <cfif structKeyExists(aiProjectInfo, "additionalInfo") AND isStruct(aiProjectInfo.additionalInfo)>
                        <cfloop collection="#aiProjectInfo.additionalInfo#" item="key">
                            <cfset mappedKey = lcase(key)>
                            <cfif mappedKey EQ "reference_websites" AND isArray(aiProjectInfo.additionalInfo[key])>
                                <cfset rawData["reference_websites"] = aiProjectInfo.additionalInfo[key]>
                            <cfelseif mappedKey EQ "reference_descriptions" AND isArray(aiProjectInfo.additionalInfo[key])>
                                <cfset rawData["reference_descriptions"] = aiProjectInfo.additionalInfo[key]>
                            <cfelse>
                                <cfset rawData[mappedKey] = aiProjectInfo.additionalInfo[key]>
                            </cfif>
                        </cfloop>
                    </cfif>
                    
                    <!--- Also get project type and service type from projectInfo --->
                    <cfif structKeyExists(aiProjectInfo, "project_type") AND len(aiProjectInfo.project_type)>
                        <cfset rawData["project_type"] = aiProjectInfo.project_type>
                    </cfif>
                    <cfif structKeyExists(aiProjectInfo, "service_type") AND len(aiProjectInfo.service_type)>
                        <cfset rawData["service_type"] = aiProjectInfo.service_type>
                    </cfif>
                </cfif>
                <cfcatch>
                    <!--- If parsing ai_conversation fails, continue with regular extraction --->
                </cfcatch>
            </cftry>
        </cfif>
        
        <!--- Also check for direct nested structures in rawData --->
        <cfif structKeyExists(rawData, "basicInfo") AND isStruct(rawData.basicInfo)>
            <cfloop collection="#rawData.basicInfo#" item="key">
                <cfif len(trim(rawData.basicInfo[key]))>
                    <cfset mappedKey = lcase(key)>
                    <cfif mappedKey EQ "phone">
                        <cfset rawData["phone_number"] = rawData.basicInfo[key]>
                    <cfelseif mappedKey EQ "company">
                        <cfset rawData["company_name"] = rawData.basicInfo[key]>
                    <cfelseif mappedKey EQ "contact_method">
                        <cfset rawData["preferred_contact_method"] = rawData.basicInfo[key]>
                    <cfelseif mappedKey EQ "website">
                        <cfset rawData["current_website"] = rawData.basicInfo[key]>
                    <cfelse>
                        <cfset rawData[mappedKey] = rawData.basicInfo[key]>
                    </cfif>
                </cfif>
            </cfloop>
        </cfif>
        
        <cfif structKeyExists(rawData, "projectDetails") AND isStruct(rawData.projectDetails)>
            <cfloop collection="#rawData.projectDetails#" item="key">
                <cfif len(trim(rawData.projectDetails[key]))>
                    <cfset mappedKey = lcase(key)>
                    <cfif mappedKey EQ "description">
                        <cfset rawData["project_description"] = rawData.projectDetails[key]>
                    <cfelseif mappedKey EQ "budget">
                        <cfset rawData["budget_range"] = rawData.projectDetails[key]>
                    <cfelse>
                        <cfset rawData[mappedKey] = rawData.projectDetails[key]>
                    </cfif>
                </cfif>
            </cfloop>
        </cfif>
        
        <cfif structKeyExists(rawData, "designFeatures") AND isStruct(rawData.designFeatures)>
            <cfloop collection="#rawData.designFeatures#" item="key">
                <cfset mappedKey = lcase(key)>
                <cfif mappedKey EQ "style">
                    <cfset rawData["design_style"] = rawData.designFeatures[key]>
                <cfelseif mappedKey EQ "colors" AND isArray(rawData.designFeatures[key])>
                    <cfset rawData["color_preferences"] = rawData.designFeatures[key]>
                <cfelseif mappedKey EQ "features" AND isArray(rawData.designFeatures[key])>
                    <cfset rawData["features"] = rawData.designFeatures[key]>
                </cfif>
            </cfloop>
        </cfif>
        
        <cfif structKeyExists(rawData, "additionalInfo") AND isStruct(rawData.additionalInfo)>
            <cfloop collection="#rawData.additionalInfo#" item="key">
                <cfset mappedKey = lcase(key)>
                <cfif mappedKey EQ "reference_websites" AND isArray(rawData.additionalInfo[key])>
                    <cfset rawData["reference_websites"] = rawData.additionalInfo[key]>
                <cfelseif mappedKey EQ "reference_descriptions" AND isArray(rawData.additionalInfo[key])>
                    <cfset rawData["reference_descriptions"] = rawData.additionalInfo[key]>
                <cfelse>
                    <cfset rawData[mappedKey] = rawData.additionalInfo[key]>
                </cfif>
            </cfloop>
        </cfif>
    </cfif>
    
    <!--- First, use raw data as base --->
    <cfset serviceFields = duplicate(rawData)>
    
    <!--- Then merge any nested serviceFields --->
    <cfif structKeyExists(rawData, "serviceFields") AND isStruct(rawData.serviceFields)>
        <cfloop collection="#rawData.serviceFields#" item="key">
            <cfset serviceFields[key] = rawData.serviceFields[key]>
        </cfloop>
    </cfif>
    <cfcatch type="any">
        <!--- Log the error for debugging --->
        <cflog file="form-view-errors" text="Error parsing form data for form #url.id#: #cfcatch.message# - #cfcatch.detail#">
        <cfset serviceFields = {}>
        <!--- Set a flag to show error message --->
        <cfset hasParsingError = true>
        <cfset errorMessage = cfcatch.message>
    </cfcatch>
</cftry>

<cfinclude template="includes/header.cfm">

<div class="container mt-4">
    <div class="row justify-content-center">
        <div class="col-md-10">
            <div class="d-flex justify-content-between align-items-center mb-4">
                <div>
                    <h2 class="mb-1">Customer Intake Form <cfif isAIForm><span class="badge bg-info ms-2"><i class="fas fa-robot"></i> AI Form</span></cfif></h2>
                    <p class="text-muted mb-0">Form ID: <cfoutput>#structKeyExists(qForm, "reference_id") AND len(qForm.reference_id) ? qForm.reference_id : "##" & qForm.form_id#</cfoutput></p>
                </div>
                <div>
                    <button onclick="window.print()" class="btn btn-outline-secondary btn-sm me-2">
                        Print
                    </button>
                    <a href="<cfoutput>#application.basePath#</cfoutput>/dashboard.cfm" class="btn btn-primary btn-sm">
                        Back
                    </a>
                </div>
            </div>
            
            <cfif structKeyExists(url, "success") AND url.success EQ "submitted">
                <div class="alert alert-success alert-dismissible fade show">
                    Form submitted successfully!
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            </cfif>
            
            <div class="card border">
                <div class="card-body">
                    <!--- Debug for AI forms --->
                    <cfif isAIForm AND structKeyExists(url, "debug")>
                        <div class="alert alert-info">
                            <h6>AI Form Debug Info:</h6>
                            <p>Is AI Form: <cfoutput>#isAIForm#</cfoutput></p>
                            <p>ServiceFields keys: <cfoutput>#structKeyList(serviceFields)#</cfoutput></p>
                            <cfif structKeyExists(serviceFields, "basicInfo")>
                                <p>BasicInfo keys: <cfoutput>#structKeyList(serviceFields.basicInfo)#</cfoutput></p>
                            </cfif>
                            <cfif structKeyExists(serviceFields, "projectDetails")>
                                <p>ProjectDetails keys: <cfoutput>#structKeyList(serviceFields.projectDetails)#</cfoutput></p>
                            </cfif>
                            <cfif structKeyExists(serviceFields, "designFeatures")>
                                <p>DesignFeatures keys: <cfoutput>#structKeyList(serviceFields.designFeatures)#</cfoutput></p>
                            </cfif>
                        </div>
                    </cfif>
                    
                    <!--- Project Type (Step 1) --->
                    <cfif structKeyExists(qForm, "project_type") AND len(trim(qForm.project_type))>
                        <div class="mb-4">
                            <h5 class="border-bottom pb-2 mb-3">Project Type</h5>
                            <div class="p-3 bg-light rounded">
                                <cfset projectTypeDisplay = qForm.project_type>
                                <cfset badgeClass = "bg-secondary">
                                
                                <!--- Determine badge color and display name based on project type --->
                                <cfswitch expression="#lcase(qForm.project_type)#">
                                    <cfcase value="website">
                                        <cfset projectTypeDisplay = "Website">
                                        <cfset badgeClass = "bg-primary">
                                    </cfcase>
                                    <cfcase value="mobile_app,app">
                                        <cfset projectTypeDisplay = "Mobile App">
                                        <cfset badgeClass = "bg-success">
                                    </cfcase>
                                    <cfcase value="saas,software">
                                        <cfset projectTypeDisplay = "SaaS Platform">
                                        <cfset badgeClass = "bg-info">
                                    </cfcase>
                                    <cfcase value="ecommerce,e_commerce">
                                        <cfset projectTypeDisplay = "E-Commerce">
                                        <cfset badgeClass = "bg-warning text-dark">
                                    </cfcase>
                                    <cfcase value="custom">
                                        <cfset projectTypeDisplay = "Custom Project">
                                        <cfset badgeClass = "bg-secondary">
                                    </cfcase>
                                    <cfdefaultcase>
                                        <!--- Capitalize first letter of each word --->
                                        <cfset projectTypeDisplay = reReplace(replace(qForm.project_type, "_", " ", "all"), "\b(\w)", "\u\1", "all")>
                                    </cfdefaultcase>
                                </cfswitch>
                                
                                <span class="badge <cfoutput>#badgeClass#</cfoutput> fs-6 px-3 py-2">
                                    <cfoutput>#projectTypeDisplay#</cfoutput>
                                </span>
                            </div>
                        </div>
                    </cfif>
                    
                    <!--- Service Type --->
                    <div class="mb-4">
                        <h5 class="border-bottom pb-2 mb-3">Service Type</h5>
                        <cfset serviceDisplay = "">
                        <cfset serviceTypeValue = qForm.service_type>
                        
                        <!--- Debug service type --->
                        <cfif structKeyExists(url, "debug")>
                            <div class="alert alert-info small">
                                <strong>Debug:</strong> service_type = <cfoutput>#qForm.service_type#</cfoutput>
                            </div>
                        </cfif>
                        
                        <!--- If service_type is empty, try to get it from form_data JSON --->
                        <cfif NOT len(trim(serviceTypeValue)) AND structKeyExists(serviceFields, "service_type")>
                            <cfset serviceTypeValue = serviceFields.service_type>
                        </cfif>
                        
                        <cfif len(trim(serviceTypeValue))>
                            <!--- Try to parse the service type --->
                            <cfif findNoCase("_", serviceTypeValue)>
                                <cfset parts = listToArray(serviceTypeValue, "_")>
                                
                                <!--- Try different split points since categories can have underscores --->
                                <cfloop from="1" to="#arrayLen(parts)-1#" index="splitIdx">
                                    <cfset possibleCategory = arrayToList(arraySlice(parts, 1, splitIdx), "_")>
                                    <cfset possibleService = arrayToList(arraySlice(parts, splitIdx + 1), "_")>
                                    
                                    <cfif structKeyExists(application.serviceCategories, possibleCategory)>
                                        <cfset cat = application.serviceCategories[possibleCategory]>
                                        <cfif structKeyExists(cat.services, possibleService)>
                                            <cfset serviceDisplay = cat.services[possibleService]>
                                            <cfbreak>
                                        </cfif>
                                    </cfif>
                                </cfloop>
                            </cfif>
                        </cfif>
                        
                        <div class="p-3 bg-light rounded">
                            <cfif len(serviceDisplay)>
                                <h6 class="mb-0"><cfoutput>#serviceDisplay#</cfoutput></h6>
                            <cfelseif len(trim(serviceTypeValue))>
                                <!--- Parse service type to make it human readable --->
                                <cfset displayValue = serviceTypeValue>
                                <cfset serviceCategory = "">
                                <cfset serviceType = "">
                                
                                <!--- Check if it's in format like "website_design" or "app_development" --->
                                <cfif findNoCase("_", serviceTypeValue)>
                                    <cfset firstUnderscore = find("_", serviceTypeValue)>
                                    <cfset serviceCategory = left(serviceTypeValue, firstUnderscore - 1)>
                                    <cfset serviceType = mid(serviceTypeValue, firstUnderscore + 1, len(serviceTypeValue))>
                                    
                                    <!--- Make service type human readable --->
                                    <cfset serviceType = replace(serviceType, "_", " ", "all")>
                                    <cfset serviceType = reReplace(serviceType, "\b(\w)", "\u\1", "all")>
                                    
                                    <!--- Determine badge color based on category --->
                                    <cfset badgeClass = "bg-secondary">
                                    <cfswitch expression="#lcase(serviceCategory)#">
                                        <cfcase value="website"><cfset badgeClass = "bg-primary"></cfcase>
                                        <cfcase value="app,mobile_app"><cfset badgeClass = "bg-success"></cfcase>
                                        <cfcase value="saas,software"><cfset badgeClass = "bg-info"></cfcase>
                                        <cfcase value="ecommerce,e_commerce"><cfset badgeClass = "bg-warning text-dark"></cfcase>
                                    </cfswitch>
                                    
                                    <div class="d-flex align-items-center gap-2">
                                        <span class="badge <cfoutput>#badgeClass#</cfoutput>"><cfoutput>#ucase(serviceCategory)#</cfoutput></span>
                                        <h6 class="mb-0"><cfoutput>#serviceType#</cfoutput></h6>
                                    </div>
                                <cfelse>
                                    <!--- If no underscore, just display as is but capitalize --->
                                    <cfset displayValue = reReplace(serviceTypeValue, "\b(\w)", "\u\1", "all")>
                                    <h6 class="mb-0"><cfoutput>#displayValue#</cfoutput></h6>
                                </cfif>
                            <cfelse>
                                <h6 class="mb-0 text-muted">Not specified</h6>
                            </cfif>
                        </div>
                    </div>
                    
                    <!--- Form Metadata --->
                    <div class="mb-4">
                        <h5 class="border-bottom pb-2 mb-3">Form Information</h5>
                        <div class="row g-3">
                            <div class="col-md-3">
                                <div class="text-center">
                                    <small class="text-muted d-block">Form ID</small>
                                    <strong><cfoutput>#structKeyExists(qForm, "reference_id") AND len(qForm.reference_id) ? qForm.reference_id : "##" & qForm.form_id#</cfoutput></strong>
                                </div>
                            </div>
                            <div class="col-md-3">
                                <div class="text-center">
                                    <small class="text-muted d-block">Status</small>
                                    <cfif qForm.is_finalized>
                                        <span class="badge bg-success">Submitted</span>
                                    <cfelse>
                                        <span class="badge bg-warning text-dark">Draft</span>
                                    </cfif>
                                </div>
                            </div>
                            <div class="col-md-3">
                                <div class="text-center">
                                    <small class="text-muted d-block">Created</small>
                                    <strong><cfoutput>#dateTimeFormat(qForm.created_at, "mm/dd/yyyy")#</cfoutput></strong>
                                </div>
                            </div>
                            <cfif qForm.is_finalized AND isDate(qForm.submitted_at)>
                                <div class="col-md-3">
                                    <div class="text-center">
                                        <small class="text-muted d-block">Submitted</small>
                                        <strong><cfoutput>#dateTimeFormat(qForm.submitted_at, "mm/dd/yyyy")#</cfoutput></strong>
                                    </div>
                                </div>
                            </cfif>
                        </div>
                    </div>
                    
                    <!--- Contact Information Section --->
                    <cfset contactFields = ['name', 'first_name', 'last_name', 'email', 'phone', 'phone_number', 'company', 'company_name', 'industry', 'preferred_contact_method', 'current_website', 'website', 'contact_method', 'job_title', 'street_address', 'city', 'state_province', 'postal_code', 'country']>
                    <cfset hasContactInfo = false>
                    
                    <!--- First check regular fields --->
                    <cfloop collection="#serviceFields#" item="fieldName">
                        <cfif listFindNoCase(arrayToList(contactFields), fieldName) AND isSimpleValue(serviceFields[fieldName]) AND len(trim(serviceFields[fieldName]))>
                            <cfset hasContactInfo = true>
                            <cfbreak>
                        </cfif>
                    </cfloop>
                    
                    <!--- If no contact info found, check basicInfo structure --->
                    <cfif NOT hasContactInfo AND structKeyExists(serviceFields, "basicInfo") AND isStruct(serviceFields.basicInfo)>
                        <cfloop collection="#serviceFields.basicInfo#" item="fieldName">
                            <cfif isSimpleValue(serviceFields.basicInfo[fieldName]) AND len(trim(serviceFields.basicInfo[fieldName]))>
                                <cfset hasContactInfo = true>
                                <cfbreak>
                            </cfif>
                        </cfloop>
                    </cfif>
                    
                    <cfif hasContactInfo>
                        <div class="mb-4">
                            <h5 class="border-bottom pb-2 mb-3">Contact Information</h5>
                            <div class="row g-3">
                                <!--- First show regular contact fields --->
                                <cfloop collection="#serviceFields#" item="fieldName">
                                    <cfif listFindNoCase(arrayToList(contactFields), fieldName) AND isSimpleValue(serviceFields[fieldName]) AND len(trim(serviceFields[fieldName]))>
                                        <cfset fieldValue = serviceFields[fieldName]>
                                        <div class="col-md-6">
                                            <div class="mb-3">
                                                <small class="text-muted d-block mb-1">
                                                    <cfset displayName = replace(fieldName, "_", " ", "all")>
                                                    <cfset displayName = reReplace(displayName, "\b(\w)", "\u\1", "all")>
                                                    <cfoutput>#displayName#</cfoutput>
                                                </small>
                                                <div>
                                                    <cfswitch expression="#fieldName#">
                                                        <cfcase value="preferred_contact_method,contact_method">
                                                            <cfswitch expression="#fieldValue#">
                                                                <cfcase value="email">Email</cfcase>
                                                                <cfcase value="phone">Phone</cfcase>
                                                                <cfcase value="text">Text Message</cfcase>
                                                                <cfcase value="whatsapp">WhatsApp</cfcase>
                                                                <cfdefaultcase>
                                                            <cfif isSimpleValue(fieldValue)>
                                                                <cfoutput>#fieldValue#</cfoutput>
                                                            <cfelse>
                                                                <cfoutput>#serializeJSON(fieldValue)#</cfoutput>
                                                            </cfif>
                                                        </cfdefaultcase>
                                                            </cfswitch>
                                                        </cfcase>
                                                        <cfcase value="email">
                                                            <a href="mailto:<cfoutput>#fieldValue#</cfoutput>" class="text-decoration-none"><cfoutput>#fieldValue#</cfoutput></a>
                                                        </cfcase>
                                                        <cfcase value="phone,phone_number">
                                                            <a href="tel:<cfoutput>#fieldValue#</cfoutput>" class="text-decoration-none"><cfoutput>#fieldValue#</cfoutput></a>
                                                        </cfcase>
                                                        <cfdefaultcase>
                                                            <cfif isSimpleValue(fieldValue)>
                                                                <cfoutput>#fieldValue#</cfoutput>
                                                            <cfelse>
                                                                <cfoutput>#serializeJSON(fieldValue)#</cfoutput>
                                                            </cfif>
                                                        </cfdefaultcase>
                                                    </cfswitch>
                                                </div>
                                            </div>
                                        </div>
                                    </cfif>
                                </cfloop>
                                
                                <!--- Then show fields from basicInfo if it exists --->
                                <cfif structKeyExists(serviceFields, "basicInfo") AND isStruct(serviceFields.basicInfo)>
                                    <cfloop collection="#serviceFields.basicInfo#" item="fieldName">
                                        <cfset fieldValue = serviceFields.basicInfo[fieldName]>
                                        <cfif isSimpleValue(fieldValue) AND len(trim(fieldValue))>
                                            <div class="col-md-6">
                                                <div class="mb-3">
                                                    <small class="text-muted d-block mb-1">
                                                        <cfset displayName = replace(fieldName, "_", " ", "all")>
                                                        <cfset displayName = reReplace(displayName, "\b(\w)", "\u\1", "all")>
                                                        <cfoutput>#displayName#</cfoutput>
                                                    </small>
                                                    <div>
                                                        <cfswitch expression="#lcase(fieldName)#">
                                                            <cfcase value="contact_method">
                                                                <cfswitch expression="#fieldValue#">
                                                                    <cfcase value="email">Email</cfcase>
                                                                    <cfcase value="phone">Phone</cfcase>
                                                                    <cfcase value="text">Text Message</cfcase>
                                                                    <cfcase value="whatsapp">WhatsApp</cfcase>
                                                                    <cfdefaultcase><cfoutput>#fieldValue#</cfoutput></cfdefaultcase>
                                                                </cfswitch>
                                                            </cfcase>
                                                            <cfcase value="email">
                                                                <a href="mailto:<cfoutput>#fieldValue#</cfoutput>" class="text-decoration-none"><cfoutput>#fieldValue#</cfoutput></a>
                                                            </cfcase>
                                                            <cfcase value="phone">
                                                                <a href="tel:<cfoutput>#fieldValue#</cfoutput>" class="text-decoration-none"><cfoutput>#fieldValue#</cfoutput></a>
                                                            </cfcase>
                                                            <cfdefaultcase>
                                                                <cfoutput>#fieldValue#</cfoutput>
                                                            </cfdefaultcase>
                                                        </cfswitch>
                                                    </div>
                                                </div>
                                            </div>
                                        </cfif>
                                    </cfloop>
                                </cfif>
                            </div>
                        </div>
                    </cfif>
                    
                    <!--- Project Details Section --->
                    <cfset projectFields = ['budget_range', 'timeline', 'project_description', 'goals', 'target_audience', 'geographic_target', 'budget', 'description']>
                    <cfset hasProjectDetails = false>
                    
                    <!--- Check regular fields --->
                    <cfloop collection="#serviceFields#" item="fieldName">
                        <cfif listFindNoCase(arrayToList(projectFields), fieldName) AND isSimpleValue(serviceFields[fieldName]) AND len(trim(serviceFields[fieldName]))>
                            <cfset hasProjectDetails = true>
                            <cfbreak>
                        </cfif>
                    </cfloop>
                    
                    <!--- Check projectDetails structure --->
                    <cfif NOT hasProjectDetails AND structKeyExists(serviceFields, "projectDetails") AND isStruct(serviceFields.projectDetails)>
                        <cfloop collection="#serviceFields.projectDetails#" item="fieldName">
                            <cfif isSimpleValue(serviceFields.projectDetails[fieldName]) AND len(trim(serviceFields.projectDetails[fieldName]))>
                                <cfset hasProjectDetails = true>
                                <cfbreak>
                            </cfif>
                        </cfloop>
                    </cfif>
                    
                    <cfif hasProjectDetails>
                        <div class="mb-4">
                            <h5 class="border-bottom pb-2 mb-3">Project Details</h5>
                            <div class="row g-3">
                                <cfloop collection="#serviceFields#" item="fieldName">
                                    <cfif listFindNoCase(arrayToList(projectFields), fieldName) AND isSimpleValue(serviceFields[fieldName]) AND len(trim(serviceFields[fieldName]))>
                                        <cfset fieldValue = serviceFields[fieldName]>
                                        <div class="<cfif fieldName CONTAINS 'description' OR len(fieldValue) GT 100>col-12<cfelse>col-md-6</cfif>">
                                            <div class="mb-3">
                                                <small class="text-muted d-block mb-1">
                                                    <cfset displayName = replace(fieldName, "_", " ", "all")>
                                                    <cfset displayName = reReplace(displayName, "\b(\w)", "\u\1", "all")>
                                                    <cfoutput>#displayName#</cfoutput>
                                                </small>
                                                <div>
                                                    <cfswitch expression="#fieldName#">
                                                        <cfcase value="timeline">
                                                            <cfswitch expression="#fieldValue#">
                                                                <cfcase value="asap"><span class="badge bg-danger">ASAP</span></cfcase>
                                                                <cfcase value="1_month"><span class="badge bg-warning text-dark">Within 1 month</span></cfcase>
                                                                <cfcase value="2_months"><span class="badge bg-info">Within 2 months</span></cfcase>
                                                                <cfcase value="3_months"><span class="badge bg-primary">Within 3 months</span></cfcase>
                                                                <cfcase value="6_months"><span class="badge bg-secondary">Within 6 months</span></cfcase>
                                                                <cfcase value="flexible"><span class="badge bg-success">Flexible</span></cfcase>
                                                                <cfdefaultcase>
                                                            <cfif isSimpleValue(fieldValue)>
                                                                <cfoutput>#fieldValue#</cfoutput>
                                                            <cfelse>
                                                                <cfoutput>#serializeJSON(fieldValue)#</cfoutput>
                                                            </cfif>
                                                        </cfdefaultcase>
                                                            </cfswitch>
                                                        </cfcase>
                                                        <cfcase value="budget_range">
                                                            <cfswitch expression="#fieldValue#">
                                                                <cfcase value="under_1000,under_1k"><span class="badge bg-light text-dark">Under $1,000</span></cfcase>
                                                                <cfcase value="1k_5k"><span class="badge bg-primary">$1,000 - $5,000</span></cfcase>
                                                                <cfcase value="5k_10k"><span class="badge bg-info">$5,000 - $10,000</span></cfcase>
                                                                <cfcase value="10k_25k"><span class="badge bg-success">$10,000 - $25,000</span></cfcase>
                                                                <cfcase value="25k_50k"><span class="badge bg-warning text-dark">$25,000 - $50,000</span></cfcase>
                                                                <cfcase value="50k_plus"><span class="badge bg-danger">$50,000+</span></cfcase>
                                                                <cfcase value="not_sure"><span class="badge bg-secondary">Not sure yet</span></cfcase>
                                                                <cfdefaultcase>
                                                            <cfif isSimpleValue(fieldValue)>
                                                                <cfoutput>#fieldValue#</cfoutput>
                                                            <cfelse>
                                                                <cfoutput>#serializeJSON(fieldValue)#</cfoutput>
                                                            </cfif>
                                                        </cfdefaultcase>
                                                            </cfswitch>
                                                        </cfcase>
                                                        <cfdefaultcase>
                                                            <cfif fieldName CONTAINS "description" OR (isSimpleValue(fieldValue) AND len(fieldValue) GT 100)>
                                                                <div class="p-3 bg-light rounded border-start border-primary border-3">
                                                                    <cfif isSimpleValue(fieldValue)>
                                                                        <cfoutput>#replace(fieldValue, chr(10), "<br>", "all")#</cfoutput>
                                                                    <cfelse>
                                                                        <cfoutput>#serializeJSON(fieldValue)#</cfoutput>
                                                                    </cfif>
                                                                </div>
                                                            <cfelse>
                                                                <cfif isSimpleValue(fieldValue)>
                                                                    <cfoutput>#fieldValue#</cfoutput>
                                                                <cfelse>
                                                                    <cfoutput>#serializeJSON(fieldValue)#</cfoutput>
                                                                </cfif>
                                                            </cfif>
                                                        </cfdefaultcase>
                                                    </cfswitch>
                                                </div>
                                            </div>
                                        </div>
                                    </cfif>
                                </cfloop>
                                
                                <!--- Show fields from projectDetails structure --->
                                <cfif structKeyExists(serviceFields, "projectDetails") AND isStruct(serviceFields.projectDetails)>
                                    <cfloop collection="#serviceFields.projectDetails#" item="fieldName">
                                        <cfset fieldValue = serviceFields.projectDetails[fieldName]>
                                        <cfif isSimpleValue(fieldValue) AND len(trim(fieldValue))>
                                            <cfset displayFieldName = fieldName>
                                            <cfif fieldName EQ "description">
                                                <cfset displayFieldName = "project_description">
                                            <cfelseif fieldName EQ "budget">
                                                <cfset displayFieldName = "budget_range">
                                            </cfif>
                                            
                                            <div class="<cfif displayFieldName CONTAINS 'description' OR len(fieldValue) GT 100>col-12<cfelse>col-md-6</cfif>">
                                                <div class="mb-3">
                                                    <small class="text-muted d-block mb-1">
                                                        <cfset displayName = replace(displayFieldName, "_", " ", "all")>
                                                        <cfset displayName = reReplace(displayName, "\b(\w)", "\u\1", "all")>
                                                        <cfoutput>#displayName#</cfoutput>
                                                    </small>
                                                    <div>
                                                        <cfswitch expression="#fieldName#">
                                                            <cfcase value="timeline">
                                                                <cfswitch expression="#fieldValue#">
                                                                    <cfcase value="asap"><span class="badge bg-danger">ASAP</span></cfcase>
                                                                    <cfcase value="1_month"><span class="badge bg-warning text-dark">Within 1 month</span></cfcase>
                                                                    <cfcase value="2_months"><span class="badge bg-info">Within 2 months</span></cfcase>
                                                                    <cfcase value="3_months"><span class="badge bg-primary">Within 3 months</span></cfcase>
                                                                    <cfcase value="6_months"><span class="badge bg-secondary">Within 6 months</span></cfcase>
                                                                    <cfcase value="flexible"><span class="badge bg-success">Flexible</span></cfcase>
                                                                    <cfdefaultcase><cfoutput>#fieldValue#</cfoutput></cfdefaultcase>
                                                                </cfswitch>
                                                            </cfcase>
                                                            <cfcase value="budget,budget_range">
                                                                <cfswitch expression="#fieldValue#">
                                                                    <cfcase value="under_1000,under_1k"><span class="badge bg-light text-dark">Under $1,000</span></cfcase>
                                                                    <cfcase value="1k_5k"><span class="badge bg-primary">$1,000 - $5,000</span></cfcase>
                                                                    <cfcase value="5k_10k"><span class="badge bg-info">$5,000 - $10,000</span></cfcase>
                                                                    <cfcase value="10k_25k"><span class="badge bg-success">$10,000 - $25,000</span></cfcase>
                                                                    <cfcase value="25k_50k"><span class="badge bg-warning text-dark">$25,000 - $50,000</span></cfcase>
                                                                    <cfcase value="50k_plus"><span class="badge bg-danger">$50,000+</span></cfcase>
                                                                    <cfcase value="not_sure"><span class="badge bg-secondary">Not sure yet</span></cfcase>
                                                                    <cfdefaultcase><cfoutput>#fieldValue#</cfoutput></cfdefaultcase>
                                                                </cfswitch>
                                                            </cfcase>
                                                            <cfcase value="geographic_target">
                                                                <cfswitch expression="#fieldValue#">
                                                                    <cfcase value="local">Local (City/Region)</cfcase>
                                                                    <cfcase value="national">National</cfcase>
                                                                    <cfcase value="international">International</cfcase>
                                                                    <cfcase value="specific">Specific Countries/Regions</cfcase>
                                                                    <cfdefaultcase><cfoutput>#fieldValue#</cfoutput></cfdefaultcase>
                                                                </cfswitch>
                                                            </cfcase>
                                                            <cfdefaultcase>
                                                                <cfif displayFieldName CONTAINS "description" OR (isSimpleValue(fieldValue) AND len(fieldValue) GT 100)>
                                                                    <div class="p-3 bg-light rounded border-start border-primary border-3">
                                                                        <cfoutput>#replace(fieldValue, chr(10), "<br>", "all")#</cfoutput>
                                                                    </div>
                                                                <cfelse>
                                                                    <cfoutput>#fieldValue#</cfoutput>
                                                                </cfif>
                                                            </cfdefaultcase>
                                                        </cfswitch>
                                                    </div>
                                                </div>
                                            </div>
                                        </cfif>
                                    </cfloop>
                                </cfif>
                            </div>
                        </div>
                    </cfif>
                    
                    <!--- Website Information --->
                    <cfset websiteField = "">
                    <cfif structKeyExists(serviceFields, "current_website") AND len(trim(serviceFields.current_website))>
                        <cfset websiteField = serviceFields.current_website>
                    <cfelseif structKeyExists(serviceFields, "website") AND len(trim(serviceFields.website))>
                        <cfset websiteField = serviceFields.website>
                    <cfelseif structKeyExists(serviceFields, "basicInfo") AND isStruct(serviceFields.basicInfo) AND structKeyExists(serviceFields.basicInfo, "website") AND len(trim(serviceFields.basicInfo.website))>
                        <cfset websiteField = serviceFields.basicInfo.website>
                    </cfif>
                    
                    <cfif len(websiteField)>
                        <div class="mb-4">
                            <h5 class="border-bottom pb-2 mb-3">Current Website</h5>
                            <div class="p-3 bg-light rounded">
                                <cfif websiteField NEQ "no" AND websiteField NEQ "none">
                                    <a href="<cfoutput>#websiteField#</cfoutput>" target="_blank" class="text-decoration-none">
                                        <cfoutput>#websiteField#</cfoutput>
                                    </a>
                                <cfelse>
                                    <span class="text-muted">No existing website</span>
                                </cfif>
                            </div>
                        </div>
                    </cfif>
                    
                    <!--- Debug: Check features fields --->
                    <cfif structKeyExists(url, "debug") AND url.debug EQ "features">
                        <div class="alert alert-info">
                            <h6>Debug: All ServiceFields Keys</h6>
                            <p>Keys: <cfoutput>#structKeyList(serviceFields)#</cfoutput></p>
                            <hr>
                            <h6>Looking for Features Fields:</h6>
                            <cfloop collection="#serviceFields#" item="key">
                                <cfif findNoCase("feature", key)>
                                    <p><strong><cfoutput>#key#</cfoutput>:</strong> 
                                        <cfif isSimpleValue(serviceFields[key])>
                                            <cfoutput>#serviceFields[key]#</cfoutput>
                                        <cfelseif isArray(serviceFields[key])>
                                            Array: <cfoutput>#serializeJSON(serviceFields[key])#</cfoutput>
                                        <cfelse>
                                            Complex: <cfoutput>#serializeJSON(serviceFields[key])#</cfoutput>
                                        </cfif>
                                    </p>
                                </cfif>
                            </cfloop>
                        </div>
                    </cfif>
                    
                    <!--- Key Features Section --->
                    <cfset hasFeatures = false>
                    <cfset featuresArray = []>
                    
                    <!--- Check for features in different formats and field names --->
                    <cfset featureFieldNames = ["features", "key_features", "selected_features", "feature_list"]>
                    <cfloop array="#featureFieldNames#" index="fieldName">
                        <cfif structKeyExists(serviceFields, fieldName)>
                            <cfif isArray(serviceFields[fieldName]) AND arrayLen(serviceFields[fieldName])>
                                <cfset hasFeatures = true>
                                <cfset featuresArray = serviceFields[fieldName]>
                                <cfbreak>
                            <cfelseif isSimpleValue(serviceFields[fieldName]) AND len(trim(serviceFields[fieldName]))>
                                <!--- Handle comma-separated string --->
                                <cfset hasFeatures = true>
                                <cfset featuresArray = listToArray(serviceFields[fieldName], ",")>
                                <cfbreak>
                            </cfif>
                        </cfif>
                    </cfloop>
                    
                    <!--- Check designFeatures structure --->
                    <cfif NOT hasFeatures AND structKeyExists(serviceFields, "designFeatures") AND isStruct(serviceFields.designFeatures) AND structKeyExists(serviceFields.designFeatures, "features")>
                        <cfif isArray(serviceFields.designFeatures.features) AND arrayLen(serviceFields.designFeatures.features)>
                            <cfset hasFeatures = true>
                            <cfset featuresArray = serviceFields.designFeatures.features>
                        <cfelseif isSimpleValue(serviceFields.designFeatures.features) AND len(trim(serviceFields.designFeatures.features))>
                            <cfset hasFeatures = true>
                            <cfset featuresArray = listToArray(serviceFields.designFeatures.features, ",")>
                        </cfif>
                    </cfif>
                    
                    <cfif hasFeatures OR (structKeyExists(serviceFields, "other_features") AND isSimpleValue(serviceFields.other_features) AND len(trim(serviceFields.other_features)))>
                        <div class="mb-4">
                            <h5 class="border-bottom pb-2 mb-3">Key Features Needed</h5>
                            <div class="row g-3">
                                <cfif arrayLen(featuresArray)>
                                    <div class="col-12">
                                        <div class="d-flex flex-wrap gap-2">
                                            <cfloop array="#featuresArray#" index="feature">
                                                <cfif isSimpleValue(feature)>
                                                    <span class="badge bg-primary">
                                                        <cfset displayFeature = replace(feature, "_", " ", "all")>
                                                        <cfset displayFeature = reReplace(displayFeature, "\b(\w)", "\u\1", "all")>
                                                        <cfoutput>#displayFeature#</cfoutput>
                                                    </span>
                                                </cfif>
                                            </cfloop>
                                        </div>
                                    </div>
                                </cfif>
                                <cfif structKeyExists(serviceFields, "other_features") AND len(trim(serviceFields.other_features))>
                                    <div class="col-12">
                                        <div class="p-3 bg-light rounded border-start border-primary border-3">
                                            <small class="text-muted d-block mb-1">Additional Features:</small>
                                            <cfoutput>#replace(serviceFields.other_features, chr(10), "<br>", "all")#</cfoutput>
                                        </div>
                                    </div>
                                </cfif>
                            </div>
                        </div>
                    </cfif>
                    
                    <!--- Additional Details Section - Show ALL fields not in skip list --->
                    <cfset skipFields = 'service_type,project_type,name,first_name,last_name,email,phone,phone_number,company,company_name,industry,preferred_contact_method,budget_range,timeline,project_description,goals,target_audience,geographic_target,current_website,website,selected_colors,reference_websites,reference_descriptions,color_preferences,color_validation,features,other_features,current_step,form_id,formId,id,action,design_style,has_branding,payment_methods,additional_comments,submit,draft_id,from_ai,from_draft,need_maintenance,need_content_writing,referral_source,serviceFields,ServiceFields,fieldnames,ai_conversation,ai_draft,is_complete,basicInfo,projectDetails,designFeatures,service_category,project_name,stage'>
                    
                    <cfset additionalFields = []>
                    <cfloop collection="#serviceFields#" item="fieldName">
                        <cfif NOT listFindNoCase(skipFields, fieldName)>
                            <cfset fieldValue = serviceFields[fieldName]>
                            <!--- Show fields that have values OR are expected form fields (even if empty) --->
                            <cfset showField = false>
                            <cfif (isSimpleValue(fieldValue) AND len(trim(fieldValue))) OR 
                                  (isArray(fieldValue) AND arrayLen(fieldValue)) OR 
                                  (isStruct(fieldValue) AND NOT isSimpleValue(fieldValue) AND structCount(fieldValue))>
                                <cfset showField = true>
                            </cfif>
                            
                            <cfif showField>
                                <cfset arrayAppend(additionalFields, {
                                    "name" = fieldName,
                                    "value" = fieldValue
                                })>
                            </cfif>
                        </cfif>
                    </cfloop>
                    
                    <!--- Initialize additional fields data structure --->
                    <cfset additionalFieldsData = {
                        "lists" = [],
                        "structured" = [],  
                        "technical" = [],
                        "basic_info" = []
                    }>
                    <cfset hasAdditionalFields = false>
                    
                    <!--- Categorize remaining fields --->
                    <cfloop collection="#serviceFields#" item="fieldName">
                        <cfif NOT listFindNoCase("fieldnames,action,form_id,#skipFields#", fieldName)>
                            <cfset fieldValue = serviceFields[fieldName]>
                            
                            <!--- Only process non-empty values --->
                            <cfif (isSimpleValue(fieldValue) AND len(trim(fieldValue))) OR 
                                  (isArray(fieldValue) AND arrayLen(fieldValue)) OR 
                                  (isStruct(fieldValue) AND NOT isSimpleValue(fieldValue) AND structCount(fieldValue))>
                                
                                <cfset hasAdditionalFields = true>
                                <cfset fieldData = {
                                    "name" = fieldName,
                                    "value" = fieldValue,
                                    "type" = ""
                                }>
                                
                                <!--- Categorize field types --->
                                <cfif isArray(fieldValue)>
                                    <cfset fieldData.type = "array">
                                    <cfset arrayAppend(additionalFieldsData.lists, fieldData)>
                                <cfelseif isStruct(fieldValue) AND NOT isSimpleValue(fieldValue)>
                                    <cfset fieldData.type = "struct">
                                    <cfset arrayAppend(additionalFieldsData.structured, fieldData)>
                                <cfelseif listFindNoCase("technology,platform,framework,code,api,integration,database", fieldName)>
                                    <cfset fieldData.type = "technical">
                                    <cfset arrayAppend(additionalFieldsData.technical, fieldData)>
                                <cfelse>
                                    <cfset fieldData.type = "basic">
                                    <cfset arrayAppend(additionalFieldsData.basic_info, fieldData)>
                                </cfif>
                            </cfif>
                        </cfif>
                    </cfloop>
                    
                    <!--- Display Additional Fields --->
                    <div class="mb-4">
                        <h5 class="border-bottom pb-2 mb-3">Additional Details</h5>
                        <cfif arrayLen(additionalFields) GT 0>
                            <div class="row g-3">
                                <cfloop array="#additionalFields#" index="field">
                                    <div class="col-md-6">
                                        <div class="p-3 bg-light rounded">
                                            <small class="text-muted d-block mb-1">
                                                <cfset displayName = replace(field.name, "_", " ", "all")>
                                                <cfset displayName = reReplace(displayName, "\b(\w)", "\u\1", "all")>
                                                <cfoutput>#displayName#</cfoutput>
                                            </small>
                                            <div>
                                                <cfif isSimpleValue(field.value)>
                                                    <cfif len(trim(field.value))>
                                                        <cfoutput>#field.value#</cfoutput>
                                                    <cfelse>
                                                        <span class="text-muted fst-italic">Not provided</span>
                                                    </cfif>
                                                <cfelseif isArray(field.value)>
                                                    <cfif arrayLen(field.value)>
                                                        <cfoutput>[#arrayToList(field.value, ", ")#]</cfoutput>
                                                    <cfelse>
                                                        <span class="text-muted fst-italic">Not provided</span>
                                                    </cfif>
                                                <cfelse>
                                                    <code><cfoutput>#serializeJSON(field.value)#</cfoutput></code>
                                                </cfif>
                                            </div>
                                        </div>
                                    </div>
                                </cfloop>
                            </div>
                        <cfelse>
                            <p class="text-muted fst-italic">No additional details provided.</p>
                        </cfif>
                    </div>
                    
                    <!--- Design Style Section --->
                    <cfset designStyleValue = "">
                    <cfif structKeyExists(serviceFields, "design_style") AND len(trim(serviceFields.design_style))>
                        <cfset designStyleValue = serviceFields.design_style>
                    <cfelseif structKeyExists(serviceFields, "designFeatures") AND isStruct(serviceFields.designFeatures) AND structKeyExists(serviceFields.designFeatures, "style") AND len(trim(serviceFields.designFeatures.style))>
                        <cfset designStyleValue = serviceFields.designFeatures.style>
                    </cfif>
                    
                    <cfif len(designStyleValue)>
                        <div class="mb-4">
                            <h5 class="border-bottom pb-2 mb-3">Design Style</h5>
                            <div class="p-3 bg-light rounded">
                                <cfswitch expression="#designStyleValue#">
                                    <cfcase value="modern_minimalist,modern_minimal"><span class="badge bg-dark">Modern & Minimalist</span></cfcase>
                                    <cfcase value="bold_colorful"><span class="badge bg-danger">Bold & Colorful</span></cfcase>
                                    <cfcase value="corporate_professional"><span class="badge bg-primary">Corporate & Professional</span></cfcase>
                                    <cfcase value="playful_fun"><span class="badge bg-warning text-dark">Playful & Fun</span></cfcase>
                                    <cfcase value="elegant_sophisticated"><span class="badge bg-secondary">Elegant & Sophisticated</span></cfcase>
                                    <cfcase value="tech_futuristic"><span class="badge bg-info">Tech & Futuristic</span></cfcase>
                                    <cfcase value="organic_natural"><span class="badge bg-success">Organic & Natural</span></cfcase>
                                    <cfcase value="vintage_retro"><span class="badge bg-dark">Vintage & Retro</span></cfcase>
                                    <cfcase value="creative_bold"><span class="badge bg-danger">Creative & Bold</span></cfcase>
                                    <cfcase value="friendly_approachable"><span class="badge bg-success">Friendly & Approachable</span></cfcase>
                                    <cfcase value="no_preference"><span class="badge bg-secondary">No Preference</span></cfcase>
                                    <cfcase value="custom"><span class="badge bg-secondary">Custom Style</span></cfcase>
                                    <cfdefaultcase>
                                        <cfif isSimpleValue(designStyleValue)>
                                            <!--- Convert underscore-separated values to human readable format --->
                                            <cfset displayStyle = replace(designStyleValue, "_", " ", "all")>
                                            <cfset displayStyle = reReplace(displayStyle, "\b(\w)", "\u\1", "all")>
                                            <span class="badge bg-secondary"><cfoutput>#displayStyle#</cfoutput></span>
                                        <cfelse>
                                            <cfoutput>#serializeJSON(designStyleValue)#</cfoutput>
                                        </cfif>
                                    </cfdefaultcase>
                                </cfswitch>
                            </div>
                        </div>
                    </cfif>
                    
                    <!--- Debug: Check color fields --->
                    <cfif structKeyExists(url, "debug") AND url.debug EQ "colors">
                        <div class="alert alert-info">
                            <h6>Debug: Color Fields</h6>
                            <cfloop collection="#serviceFields#" item="key">
                                <cfif findNoCase("color", key)>
                                    <p><strong><cfoutput>#key#</cfoutput>:</strong> 
                                        <cfif isSimpleValue(serviceFields[key])>
                                            <cfoutput>#serviceFields[key]#</cfoutput>
                                        <cfelseif isArray(serviceFields[key])>
                                            Array: <cfoutput>#serializeJSON(serviceFields[key])#</cfoutput>
                                        <cfelse>
                                            Complex: <cfoutput>#serializeJSON(serviceFields[key])#</cfoutput>
                                        </cfif>
                                    </p>
                                </cfif>
                            </cfloop>
                        </div>
                    </cfif>
                    
                    <!--- Color Palette Section --->
                    <cfset hasColors = false>
                    <cfset colorArray = []>
                    
                    <!--- Check for colors in different formats --->
                    <cfset colorFieldNames = ["selected_colors", "color_preferences", "colors", "color_palette"]>
                    <cfloop array="#colorFieldNames#" index="fieldName">
                        <cfif structKeyExists(serviceFields, fieldName)>
                            <cfif isArray(serviceFields[fieldName]) AND arrayLen(serviceFields[fieldName])>
                                <cfset hasColors = true>
                                <cfset colorArray = serviceFields[fieldName]>
                                <cfbreak>
                            <cfelseif isSimpleValue(serviceFields[fieldName]) AND len(trim(serviceFields[fieldName]))>
                                <!--- Handle comma-separated string --->
                                <cfset hasColors = true>
                                <cfset colorArray = listToArray(serviceFields[fieldName], ",")>
                                <cfbreak>
                            </cfif>
                        </cfif>
                    </cfloop>
                    
                    <cfif hasColors>
                        <div class="mb-4">
                            <h5 class="border-bottom pb-2 mb-3">Color Palette</h5>
                            <div class="color-palette-display">
                                <cfloop array="#colorArray#" index="color">
                                    <cfif isSimpleValue(color)>
                                        <cfset colorValue = trim(color)>
                                        <cfset displayColor = colorValue>
                                        <cfset colorName = "">
                                        
                                        <!--- Map common color names to hex values --->
                                        <cfswitch expression="#lcase(colorValue)#">
                                            <cfcase value="blue"><cfset displayColor = "##0000FF"><cfset colorName = "Blue"></cfcase>
                                            <cfcase value="red"><cfset displayColor = "##FF0000"><cfset colorName = "Red"></cfcase>
                                            <cfcase value="green"><cfset displayColor = "##00FF00"><cfset colorName = "Green"></cfcase>
                                            <cfcase value="yellow"><cfset displayColor = "##FFFF00"><cfset colorName = "Yellow"></cfcase>
                                            <cfcase value="orange"><cfset displayColor = "##FFA500"><cfset colorName = "Orange"></cfcase>
                                            <cfcase value="purple"><cfset displayColor = "##800080"><cfset colorName = "Purple"></cfcase>
                                            <cfcase value="pink"><cfset displayColor = "##FFC0CB"><cfset colorName = "Pink"></cfcase>
                                            <cfcase value="black"><cfset displayColor = "##000000"><cfset colorName = "Black"></cfcase>
                                            <cfcase value="white"><cfset displayColor = "##FFFFFF"><cfset colorName = "White"></cfcase>
                                            <cfcase value="gray,grey"><cfset displayColor = "##808080"><cfset colorName = "Gray"></cfcase>
                                            <cfcase value="brown"><cfset displayColor = "##A52A2A"><cfset colorName = "Brown"></cfcase>
                                            <cfcase value="navy"><cfset displayColor = "##000080"><cfset colorName = "Navy"></cfcase>
                                            <cfdefaultcase>
                                                <cfif left(colorValue, 1) EQ "##">
                                                    <cfset displayColor = colorValue>
                                                    <cfset colorName = "Custom">
                                                <cfelse>
                                                    <cfset displayColor = "##CCCCCC">
                                                    <cfif len(colorValue) GT 1>
                                                        <cfset colorName = ucase(left(colorValue, 1)) & right(colorValue, len(colorValue)-1)>
                                                    <cfelseif len(colorValue) EQ 1>
                                                        <cfset colorName = ucase(colorValue)>
                                                    <cfelse>
                                                        <cfset colorName = "Unknown">
                                                    </cfif>
                                                </cfif>
                                            </cfdefaultcase>
                                        </cfswitch>
                                        
                                        <div class="color-swatch-card">
                                            <div class="color-swatch" style="background-color: <cfoutput>#displayColor#</cfoutput>;"></div>
                                            <div class="color-info">
                                                <div class="color-hex"><cfoutput>#ucase(displayColor)#</cfoutput></div>
                                                <div class="color-name"><cfoutput>#colorName#</cfoutput></div>
                                            </div>
                                        </div>
                                    <cfelse>
                                        <!--- Handle complex color objects --->
                                        <div class="color-swatch-card">
                                            <div class="color-swatch" style="background-color: #ccc;"></div>
                                            <div class="color-info">
                                                <div class="color-hex">Complex Data</div>
                                                <div class="color-name">
                                                    <code><cfoutput>#serializeJSON(color)#</cfoutput></code>
                                                </div>
                                            </div>
                                        </div>
                                    </cfif>
                                </cfloop>
                            </div>
                        </div>
                    </cfif>
                    
                    <!--- Reference Websites Section --->
                    <cfif structKeyExists(serviceFields, "reference_websites") AND (
                        (isArray(serviceFields.reference_websites) AND arrayLen(serviceFields.reference_websites) GT 0) OR
                        (isSimpleValue(serviceFields.reference_websites) AND len(trim(serviceFields.reference_websites)) AND serviceFields.reference_websites NEQ "none")
                    )>
                            <div class="mb-4">
                            <h5 class="border-bottom pb-2 mb-3">Reference Websites</h5>
                            <div class="row g-3">
                                <!--- Handle both array and string formats --->
                                <cfset websitesList = []>
                                <cfset descriptionsList = []>
                                
                                <cfif isArray(serviceFields.reference_websites)>
                                    <cfset websitesList = serviceFields.reference_websites>
                                <cfelseif isSimpleValue(serviceFields.reference_websites)>
                                    <cfset websitesList = listToArray(serviceFields.reference_websites, ",")>
                                </cfif>
                                
                                <cfif structKeyExists(serviceFields, "reference_descriptions")>
                                    <cfif isArray(serviceFields.reference_descriptions)>
                                        <cfset descriptionsList = serviceFields.reference_descriptions>
                                    <cfelseif isSimpleValue(serviceFields.reference_descriptions)>
                                        <cfset descriptionsList = listToArray(serviceFields.reference_descriptions, ",")>
                                    </cfif>
                                </cfif>
                                    
                                    <cfloop from="1" to="#arrayLen(websitesList)#" index="idx">
                                        <cfset websiteUrl = trim(websitesList[idx])>
                                        <cfset description = "">
                                        <cfif arrayLen(descriptionsList) GTE idx>
                                            <cfset description = trim(descriptionsList[idx])>
                                        </cfif>
                                        
                                        <div class="col-12">
                                            <div class="p-3 border rounded bg-light">
                                                <div class="d-flex align-items-start">
                                                    <div class="me-3">
                                                        <span class="badge bg-primary rounded-circle" style="width: 30px; height: 30px; display: flex; align-items: center; justify-content: center;">
                                                            <cfoutput>#idx#</cfoutput>
                                                        </span>
                                                    </div>
                                                    <div class="flex-grow-1">
                                                        <div class="fw-bold mb-1">
                                                            <a href="<cfoutput>#websiteUrl#</cfoutput>" target="_blank" class="text-decoration-none">
                                                                <cfoutput>#websiteUrl#</cfoutput>
                                                                <i class="fas fa-external-link-alt ms-1 small"></i>
                                                            </a>
                                                        </div>
                                                        <cfif len(description)>
                                                            <div class="text-muted small">
                                                                <cfoutput>#description#</cfoutput>
                                                            </div>
                                                        </cfif>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </cfloop>
                            </div>
                        </div>
                    </cfif>
                    
                    <!--- Payment Methods Section --->
                    <cfif structKeyExists(serviceFields, "payment_methods") AND isArray(serviceFields.payment_methods) AND arrayLen(serviceFields.payment_methods)>
                        <div class="mb-4">
                            <h5 class="border-bottom pb-2 mb-3">Payment Methods Required</h5>
                            <div class="d-flex flex-wrap gap-2">
                                <cfloop array="#serviceFields.payment_methods#" index="method">
                                    <span class="badge bg-light text-dark border">
                                        <cfswitch expression="#method#">
                                            <cfcase value="credit_card">Credit/Debit Cards</cfcase>
                                            <cfcase value="paypal">PayPal</cfcase>
                                            <cfcase value="stripe">Stripe</cfcase>
                                            <cfcase value="bank_transfer">Bank Transfer</cfcase>
                                            <cfcase value="crypto">Cryptocurrency</cfcase>
                                            <cfdefaultcase>
                                                <cfif isSimpleValue(method)>
                                                    <cfoutput>#method#</cfoutput>
                                                <cfelse>
                                                    <cfoutput>#serializeJSON(method)#</cfoutput>
                                                </cfif>
                                            </cfdefaultcase>
                                        </cfswitch>
                                    </span>
                                </cfloop>
                            </div>
                        </div>
                    </cfif>
                    
                    <!--- Branding Materials Section --->
                    <cfif structKeyExists(serviceFields, "has_branding") AND len(trim(serviceFields.has_branding))>
                        <div class="mb-4">
                            <h5 class="border-bottom pb-2 mb-3">Branding Materials</h5>
                            <div class="p-3 bg-light rounded">
                                <cfswitch expression="#serviceFields.has_branding#">
                                    <cfcase value="yes_complete"><span class="badge bg-success">Complete brand guide available</span></cfcase>
                                    <cfcase value="yes_logo"><span class="badge bg-info">Logo only</span></cfcase>
                                    <cfcase value="yes_some"><span class="badge bg-warning text-dark">Some materials available</span></cfcase>
                                    <cfcase value="no"><span class="badge bg-secondary">Need branding help</span></cfcase>
                                    <cfdefaultcase>
                                        <cfif isSimpleValue(serviceFields.has_branding)>
                                            <cfoutput>#serviceFields.has_branding#</cfoutput>
                                        <cfelse>
                                            <cfoutput>#serializeJSON(serviceFields.has_branding)#</cfoutput>
                                        </cfif>
                                    </cfdefaultcase>
                                </cfswitch>
                            </div>
                        </div>
                    </cfif>
                    
                    <!--- Additional Services Section --->
                    <cfif (structKeyExists(serviceFields, "need_maintenance") AND len(trim(serviceFields.need_maintenance))) OR 
                          (structKeyExists(serviceFields, "need_content_writing") AND len(trim(serviceFields.need_content_writing))) OR
                          (structKeyExists(serviceFields, "referral_source") AND len(trim(serviceFields.referral_source)))>
                        <div class="mb-4">
                            <h5 class="border-bottom pb-2 mb-3">Additional Services & Information</h5>
                            <div class="row g-3">
                                <cfif structKeyExists(serviceFields, "need_maintenance") AND len(trim(serviceFields.need_maintenance))>
                                    <div class="col-md-4">
                                        <div class="p-3 bg-light rounded">
                                            <small class="text-muted d-block mb-1">Maintenance Required</small>
                                            <cfswitch expression="#serviceFields.need_maintenance#">
                                                <cfcase value="yes_monthly">Yes - Monthly</cfcase>
                                                <cfcase value="yes_quarterly">Yes - Quarterly</cfcase>
                                                <cfcase value="yes_annually">Yes - Annually</cfcase>
                                                <cfcase value="no">No</cfcase>
                                                <cfdefaultcase>
                                                    <cfif isSimpleValue(serviceFields.need_maintenance)>
                                                        <cfoutput>#serviceFields.need_maintenance#</cfoutput>
                                                    <cfelse>
                                                        <cfoutput>#serializeJSON(serviceFields.need_maintenance)#</cfoutput>
                                                    </cfif>
                                                </cfdefaultcase>
                                            </cfswitch>
                                        </div>
                                    </div>
                                </cfif>
                                <cfif structKeyExists(serviceFields, "need_content_writing") AND len(trim(serviceFields.need_content_writing))>
                                    <div class="col-md-4">
                                        <div class="p-3 bg-light rounded">
                                            <small class="text-muted d-block mb-1">Content Writing Needed</small>
                                            <cfswitch expression="#serviceFields.need_content_writing#">
                                                <cfcase value="yes_all">Yes - All content</cfcase>
                                                <cfcase value="yes_some">Yes - Some content</cfcase>
                                                <cfcase value="no">No - Have content</cfcase>
                                                <cfdefaultcase>
                                                    <cfif isSimpleValue(serviceFields.need_content_writing)>
                                                        <cfoutput>#serviceFields.need_content_writing#</cfoutput>
                                                    <cfelse>
                                                        <cfoutput>#serializeJSON(serviceFields.need_content_writing)#</cfoutput>
                                                    </cfif>
                                                </cfdefaultcase>
                                            </cfswitch>
                                        </div>
                                    </div>
                                </cfif>
                                <cfif structKeyExists(serviceFields, "referral_source") AND len(trim(serviceFields.referral_source))>
                                    <div class="col-md-4">
                                        <div class="p-3 bg-light rounded">
                                            <small class="text-muted d-block mb-1">How They Found Us</small>
                                            <cfswitch expression="#serviceFields.referral_source#">
                                                <cfcase value="google">Google Search</cfcase>
                                                <cfcase value="social_media">Social Media</cfcase>
                                                <cfcase value="referral">Referral</cfcase>
                                                <cfcase value="other">Other</cfcase>
                                                <cfdefaultcase>
                                                    <cfif isSimpleValue(serviceFields.referral_source)>
                                                        <cfoutput>#serviceFields.referral_source#</cfoutput>
                                                    <cfelse>
                                                        <cfoutput>#serializeJSON(serviceFields.referral_source)#</cfoutput>
                                                    </cfif>
                                                </cfdefaultcase>
                                            </cfswitch>
                                        </div>
                                    </div>
                                </cfif>
                            </div>
                        </div>
                    </cfif>
                    
                    <!--- Additional Comments --->
                    <cfif structKeyExists(serviceFields, "additional_comments") AND ((isSimpleValue(serviceFields.additional_comments) AND len(trim(serviceFields.additional_comments))) OR NOT isSimpleValue(serviceFields.additional_comments))>
                        <div class="mb-4">
                            <h5 class="border-bottom pb-2 mb-3">Additional Comments</h5>
                            <div class="p-3 bg-light rounded border-start border-secondary border-3">
                                <cfif isSimpleValue(serviceFields.additional_comments)>
                                    <cfoutput>#replace(serviceFields.additional_comments, chr(10), "<br>", "all")#</cfoutput>
                                <cfelse>
                                    <cfoutput>#serializeJSON(serviceFields.additional_comments)#</cfoutput>
                                </cfif>
                            </div>
                        </div>
                    </cfif>
                    
                    </div>
                    
                    <!--- Debug: Show all fields and skip status --->
                    <cfif structKeyExists(url, "debug") AND url.debug EQ "true">
                        <hr class="my-4">
                        <h5 class="text-primary mb-3">Debug: All Fields in ServiceFields</h5>
                        <div class="bg-light p-3 rounded mb-3">
                            <table class="table table-sm">
                                <thead>
                                    <tr>
                                        <th>Field Name</th>
                                        <th>Value</th>
                                        <th>In Skip List?</th>
                                        <th>Displayed?</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <cfloop collection="#serviceFields#" item="fieldName">
                                        <tr>
                                            <td><cfoutput>#fieldName#</cfoutput></td>
                                            <td>
                                                <cfset fieldValue = serviceFields[fieldName]>
                                                <cfif isSimpleValue(fieldValue)>
                                                    <cfoutput>#left(fieldValue, 50)#<cfif len(fieldValue) GT 50>...</cfif></cfoutput>
                                                <cfelseif isArray(fieldValue)>
                                                    Array (<cfoutput>#arrayLen(fieldValue)#</cfoutput> items)
                                                <cfelse>
                                                    Struct (<cfoutput>#structCount(fieldValue)#</cfoutput> keys)
                                                </cfif>
                                            </td>
                                            <td>
                                                <cfif listFindNoCase("fieldnames,action,form_id,#skipFields#", fieldName)>
                                                    <span class="text-danger">Yes</span>
                                                <cfelse>
                                                    <span class="text-success">No</span>
                                                </cfif>
                                            </td>
                                            <td>
                                                <cfif listFindNoCase("fieldnames,action,form_id,#skipFields#", fieldName)>
                                                    In specific section
                                                <cfelse>
                                                    Should be in Additional Details
                                                </cfif>
                                            </td>
                                        </tr>
                                    </cfloop>
                                </tbody>
                            </table>
                        </div>
                        <h5 class="text-primary mb-3">Raw Form Data (JSON)</h5>
                        <div class="bg-light p-3 rounded">
                            <pre class="mb-0"><code><cfoutput>#encodeForHTML(qForm.form_data)#</cfoutput></code></pre>
                        </div>
                    </cfif>
                </div>
            </div>
        </div>
    </div>
</div>

<style>
@media print {
    .navbar, footer, .btn {
        display: none !important;
    }
    .card {
        box-shadow: none !important;
        border: 1px solid #dee2e6 !important;
    }
}

.bg-purple {
    background-color: #6f42c1 !important;
}

/* Color Palette Styles */
.color-palette-display {
    display: flex;
    flex-wrap: wrap;
    gap: 1rem;
}

.color-swatch-card {
    background: #fff;
    border: 1px solid #e0e0e0;
    border-radius: 8px;
    padding: 10px;
    text-align: center;
    box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

.color-swatch {
    width: 80px;
    height: 80px;
    border-radius: 8px;
    margin-bottom: 8px;
    border: 1px solid rgba(0,0,0,0.1);
}

.color-info {
    font-size: 0.875rem;
}

.color-hex {
    font-weight: bold;
    font-family: monospace;
    margin-bottom: 2px;
}

.color-name {
    color: #6c757d;
    font-size: 0.75rem;
}

</style>

<cfinclude template="includes/footer.cfm">

<cfcatch type="any">
    <!--- Display error page instead of 500 error --->
    <cfcontent reset="true">
    <!DOCTYPE html>
    <html>
    <head>
        <title>Form View Error</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    </head>
    <body>
        <div class="container mt-5">
            <div class="row justify-content-center">
                <div class="col-md-8">
                    <div class="alert alert-danger">
                        <h4>Error Loading Form</h4>
                        <p><strong>Error:</strong> <cfoutput>#cfcatch.message#</cfoutput></p>
                        <p><strong>Detail:</strong> <cfoutput>#cfcatch.detail#</cfoutput></p>
                        <cfif structKeyExists(cfcatch, "template")>
                            <p><strong>File:</strong> <cfoutput>#cfcatch.template#</cfoutput></p>
                        </cfif>
                        <cfif structKeyExists(cfcatch, "line")>
                            <p><strong>Line:</strong> <cfoutput>#cfcatch.line#</cfoutput></p>
                        </cfif>
                        <hr>
                        <p><a href="<cfoutput>#application.basePath#</cfoutput>/dashboard.cfm" class="btn btn-primary">Back to Dashboard</a></p>
                    </div>
                </div>
            </div>
        </div>
    </body>
    </html>
</cfcatch>
</cftry>