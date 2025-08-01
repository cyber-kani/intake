<cfparam name="url.id" default="">

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

<cfif qForm.is_finalized>
    <cflocation url="#application.basePath#/form-view.cfm?id=#qForm.reference_id#" addtoken="false">
</cfif>

<!--- Parse form data --->
<cfset formData = {}>
<cftry>
    <cfset formData = deserializeJSON(qForm.form_data)>
    <cfcatch>
        <cfset formData = {}>
    </cfcatch>
</cftry>

<cfinclude template="includes/header.cfm">

<div class="container mt-4">
    <div class="row justify-content-center">
        <div class="col-md-10">
            <h2 class="mb-4">Edit Customer Intake Form</h2>
            
            <div class="card shadow">
                <div class="card-body">
                    <div class="alert alert-info">
                        <i class="fas fa-info-circle"></i> You are editing a draft form. You can update the information and save changes or submit the final form.
                    </div>
                    
                    <!--- Display current form data --->
                    <table class="table">
                        <tr>
                            <th width="30%">Field</th>
                            <th>Value</th>
                        </tr>
                        <tr>
                            <td><strong>Project Type:</strong></td>
                            <td><cfoutput>#qForm.project_type#</cfoutput></td>
                        </tr>
                        <tr>
                            <td><strong>Service Type:</strong></td>
                            <td><cfoutput>#qForm.service_type#</cfoutput></td>
                        </tr>
                        <tr>
                            <td><strong>First Name:</strong></td>
                            <td><cfoutput>#qForm.first_name#</cfoutput></td>
                        </tr>
                        <tr>
                            <td><strong>Last Name:</strong></td>
                            <td><cfoutput>#qForm.last_name#</cfoutput></td>
                        </tr>
                        <tr>
                            <td><strong>Email:</strong></td>
                            <td><cfoutput>#qForm.email#</cfoutput></td>
                        </tr>
                        <tr>
                            <td><strong>Phone:</strong></td>
                            <td><cfoutput>#qForm.phone_number#</cfoutput></td>
                        </tr>
                        <tr>
                            <td><strong>Company:</strong></td>
                            <td><cfoutput>#qForm.company_name#</cfoutput></td>
                        </tr>
                    </table>
                    
                    
                    <div class="mt-4">
                        <a href="<cfoutput>#application.basePath#</cfoutput>/dashboard.cfm" class="btn btn-secondary">
                            <i class="fas fa-arrow-left"></i> Back to Dashboard
                        </a>
                        <form action="<cfoutput>#application.basePath#</cfoutput>/form-new.cfm" method="POST" style="display: inline;">
                            <input type="hidden" name="draft_id" value="<cfoutput>#qForm.form_id#</cfoutput>">
                            <input type="hidden" name="project_type" value="<cfoutput>#qForm.project_type#</cfoutput>">
                            <input type="hidden" name="service_type" value="<cfoutput>#qForm.service_type#</cfoutput>">
                            <input type="hidden" name="from_draft" value="true">
                            <button type="submit" class="btn btn-primary">
                                <i class="fas fa-edit"></i> Continue Editing Form
                            </button>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<cfinclude template="includes/footer.cfm">