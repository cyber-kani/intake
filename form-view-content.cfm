<!--- Display form data with all fields from form_data JSON --->
<cfif structKeyExists(variables, "qForm") AND qForm.recordCount GT 0>
    <!--- Parse all form data --->
    <cfset allData = {}>
    <cftry>
        <cfset allData = deserializeJSON(qForm.form_data)>
        <cfcatch>
            <cfset allData = {}>
        </cfcatch>
    </cftry>
    
    <!--- Service Type --->
    <div class="mb-4">
        <h5 class="text-primary">Service Type</h5>
        <cfset serviceDisplay = "">
        <cfif findNoCase("_", qForm.service_type)>
            <cfset parts = listToArray(qForm.service_type, "_")>
            <cfif arrayLen(parts) GTE 2 AND structKeyExists(application.serviceCategories, parts[1])>
                <cfset cat = application.serviceCategories[parts[1]]>
                <cfset serviceKey = arrayToList(arraySlice(parts, 2), "_")>
                <cfif structKeyExists(cat.services, serviceKey)>
                    <cfset serviceDisplay = cat.services[serviceKey]>
                </cfif>
            </cfif>
        </cfif>
        <p class="fs-5"><cfoutput>#serviceDisplay#</cfoutput></p>
    </div>
    
    <!--- Contact Information --->
    <h5 class="text-primary mb-3">Contact Information</h5>
    <div class="row mb-4">
        <div class="col-md-6">
            <strong>Name:</strong> <cfoutput>#qForm.first_name# #qForm.last_name#</cfoutput><br>
            <strong>Email:</strong> <cfoutput>#qForm.email#</cfoutput><br>
            <strong>Phone:</strong> <cfoutput>#qForm.phone_number#</cfoutput>
        </div>
        <div class="col-md-6">
            <cfif len(qForm.company_name)>
                <strong>Company:</strong> <cfoutput>#qForm.company_name#</cfoutput><br>
            </cfif>
            <cfif structKeyExists(allData, "preferred_contact_method") AND len(allData.preferred_contact_method)>
                <strong>Preferred Contact:</strong> <cfoutput>#allData.preferred_contact_method#</cfoutput><br>
            </cfif>
        </div>
    </div>
    
    <!--- All Form Fields --->
    <cfif NOT structIsEmpty(allData)>
        <h5 class="text-primary mb-3">Form Details</h5>
        <div class="mb-4">
            <div class="row">
                <cfloop collection="#allData#" item="fieldName">
                    <cfif NOT listFindNoCase("serviceFields,project_type,service_type,first_name,last_name,email,phone_number,company_name", fieldName) AND len(allData[fieldName])>
                        <div class="col-md-6 mb-2">
                            <strong><cfoutput>#replace(replace(fieldName, "_", " ", "all"), "id", "ID")#</cfoutput>:</strong>
                            <cfif isArray(allData[fieldName])>
                                <cfoutput>#arrayToList(allData[fieldName], ", ")#</cfoutput>
                            <cfelse>
                                <cfoutput>#allData[fieldName]#</cfoutput>
                            </cfif>
                        </div>
                    </cfif>
                </cfloop>
            </div>
        </div>
    </cfif>
    
    <!--- Form Metadata --->
    <hr class="my-4">
    <div class="text-muted small">
        <strong>Form ID:</strong> <cfoutput>#qForm.form_id#</cfoutput><br>
        <strong>Created:</strong> <cfoutput>#dateTimeFormat(qForm.created_at, "mm/dd/yyyy hh:nn tt")#</cfoutput><br>
        <cfif qForm.is_finalized AND isDate(qForm.submitted_at)>
            <strong>Submitted:</strong> <cfoutput>#dateTimeFormat(qForm.submitted_at, "mm/dd/yyyy hh:nn tt")#</cfoutput>
        </cfif>
    </div>
</cfif>