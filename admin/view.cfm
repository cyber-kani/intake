<cfparam name="url.id" default="">

<!--- Get form data --->
<cfset db = createObject("component", "intake.components.Database")>

<!--- Check if ID is numeric (old style) or alphanumeric (form_code) --->
<cfif isNumeric(url.id)>
    <cfquery name="qForm" datasource="clitools">
        SELECT f.*, u.email as user_email, u.display_name, u.google_id
        FROM IntakeForms f
        INNER JOIN Users u ON f.user_id = u.user_id
        WHERE f.form_id = <cfqueryparam value="#url.id#" cfsqltype="cf_sql_integer">
    </cfquery>
<cfelse>
    <cfquery name="qForm" datasource="clitools">
        SELECT f.*, u.email as user_email, u.display_name, u.google_id
        FROM IntakeForms f
        INNER JOIN Users u ON f.user_id = u.user_id
        WHERE f.form_code = <cfqueryparam value="#url.id#" cfsqltype="cf_sql_varchar">
    </cfquery>
</cfif>

<cfif qForm.recordCount EQ 0>
    <cflocation url="#application.basePath#/admin/" addtoken="false">
</cfif>

<!--- Parse service fields --->
<cfset serviceFields = {}>
<cftry>
    <cfset serviceFields = deserializeJSON(qForm.form_data)>
    <cfcatch>
        <cfset serviceFields = {}>
    </cfcatch>
</cftry>

<cfinclude template="../includes/header.cfm">

<div class="container mt-4">
    <div class="row justify-content-center">
        <div class="col-md-12">
            <div class="d-flex justify-content-between align-items-center mb-4">
                <h2>Admin View - Form <cfoutput>#structKeyExists(qForm, "form_code") AND len(qForm.form_code) ? qForm.form_code : "##" & qForm.form_id#</cfoutput></h2>
                <div>
                    <button onclick="window.print()" class="btn btn-outline-primary">
                        <i class="fas fa-print"></i> Print
                    </button>
                    <a href="<cfoutput>#application.basePath#</cfoutput>/admin/" class="btn btn-secondary ms-2">
                        <i class="fas fa-arrow-left"></i> Back to Admin
                    </a>
                </div>
            </div>
            
            <!--- Admin User Information Card --->
            <div class="card shadow-lg border-0 mb-4">
                <div class="card-header bg-dark text-white">
                    <div class="d-flex align-items-center">
                        <div class="section-icon bg-light text-dark me-3">
                            <i class="fas fa-user-shield"></i>
                        </div>
                        <h5 class="mb-0">User Information (Admin View)</h5>
                    </div>
                </div>
                <div class="card-body p-4">
                    <div class="row g-3">
                        <div class="col-md-6">
                            <div class="info-card">
                                <div class="info-card-icon">
                                    <i class="fas fa-user-tag"></i>
                                </div>
                                <div class="info-card-content">
                                    <div class="info-label">Submitted By</div>
                                    <div class="info-value"><cfoutput>#qForm.display_name#</cfoutput></div>
                                </div>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="info-card">
                                <div class="info-card-icon">
                                    <i class="fas fa-envelope"></i>
                                </div>
                                <div class="info-card-content">
                                    <div class="info-label">User Email</div>
                                    <div class="info-value"><a href="mailto:<cfoutput>#qForm.user_email#</cfoutput>" class="text-decoration-none"><cfoutput>#qForm.user_email#</cfoutput></a></div>
                                </div>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="info-card">
                                <div class="info-card-icon">
                                    <i class="fas fa-id-badge"></i>
                                </div>
                                <div class="info-card-content">
                                    <div class="info-label">User ID</div>
                                    <div class="info-value"><cfoutput>#qForm.user_id#</cfoutput></div>
                                </div>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="info-card">
                                <div class="info-card-icon">
                                    <i class="fas fa-flag"></i>
                                </div>
                                <div class="info-card-content">
                                    <div class="info-label">Form Status</div>
                                    <div class="info-value">
                                        <cfif qForm.is_finalized>
                                            <span class="badge bg-success px-3 py-2"><i class="fas fa-check me-1"></i>Submitted</span>
                                        <cfelse>
                                            <span class="badge bg-warning px-3 py-2"><i class="fas fa-clock me-1"></i>Draft</span>
                                        </cfif>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="info-card">
                                <div class="info-card-icon">
                                    <i class="fas fa-hashtag"></i>
                                </div>
                                <div class="info-card-content">
                                    <div class="info-label">Form Code</div>
                                    <div class="info-value"><span class="badge bg-primary px-3 py-2"><cfoutput>#structKeyExists(qForm, "form_code") AND len(qForm.form_code) ? qForm.form_code : "##" & qForm.form_id#</cfoutput></span></div>
                                </div>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="info-card">
                                <div class="info-card-icon">
                                    <i class="fas fa-google"></i>
                                </div>
                                <div class="info-card-content">
                                    <div class="info-label">Google ID</div>
                                    <div class="info-value"><code class="bg-light px-2 py-1 rounded"><cfoutput>#qForm.google_id#</cfoutput></code></div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            
            <!--- Form Content --->
            <div class="card shadow-lg border-0">
                <div class="card-body p-4">
                    <cfif qForm.is_finalized>
                        <div class="position-absolute top-0 end-0 m-3">
                            <span class="badge bg-success fs-6 px-3 py-2 rounded-pill">
                                <i class="fas fa-check-circle me-1"></i> Submitted
                            </span>
                        </div>
                    </cfif>
                    <!--- Service Type --->
                    <div class="mb-5">
                        <div class="section-header mb-3">
                            <div class="d-flex align-items-center">
                                <div class="section-icon bg-primary">
                                    <i class="fas fa-cogs"></i>
                                </div>
                                <h4 class="section-title mb-0">Service Type</h4>
                            </div>
                        </div>
                        <cfset serviceDisplay = "">
                        <cfset serviceTypeValue = qForm.service_type>
                        
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
                        
                        <div class="service-type-display">
                            <cfif len(serviceDisplay)>
                                <div class="service-badge">
                                    <i class="fas fa-star me-2"></i>
                                    <span class="fs-5 fw-semibold"><cfoutput>#serviceDisplay#</cfoutput></span>
                                </div>
                            <cfelseif len(trim(serviceTypeValue))>
                                <div class="service-badge">
                                    <i class="fas fa-star me-2"></i>
                                    <span class="fs-5 fw-semibold"><cfoutput>#serviceTypeValue#</cfoutput></span>
                                </div>
                            <cfelse>
                                <div class="service-badge text-muted">
                                    <i class="fas fa-question-circle me-2"></i>
                                    <span class="fs-5">Not specified</span>
                                </div>
                            </cfif>
                        </div>
                    </div>
                    
                    <!--- Form Metadata --->
                    <div class="mb-5">
                        <div class="section-header mb-3">
                            <div class="d-flex align-items-center">
                                <div class="section-icon bg-info">
                                    <i class="fas fa-info-circle"></i>
                                </div>
                                <h4 class="section-title mb-0">Form Information</h4>
                            </div>
                        </div>
                        <div class="row g-3">
                            <div class="col-md-6">
                                <div class="info-card">
                                    <div class="info-card-icon">
                                        <i class="fas fa-calendar-plus"></i>
                                    </div>
                                    <div class="info-card-content">
                                        <div class="info-label">Created</div>
                                        <div class="info-value"><cfoutput>#dateTimeFormat(qForm.created_at, "mm/dd/yyyy hh:nn tt")#</cfoutput></div>
                                    </div>
                                </div>
                            </div>
                            <cfif qForm.is_finalized AND isDate(qForm.submitted_at)>
                                <div class="col-md-6">
                                    <div class="info-card">
                                        <div class="info-card-icon">
                                            <i class="fas fa-paper-plane"></i>
                                        </div>
                                        <div class="info-card-content">
                                            <div class="info-label">Submitted</div>
                                            <div class="info-value"><cfoutput>#dateTimeFormat(qForm.submitted_at, "mm/dd/yyyy hh:nn tt")#</cfoutput></div>
                                        </div>
                                    </div>
                                </div>
                            </cfif>
                            <cfif isDate(qForm.updated_at)>
                                <div class="col-md-6">
                                    <div class="info-card">
                                        <div class="info-card-icon">
                                            <i class="fas fa-clock"></i>
                                        </div>
                                        <div class="info-card-content">
                                            <div class="info-label">Last Updated</div>
                                            <div class="info-value"><cfoutput>#dateTimeFormat(qForm.updated_at, "mm/dd/yyyy hh:nn tt")#</cfoutput></div>
                                        </div>
                                    </div>
                                </div>
                            </cfif>
                            <div class="col-md-6">
                                <div class="info-card">
                                    <div class="info-card-icon">
                                        <i class="fas fa-project-diagram"></i>
                                    </div>
                                    <div class="info-card-content">
                                        <div class="info-label">Project Type</div>
                                        <div class="info-value"><cfoutput>#qForm.project_type#</cfoutput></div>
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="info-card">
                                    <div class="info-card-icon">
                                        <i class="fas fa-database"></i>
                                    </div>
                                    <div class="info-card-content">
                                        <div class="info-label">Database ID</div>
                                        <div class="info-value"><span class="badge bg-secondary px-3 py-2"><cfoutput>#qForm.form_id#</cfoutput></span></div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    
                    <!--- All Form Fields --->
                    <h5 class="text-primary mb-3">All Submitted Data</h5>
                    <div class="mb-4">
                        <div class="row">
                            <cfloop collection="#serviceFields#" item="fieldName">
                                <cfif NOT listFindNoCase("fieldnames,action,form_id", fieldName)>
                                    <cfset fieldValue = serviceFields[fieldName]>
                                    
                                    <!--- Handle simple values --->
                                    <cfif isSimpleValue(fieldValue) AND len(trim(fieldValue))>
                                        <div class="col-md-6 mb-3">
                                            <div class="border-start border-3 border-primary ps-3">
                                                <strong class="text-capitalize">
                                                    <cfset displayName = replace(fieldName, "_", " ", "all")>
                                                    <cfset displayName = reReplace(displayName, "\b(\w)", "\u\1", "all")>
                                                    <cfoutput>#displayName#</cfoutput>:
                                                </strong><br>
                                                <cfif fieldName CONTAINS "description" OR fieldName CONTAINS "comments" OR len(fieldValue) GT 100>
                                                    <p class="mb-0 text-muted"><cfoutput>#replace(fieldValue, chr(10), "<br>", "all")#</cfoutput></p>
                                                <cfelse>
                                                    <span class="text-muted">
                                                        <cfswitch expression="#fieldName#">
                                                            <cfcase value="timeline">
                                                                <cfswitch expression="#fieldValue#">
                                                                    <cfcase value="asap">ASAP</cfcase>
                                                                    <cfcase value="1_month">Within 1 month</cfcase>
                                                                    <cfcase value="2_months">Within 2 months</cfcase>
                                                                    <cfcase value="3_months">Within 3 months</cfcase>
                                                                    <cfcase value="6_months">Within 6 months</cfcase>
                                                                    <cfcase value="flexible">Flexible</cfcase>
                                                                    <cfdefaultcase><cfoutput>#fieldValue#</cfoutput></cfdefaultcase>
                                                                </cfswitch>
                                                            </cfcase>
                                                            <cfcase value="budget_range">
                                                                <cfswitch expression="#fieldValue#">
                                                                    <cfcase value="under_1000,under_1k">Under $1,000</cfcase>
                                                                    <cfcase value="1k_5k">$1,000 - $5,000</cfcase>
                                                                    <cfcase value="5k_10k">$5,000 - $10,000</cfcase>
                                                                    <cfcase value="10k_25k">$10,000 - $25,000</cfcase>
                                                                    <cfcase value="25k_50k">$25,000 - $50,000</cfcase>
                                                                    <cfcase value="50k_plus">$50,000+</cfcase>
                                                                    <cfcase value="not_sure">Not sure yet</cfcase>
                                                                    <cfdefaultcase><cfoutput>#fieldValue#</cfoutput></cfdefaultcase>
                                                                </cfswitch>
                                                            </cfcase>
                                                            <cfcase value="preferred_contact_method">
                                                                <cfswitch expression="#fieldValue#">
                                                                    <cfcase value="email">Email</cfcase>
                                                                    <cfcase value="phone">Phone</cfcase>
                                                                    <cfcase value="text">Text Message</cfcase>
                                                                    <cfdefaultcase><cfoutput>#fieldValue#</cfoutput></cfdefaultcase>
                                                                </cfswitch>
                                                            </cfcase>
                                                            <cfdefaultcase>
                                                                <cfoutput>#fieldValue#</cfoutput>
                                                            </cfdefaultcase>
                                                        </cfswitch>
                                                    </span>
                                                </cfif>
                                            </div>
                                        </div>
                                        
                                    <!--- Handle arrays (like features, colors) --->
                                    <cfelseif isArray(fieldValue) AND arrayLen(fieldValue)>
                                        <cfif fieldName EQ "selected_colors">
                                            <!--- Special handling for colors --->
                                            <div class="col-12 mb-3">
                                                <div class="border-start border-3 border-primary ps-3">
                                                    <strong>Selected Colors:</strong><br>
                                                    <div class="d-flex flex-wrap gap-2 mt-2">
                                                        <cfloop array="#fieldValue#" index="color">
                                                            <div class="d-flex align-items-center">
                                                                <div style="width: 30px; height: 30px; background-color: <cfoutput>#color#</cfoutput>; border: 1px solid ##ddd; border-radius: 4px;"></div>
                                                                <span class="ms-2 text-muted"><cfoutput>#color#</cfoutput></span>
                                                            </div>
                                                        </cfloop>
                                                    </div>
                                                </div>
                                            </div>
                                        <cfelseif fieldName EQ "reference_websites">
                                            <!--- Special handling for reference websites --->
                                            <div class="col-12 mb-3">
                                                <div class="border-start border-3 border-primary ps-3">
                                                    <strong>Reference Websites:</strong><br>
                                                    <cfloop array="#fieldValue#" index="website">
                                                        <cfif isStruct(website)>
                                                            <div class="mt-2 p-2 bg-light rounded">
                                                                <a href="<cfoutput>#website.url#</cfoutput>" target="_blank" class="text-decoration-none">
                                                                    <cfoutput>#website.url#</cfoutput>
                                                                </a>
                                                                <cfif structKeyExists(website, "description") AND len(website.description)>
                                                                    <p class="mb-0 mt-1 text-muted small">
                                                                        <i class="fas fa-comment"></i> <cfoutput>#website.description#</cfoutput>
                                                                    </p>
                                                                </cfif>
                                                            </div>
                                                        <cfelse>
                                                            <div class="mt-2">
                                                                <a href="<cfoutput>#website#</cfoutput>" target="_blank" class="text-decoration-none">
                                                                    <cfoutput>#website#</cfoutput>
                                                                </a>
                                                            </div>
                                                        </cfif>
                                                    </cfloop>
                                                </div>
                                            </div>
                                        <cfelse>
                                            <!--- Regular array handling --->
                                            <div class="col-md-6 mb-3">
                                                <div class="border-start border-3 border-primary ps-3">
                                                    <strong class="text-capitalize">
                                                        <cfset displayName = replace(fieldName, "_", " ", "all")>
                                                        <cfset displayName = reReplace(displayName, "\b(\w)", "\u\1", "all")>
                                                        <cfoutput>#displayName#</cfoutput>:
                                                    </strong><br>
                                                    <ul class="mb-0">
                                                        <cfloop array="#fieldValue#" index="item">
                                                            <li class="text-muted"><cfoutput>#item#</cfoutput></li>
                                                        </cfloop>
                                                    </ul>
                                                </div>
                                            </div>
                                        </cfif>
                                        
                                    <!--- Handle structs/objects --->
                                    <cfelseif isStruct(fieldValue) AND NOT isSimpleValue(fieldValue)>
                                        <div class="col-md-6 mb-3">
                                            <div class="border-start border-3 border-primary ps-3">
                                                <strong class="text-capitalize">
                                                    <cfset displayName = replace(fieldName, "_", " ", "all")>
                                                    <cfset displayName = reReplace(displayName, "\b(\w)", "\u\1", "all")>
                                                    <cfoutput>#displayName#</cfoutput>:
                                                </strong><br>
                                                <ul class="mb-0">
                                                    <cfloop collection="#fieldValue#" item="subKey">
                                                        <li class="text-muted">
                                                            <cfoutput>#subKey#: 
                                                            <cfif isSimpleValue(fieldValue[subKey])>
                                                                #fieldValue[subKey]#
                                                            <cfelseif isArray(fieldValue[subKey])>
                                                                [#arrayToList(fieldValue[subKey], ", ")#]
                                                            <cfelse>
                                                                #serializeJSON(fieldValue[subKey])#
                                                            </cfif>
                                                            </cfoutput>
                                                        </li>
                                                    </cfloop>
                                                </ul>
                                            </div>
                                        </div>
                                    </cfif>
                                </cfif>
                            </cfloop>
                        </div>
                        
                        <!--- Show any additional data that might be in standard fields --->
                        <div class="row">
                        <cfif structKeyExists(serviceFields, "website") AND len(trim(serviceFields.website))>
                            <div class="col-md-6 mb-3">
                                <div class="border-start border-3 border-primary ps-3">
                                    <strong>Website:</strong><br>
                                    <cfif serviceFields.website NEQ "no" AND serviceFields.website NEQ "none">
                                        <a href="<cfoutput>#serviceFields.website#</cfoutput>" target="_blank" class="text-decoration-none">
                                            <cfoutput>#serviceFields.website#</cfoutput>
                                        </a>
                                    <cfelse>
                                        <span class="text-muted">No existing website</span>
                                    </cfif>
                                </div>
                            </div>
                        </cfif>
                        
                        <cfif structKeyExists(serviceFields, "additional_comments") AND len(trim(serviceFields.additional_comments))>
                            <div class="col-12 mb-3">
                                <div class="border-start border-3 border-primary ps-3">
                                    <strong>Additional Comments:</strong><br>
                                    <p class="mb-0 text-muted"><cfoutput>#replace(serviceFields.additional_comments, chr(10), "<br>", "all")#</cfoutput></p>
                                </div>
                            </div>
                        </cfif>
                        </div>
                    </div>
                    
                    <!--- Raw Form Data --->
                    <hr class="my-4">
                    <h5 class="text-primary mb-3">Raw Form Data (JSON)</h5>
                    <div class="bg-light p-3 rounded">
                        <pre class="mb-0" style="white-space: pre-wrap; word-wrap: break-word;"><code><cfoutput>#encodeForHTML(qForm.form_data)#</cfoutput></code></pre>
                    </div>
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
</style>

<cfinclude template="../includes/footer.cfm">