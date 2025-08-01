<!--- Get user's forms --->
<cfset db = createObject("component", "components.Database")>
<cfset qForms = db.getUserForms(session.user.userId)>

<cfinclude template="includes/header.cfm">

<div class="container-fluid mt-4">
    <cfif qForms.recordCount GT 0>
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h2 class="mb-0">My Intake Forms</h2>
            <a href="<cfoutput>#application.basePath#</cfoutput>/index.cfm?new=true" class="btn btn-primary">
                <i class="fas fa-plus-circle"></i> Create New Form
            </a>
        </div>
        
        <cfif structKeyExists(url, "success")>
            <div class="alert alert-success alert-dismissible fade show">
                <i class="fas fa-check-circle"></i> 
                <cfif url.success EQ "submitted">
                    Your form has been submitted successfully!
                <cfelse>
                    <cfoutput>#url.success#</cfoutput>
                </cfif>
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </cfif>
        
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
                            <cfloop query="qForms">
                                <tr>
                                    <td>
                                        <cfif structKeyExists(qForms, "reference_id") AND len(qForms.reference_id)>
                                            <span class="badge bg-primary"><cfoutput>#qForms.reference_id#</cfoutput></span>
                                        <cfelse>
                                            <!--- Generate reference ID on the fly if missing --->
                                            <cfset tempRefId = "">
                                            <cfset chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789">
                                            <cfloop from="1" to="8" index="i">
                                                <cfset tempRefId = tempRefId & mid(chars, randRange(1, len(chars)), 1)>
                                            </cfloop>
                                            
                                            <!--- Update the database with this reference ID --->
                                            <cfquery datasource="clitools">
                                                UPDATE IntakeForms
                                                SET reference_id = <cfqueryparam value="#tempRefId#" cfsqltype="cf_sql_varchar">
                                                WHERE form_id = <cfqueryparam value="#qForms.form_id#" cfsqltype="cf_sql_integer">
                                                AND (reference_id IS NULL OR reference_id = '')
                                            </cfquery>
                                            
                                            <span class="badge bg-primary"><cfoutput>#tempRefId#</cfoutput></span>
                                        </cfif>
                                    </td>
                                    <td>
                                        <cfset serviceDisplay = "">
                                        <cfset serviceTypeValue = qForms.service_type>
                                        
                                        <!--- If service_type is empty, try to get it from form_data JSON --->
                                        <cfif NOT len(trim(serviceTypeValue)) AND len(trim(qForms.form_data))>
                                            <cftry>
                                                <cfset formDataObj = deserializeJSON(qForms.form_data)>
                                                <cfif structKeyExists(formDataObj, "service_type")>
                                                    <cfset serviceTypeValue = formDataObj.service_type>
                                                <cfelseif structKeyExists(formDataObj, "serviceFields") AND structKeyExists(formDataObj.serviceFields, "service_type")>
                                                    <cfset serviceTypeValue = formDataObj.serviceFields.service_type>
                                                </cfif>
                                                <cfcatch>
                                                    <!--- JSON parse error, ignore --->
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
                                    <td><cfoutput>#qForms.first_name# #qForms.last_name#</cfoutput></td>
                                    <td><cfoutput>#qForms.email#</cfoutput></td>
                                    <td>
                                        <cfif qForms.is_finalized>
                                            <span class="badge bg-success">
                                                <i class="fas fa-check-circle"></i> Submitted
                                            </span>
                                        <cfelse>
                                            <!--- Check if this is an AI draft --->
                                            <cfset isAIDraftStatus = false>
                                            <cfif len(trim(qForms.form_data))>
                                                <cftry>
                                                    <cfset formDataObj = deserializeJSON(qForms.form_data)>
                                                    <cfif structKeyExists(formDataObj, "ai_draft") AND formDataObj.ai_draft EQ true>
                                                        <cfset isAIDraftStatus = true>
                                                    </cfif>
                                                    <cfcatch>
                                                        <!--- Invalid JSON, ignore --->
                                                    </cfcatch>
                                                </cftry>
                                            </cfif>
                                            
                                            <cfif isAIDraftStatus>
                                                <span class="badge bg-info">
                                                    <i class="fas fa-robot"></i> AI Draft
                                                </span>
                                            <cfelse>
                                                <span class="badge bg-warning">
                                                    <i class="fas fa-edit"></i> Draft
                                                </span>
                                            </cfif>
                                        </cfif>
                                    </td>
                                    <td><cfoutput>#dateFormat(qForms.created_at, "mm/dd/yyyy")#</cfoutput></td>
                                    <td>
                                        <cfif qForms.is_finalized>
                                            <a href="<cfoutput>#application.basePath#</cfoutput>/form-view.cfm?id=<cfoutput>#structKeyExists(qForms, "reference_id") AND len(qForms.reference_id) ? qForms.reference_id : qForms.form_id#</cfoutput>" class="btn btn-sm btn-outline-primary">
                                                <i class="fas fa-eye"></i> View
                                            </a>
                                        <cfelse>
                                            <div class="btn-group" role="group">
                                                <!--- Check if this is an AI draft --->
                                                <cfset isAIDraft = false>
                                                <cfif len(trim(qForms.form_data))>
                                                    <cftry>
                                                        <cfset formDataObj = deserializeJSON(qForms.form_data)>
                                                        <cfif structKeyExists(formDataObj, "ai_draft") AND formDataObj.ai_draft EQ true>
                                                            <cfset isAIDraft = true>
                                                        </cfif>
                                                        <cfcatch>
                                                            <!--- Invalid JSON, ignore --->
                                                        </cfcatch>
                                                    </cftry>
                                                </cfif>
                                                
                                                <cfif isAIDraft>
                                                    <a href="<cfoutput>#application.basePath#</cfoutput>/form-new-ai.cfm?id=<cfoutput>#structKeyExists(qForms, "reference_id") AND len(qForms.reference_id) ? qForms.reference_id : qForms.form_id#</cfoutput>" class="btn btn-sm btn-outline-primary">
                                                        <i class="fas fa-comments"></i> Continue Chat
                                                    </a>
                                                <cfelse>
                                                    <a href="<cfoutput>#application.basePath#</cfoutput>/form-edit-simple.cfm?id=<cfoutput>#structKeyExists(qForms, "reference_id") AND len(qForms.reference_id) ? qForms.reference_id : qForms.form_id#</cfoutput>" class="btn btn-sm btn-outline-primary">
                                                        <i class="fas fa-edit"></i> Edit
                                                    </a>
                                                </cfif>
                                                <button type="button" class="btn btn-sm btn-outline-danger" onclick="deleteForm('<cfoutput>#structKeyExists(qForms, "reference_id") AND len(qForms.reference_id) ? qForms.reference_id : qForms.form_id#</cfoutput>')">
                                                    <i class="fas fa-trash"></i> Delete
                                                </button>
                                            </div>
                                        </cfif>
                                    </td>
                                </tr>
                            </cfloop>
                        </tbody>
                    </table>
                </div>
            <cfelse>
                <div class="card">
                    <div class="card-body text-center py-5">
                        <i class="fas fa-clipboard-list fa-4x text-muted mb-4"></i>
                        <h4>No Forms Yet</h4>
                        <p class="text-muted">You haven't created any intake forms yet.</p>
                        <a href="<cfoutput>#application.basePath#</cfoutput>/index.cfm?new=true" class="btn btn-primary">
                            <i class="fas fa-plus-circle"></i> Start Your Project
                        </a>
                    </div>
                </div>
            </cfif>
        </div>
    </div>
</div>

<!--- Delete Confirmation Modal --->
<div class="modal fade" id="deleteModal" tabindex="-1" aria-labelledby="deleteModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header border-0">
                <h5 class="modal-title" id="deleteModalLabel">
                    <i class="fas fa-exclamation-triangle text-warning"></i> Confirm Delete
                </h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body text-center py-4">
                <div class="mb-3">
                    <i class="fas fa-trash-alt fa-4x text-danger opacity-50"></i>
                </div>
                <h6>Are you sure you want to delete this form?</h6>
                <p class="text-muted small mb-0">This action cannot be undone.</p>
            </div>
            <div class="modal-footer border-0 justify-content-center">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">
                    <i class="fas fa-times"></i> Cancel
                </button>
                <button type="button" class="btn btn-danger" id="confirmDeleteBtn">
                    <i class="fas fa-trash"></i> Delete Form
                </button>
            </div>
        </div>
    </div>
</div>

<style>
.modal-content {
    border-radius: 15px;
    box-shadow: 0 10px 40px rgba(0,0,0,0.1);
}

.modal-header {
    background-color: #f8f9fa;
    border-radius: 15px 15px 0 0;
}

.modal-footer {
    background-color: #f8f9fa;
    border-radius: 0 0 15px 15px;
}

#deleteModal .modal-body {
    padding: 2rem;
}

.btn {
    padding: 0.5rem 1.5rem;
    border-radius: 8px;
    font-weight: 500;
}

.btn-danger {
    background-color: #dc3545;
    border-color: #dc3545;
}

.btn-danger:hover {
    background-color: #c82333;
    border-color: #bd2130;
}
</style>

<script>
let formToDelete = null;

function deleteForm(formIdentifier) {
    formToDelete = formIdentifier;
    const deleteModal = new bootstrap.Modal(document.getElementById('deleteModal'));
    deleteModal.show();
}

document.getElementById('confirmDeleteBtn').addEventListener('click', function() {
    if (formToDelete) {
        // Show loading state
        const btn = this;
        const originalHTML = btn.innerHTML;
        btn.disabled = true;
        btn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Deleting...';
        
        // Determine if it's a numeric ID or form code
        const isNumeric = /^\d+$/.test(formToDelete);
        const payload = isNumeric ? { formId: parseInt(formToDelete) } : { formCode: formToDelete };
        
        fetch('<cfoutput>#application.basePath#</cfoutput>/api/delete-form.cfm', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(payload)
        })
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                // Hide modal
                const deleteModal = bootstrap.Modal.getInstance(document.getElementById('deleteModal'));
                deleteModal.hide();
                
                // Show success message
                const alertDiv = document.createElement('div');
                alertDiv.className = 'alert alert-success alert-dismissible fade show position-fixed top-0 start-50 translate-middle-x mt-3';
                alertDiv.style.zIndex = '9999';
                alertDiv.innerHTML = `
                    <i class="fas fa-check-circle"></i> Form deleted successfully!
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                `;
                document.body.appendChild(alertDiv);
                
                // Reload after short delay
                setTimeout(() => {
                    location.reload();
                }, 1000);
            } else {
                // Show error
                btn.disabled = false;
                btn.innerHTML = originalHTML;
                
                const alertDiv = document.createElement('div');
                alertDiv.className = 'alert alert-danger alert-dismissible fade show position-fixed top-0 start-50 translate-middle-x mt-3';
                alertDiv.style.zIndex = '9999';
                alertDiv.innerHTML = `
                    <i class="fas fa-exclamation-circle"></i> Error: ${data.error}
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                `;
                document.body.appendChild(alertDiv);
                
                // Hide modal
                const deleteModal = bootstrap.Modal.getInstance(document.getElementById('deleteModal'));
                deleteModal.hide();
            }
        })
        .catch(error => {
            btn.disabled = false;
            btn.innerHTML = originalHTML;
            alert('Error deleting form: ' + error);
        });
    }
});
</script>

<cfinclude template="includes/footer.cfm">