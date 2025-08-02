<cfparam name="url.id" default="0">

<!--- Get form data --->
<cfset db = createObject("component", "components.Database")>

<!--- Check if ID is numeric (old style) or alphanumeric (reference_id) --->
<cfif isNumeric(url.id)>
    <cfset qForm = db.getFormById(url.id, session.user.userId)>
<cfelse>
    <cfset qForm = db.getFormByCode(url.id, session.user.userId)>
</cfif>

<cfif qForm.recordCount EQ 0>
    <cflocation url="#application.basePath#/dashboard.cfm" addtoken="false">
</cfif>

<cfif qForm.is_finalized>
    <cflocation url="#application.basePath#/form-view.cfm?id=#url.id#" addtoken="false">
</cfif>

<!--- Parse service fields --->
<cfset serviceFields = {}>
<cftry>
    <cfset serviceFields = deserializeJSON(qForm.form_data)>
    <cfcatch>
        <cfset serviceFields = {}>
    </cfcatch>
</cftry>

<cfinclude template="includes/header.cfm">

<div class="container mt-4">
    <div class="row justify-content-center">
        <div class="col-md-10">
            <h2 class="mb-4">Edit Customer Intake Form</h2>
            
            <cfif structKeyExists(url, "success")>
                <div class="alert alert-success alert-dismissible fade show">
                    Form saved successfully!
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            </cfif>
            
            <div class="card shadow">
                <div class="card-body">
                    <form action="<cfoutput>#application.basePath#</cfoutput>/form-save.cfm" method="POST">
                        <input type="hidden" name="form_id" value="<cfoutput>#qForm.form_id#</cfoutput>">
                        
                        <!--- Service Type Display --->
                        <div class="alert alert-info">
                            <strong>Service Type:</strong> 
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
                            <cfoutput>#serviceDisplay#</cfoutput>
                        </div>
                        <input type="hidden" name="service_type" value="<cfoutput>#qForm.service_type#</cfoutput>">

                        <!--- Contact Information --->
                        <h4 class="mb-4">Contact Information</h4>
                        
                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label class="form-label">First Name <span class="text-danger">*</span></label>
                                <input type="text" class="form-control" name="first_name" value="<cfoutput>#qForm.first_name#</cfoutput>" required>
                            </div>
                            <div class="col-md-6 mb-3">
                                <label class="form-label">Last Name <span class="text-danger">*</span></label>
                                <input type="text" class="form-control" name="last_name" value="<cfoutput>#qForm.last_name#</cfoutput>" required>
                            </div>
                        </div>
                        
                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label class="form-label">Email <span class="text-danger">*</span></label>
                                <input type="email" class="form-control" name="email" value="<cfoutput>#qForm.email#</cfoutput>" required>
                            </div>
                            <div class="col-md-6 mb-3">
                                <label class="form-label">Phone Number <span class="text-danger">*</span></label>
                                <input type="tel" class="form-control" name="phone_number" value="<cfoutput>#qForm.phone_number#</cfoutput>" required>
                            </div>
                        </div>

                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label class="form-label">Company Name</label>
                                <input type="text" class="form-control" name="company_name" value="<cfoutput>#qForm.company_name#</cfoutput>">
                            </div>
                            <div class="col-md-6 mb-3">
                                <label class="form-label">Preferred Contact Method</label>
                                <select class="form-select" name="preferred_contact_method">
                                    <option value="">Select...</option>
                                    <option value="email" <cfif qForm.preferred_contact_method EQ "email">selected</cfif>>Email</option>
                                    <option value="phone" <cfif qForm.preferred_contact_method EQ "phone">selected</cfif>>Phone</option>
                                    <option value="text" <cfif qForm.preferred_contact_method EQ "text">selected</cfif>>Text Message</option>
                                </select>
                            </div>
                        </div>

                        <!--- Project Details --->
                        <hr class="my-4">
                        <h4 class="mb-4">Project Details</h4>
                        
                        <cfif structKeyExists(serviceFields, "timeline")>
                            <input type="hidden" name="timeline" value="<cfoutput>#serviceFields.timeline#</cfoutput>">
                        </cfif>
                        <cfif structKeyExists(serviceFields, "budget")>
                            <input type="hidden" name="budget" value="<cfoutput>#serviceFields.budget#</cfoutput>">
                        </cfif>
                        
                        <div class="mb-3">
                            <label class="form-label">Project Description</label>
                            <textarea class="form-control" name="project_description" rows="4"><cfif structKeyExists(serviceFields, "project_description")><cfoutput>#serviceFields.project_description#</cfoutput></cfif></textarea>
                        </div>

                        <!--- Service-Specific Fields --->
                        <cfif NOT structIsEmpty(serviceFields)>
                            <hr class="my-4">
                            <h4 class="mb-4">Service-Specific Information</h4>
                            
                            <cfloop collection="#serviceFields#" item="fieldName">
                                <cfif NOT listFindNoCase("timeline,budget,project_description,referral_source,comments", fieldName)>
                                    <input type="hidden" name="<cfoutput>#fieldName#</cfoutput>" value="<cfoutput>#serviceFields[fieldName]#</cfoutput>">
                                </cfif>
                            </cfloop>
                            
                            <div class="alert alert-info">
                                Service-specific information has been saved and will be preserved.
                            </div>
                        </cfif>

                        <!--- Additional Information --->
                        <hr class="my-4">
                        <h4 class="mb-4">Additional Information</h4>
                        
                        <div class="mb-3">
                            <label class="form-label">Additional Comments</label>
                            <textarea class="form-control" name="comments" rows="3"><cfif structKeyExists(serviceFields, "comments")><cfoutput>#serviceFields.comments#</cfoutput></cfif></textarea>
                        </div>

                        <!--- Hidden fields --->
                        <input type="hidden" name="middle_name" value="<cfoutput>#qForm.middle_name#</cfoutput>">
                        <input type="hidden" name="date_of_birth" value="<cfoutput>#qForm.date_of_birth#</cfoutput>">
                        <input type="hidden" name="street_address" value="<cfoutput>#qForm.street_address#</cfoutput>">
                        <input type="hidden" name="city" value="<cfoutput>#qForm.city#</cfoutput>">
                        <input type="hidden" name="state_province" value="<cfoutput>#qForm.state_province#</cfoutput>">
                        <input type="hidden" name="postal_code" value="<cfoutput>#qForm.postal_code#</cfoutput>">
                        <input type="hidden" name="country" value="<cfoutput>#qForm.country#</cfoutput>">
                        <input type="hidden" name="job_title" value="<cfoutput>#qForm.job_title#</cfoutput>">
                        <input type="hidden" name="emergency_contact_name" value="<cfoutput>#qForm.emergency_contact_name#</cfoutput>">
                        <input type="hidden" name="emergency_contact_phone" value="<cfoutput>#qForm.emergency_contact_phone#</cfoutput>">
                        <cfif structKeyExists(serviceFields, "referral_source")>
                            <input type="hidden" name="referral_source" value="<cfoutput>#serviceFields.referral_source#</cfoutput>">
                        </cfif>

                        <!--- Form Actions --->
                        <div class="d-flex justify-content-between mt-4">
                            <a href="<cfoutput>#application.basePath#</cfoutput>/dashboard.cfm" class="btn btn-secondary">
                                <i class="fas fa-arrow-left"></i> Back to Dashboard
                            </a>
                            <div>
                                <button type="submit" name="action" value="save" class="btn btn-primary">
                                    <i class="fas fa-save"></i> Save Changes
                                </button>
                                <button type="submit" name="action" value="submit" class="btn btn-success" 
                                        onclick="return confirm('Are you sure you want to submit this form? Once submitted, it cannot be edited.')">
                                    <i class="fas fa-check"></i> Submit Form
                                </button>
                            </div>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>

<cfinclude template="includes/footer.cfm">