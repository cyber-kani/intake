<!--- Admin check is done in Application.cfc --->

<!--- Get all forms --->
<cfquery name="qAllForms" datasource="clitools">
    SELECT f.form_id, f.form_code, f.reference_id, 
           COALESCE(f.service_type, '') as service_type,
           f.project_type, f.first_name, f.last_name, f.email as email,
           f.is_finalized, f.created_at, f.submitted_at, f.form_data,
           f.user_id, u.email as user_email, u.display_name
    FROM IntakeForms f
    INNER JOIN Users u ON f.user_id = u.user_id
    ORDER BY f.created_at DESC
</cfquery>

<cfinclude template="../includes/header.cfm">

<div class="container-fluid mt-4">
    <cfif qAllForms.recordCount GT 0>
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h2 class="mb-0">All Intake Forms</h2>
        </div>
        
        <div class="card">
            <div class="card-body">
                <div class="table-responsive">
                    <table class="table table-hover">
                        <thead>
                            <tr>
                                <th>Form ID</th>
                                <th>Service Type</th>
                                <th>Name</th>
                                <th>Email</th>
                                <th>Status</th>
                                <th>Created</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                        <cfloop query="qAllForms">
                            <tr>
                                <td>
                                    <cfif structKeyExists(qAllForms, "reference_id") AND len(qAllForms.reference_id)>
                                        <span class="badge bg-primary"><cfoutput>#qAllForms.reference_id#</cfoutput></span>
                                    <cfelse>
                                        #<cfoutput>#qAllForms.form_id#</cfoutput>
                                    </cfif>
                                </td>
                                <td>
                                    <cfset serviceDisplay = "">
                                    <cfset serviceTypeValue = qAllForms.service_type>
                                    
                                    <!--- If service_type is empty, try to get it from form_data JSON --->
                                    <cfif NOT len(trim(serviceTypeValue)) AND len(trim(qAllForms.form_data))>
                                        <cftry>
                                            <cfset formDataObj = deserializeJSON(qAllForms.form_data)>
                                            <cfif structKeyExists(formDataObj, "service_type")>
                                                <cfset serviceTypeValue = formDataObj.service_type>
                                            <cfelseif structKeyExists(formDataObj, "serviceFields") AND structKeyExists(formDataObj.serviceFields, "service_type")>
                                                <cfset serviceTypeValue = formDataObj.serviceFields.service_type>
                                            <cfelseif structKeyExists(formDataObj, "ai_conversation") AND isSimpleValue(formDataObj.ai_conversation)>
                                                <!--- Try to extract from ai_conversation field --->
                                                <cftry>
                                                    <cfset aiConvData = deserializeJSON(formDataObj.ai_conversation)>
                                                    <cfif structKeyExists(aiConvData, "projectInfo") AND structKeyExists(aiConvData.projectInfo, "service_type")>
                                                        <cfset serviceTypeValue = aiConvData.projectInfo.service_type>
                                                    </cfif>
                                                    <cfcatch>
                                                        <!--- Nested JSON parse error --->
                                                    </cfcatch>
                                                </cftry>
                                            </cfif>
                                            <cfcatch>
                                                <!--- Invalid JSON, ignore --->
                                            </cfcatch>
                                        </cftry>
                                    </cfif>
                                    
                                    <cfif len(trim(serviceTypeValue))>
                                        <!--- Parse service type to make it human readable --->
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
                                            
                                            <small>
                                                <span class="badge <cfoutput>#badgeClass#</cfoutput>" style="font-size: 0.65rem;"><cfoutput>#ucase(serviceCategory)#</cfoutput></span><br>
                                                <cfoutput>#serviceType#</cfoutput>
                                            </small>
                                        <cfelse>
                                            <!--- If no underscore, just display as is but capitalize --->
                                            <cfset displayValue = reReplace(serviceTypeValue, "\b(\w)", "\u\1", "all")>
                                            <small><cfoutput>#displayValue#</cfoutput></small>
                                        </cfif>
                                    <cfelse>
                                        <small class="text-muted">Not specified</small>
                                    </cfif>
                                </td>
                                <td><cfoutput>#qAllForms.first_name# #qAllForms.last_name#</cfoutput></td>
                                <td><cfoutput>#qAllForms.email#</cfoutput></td>
                                <td>
                                    <cfif qAllForms.is_finalized>
                                        <span class="badge bg-success">
                                            <i class="fas fa-check-circle"></i> Submitted
                                        </span>
                                    <cfelse>
                                        <span class="badge bg-warning">
                                            <i class="fas fa-edit"></i> Draft
                                        </span>
                                    </cfif>
                                </td>
                                <td><cfoutput>#dateFormat(qAllForms.created_at, "mm/dd/yyyy")#</cfoutput></td>
                                <td>
                                    <div class="btn-group" role="group">
                                        <a href="<cfoutput>#application.basePath#</cfoutput>/admin/view.cfm?id=<cfoutput>#qAllForms.form_id#</cfoutput>" 
                                           class="btn btn-sm btn-outline-primary">
                                            <i class="fas fa-eye"></i>
                                        </a>
                                        <button type="button" class="btn btn-sm btn-outline-danger" 
                                                onclick="deleteForm(<cfoutput>#qAllForms.form_id#</cfoutput>, '<cfoutput>#qAllForms.first_name# #qAllForms.last_name#</cfoutput>')">
                                            <i class="fas fa-trash"></i>
                                        </button>
                                    </div>
                                </td>
                            </tr>
                        </cfloop>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    <cfelse>
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h2 class="mb-0">All Intake Forms</h2>
        </div>
        
        <div class="card">
            <div class="card-body text-center py-5">
                <i class="fas fa-clipboard-list fa-4x text-muted mb-4"></i>
                <h4>No Forms Yet</h4>
                <p class="text-muted">No intake forms have been created yet.</p>
            </div>
        </div>
    </cfif>
</div>

<!--- Delete Confirmation Modal --->
<div class="modal fade" id="deleteModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header bg-danger text-white">
                <h5 class="modal-title">
                    <i class="fas fa-exclamation-triangle"></i> Confirm Delete
                </h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <p>Are you sure you want to delete this form?</p>
                <p class="mb-0"><strong>Customer:</strong> <span id="deleteCustomerName"></span></p>
                <p class="text-danger mt-3 mb-0"><i class="fas fa-warning"></i> This action cannot be undone!</p>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                <button type="button" class="btn btn-danger" id="confirmDeleteBtn">
                    <i class="fas fa-trash"></i> Delete Form
                </button>
            </div>
        </div>
    </div>
</div>

<script>
let formToDelete = null;

function deleteForm(formId, customerName) {
    formToDelete = formId;
    document.getElementById('deleteCustomerName').textContent = customerName;
    const modal = new bootstrap.Modal(document.getElementById('deleteModal'));
    modal.show();
}

document.getElementById('confirmDeleteBtn').addEventListener('click', function() {
    if (!formToDelete) return;
    
    // Disable button and show loading
    this.disabled = true;
    this.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Deleting...';
    
    fetch('<cfoutput>#application.basePath#</cfoutput>/admin/delete-form.cfm', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({ formId: formToDelete })
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            // Close modal and reload page
            bootstrap.Modal.getInstance(document.getElementById('deleteModal')).hide();
            location.reload();
        } else {
            alert('Error deleting form: ' + (data.error || 'Unknown error'));
            // Re-enable button
            this.disabled = false;
            this.innerHTML = '<i class="fas fa-trash"></i> Delete Form';
        }
    })
    .catch(error => {
        alert('Error deleting form: ' + error);
        // Re-enable button
        this.disabled = false;
        this.innerHTML = '<i class="fas fa-trash"></i> Delete Form';
    });
});
</script>

<cfinclude template="../includes/footer.cfm">