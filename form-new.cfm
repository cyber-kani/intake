<!--- Check if application variables exist --->
<cfif NOT structKeyExists(application, "projectTypes")>
    <cfset applicationStop()>
    <cflocation url="#cgi.script_name#" addtoken="false">
</cfif>

<cfinclude template="includes/header.cfm">

<!--- Get project type from AI discovery or draft --->
<cfparam name="form.project_type" default="">
<cfparam name="form.project_description" default="">
<cfparam name="form.service_category" default="">
<cfparam name="form.service_type" default="">
<cfparam name="form.from_ai" default="false">
<cfparam name="form.from_draft" default="false">
<cfparam name="form.draft_id" default="0">

<cfset preSelectedType = form.project_type>
<cfset preSelectedCategory = form.service_category>
<cfset preSelectedService = form.service_type>
<cfset fromAI = form.from_ai>
<cfset fromDraft = form.from_draft>
<cfset draftId = form.draft_id>
<cfset startStep = 1>

<!--- Load draft data if editing --->
<cfset draftData = {}>
<cfif fromDraft AND draftId GT 0>
    <cfset db = createObject("component", "components.Database")>
    <cfset qDraft = db.getFormById(draftId, session.user.userId)>
    <cfif qDraft.recordCount GT 0>
        <cftry>
            <cfset draftData = deserializeJSON(qDraft.form_data)>
            <cfcatch>
                <cfset draftData = {}>
            </cfcatch>
        </cftry>
        <cfset preSelectedType = qDraft.project_type>
        <cfset preSelectedService = qDraft.service_type>
        
        <!--- Start from the saved step --->
        <cfif structKeyExists(draftData, "current_step")>
            <cfset startStep = draftData.current_step>
        <cfelseif len(preSelectedService)>
            <cfset startStep = 3>
        <cfelseif len(preSelectedType)>
            <cfset startStep = 2>
        </cfif>
    </cfif>
</cfif>

<!--- If we have a complete service selection from AI, skip to step 3 --->
<cfif len(preSelectedType) AND len(preSelectedService) AND fromAI>
    <cfset startStep = 3>
    <!--- Auto-save as draft --->
    <cfset session.formDraft = {
        "project_type" = preSelectedType,
        "service_category" = preSelectedCategory,
        "service_type" = preSelectedService,
        "project_description" = form.project_description,
        "from_ai" = true,
        "created_at" = now()
    }>
<!--- If we only have project type, start at step 2 --->
<cfelseif len(preSelectedType) AND fromAI>
    <cfset startStep = 2>
</cfif>

<div class="container mt-4">
    <div class="row justify-content-center">
        <div class="col-md-10">
            <h2 class="mb-4">Create New Customer Intake Form</h2>
            
            <!--- Progress Bar --->
            <div class="progress mb-4" style="height: 30px;">
                <div class="progress-bar" role="progressbar" style="width: 16%;" id="progressBar">
                    Step 1 of 6
                </div>
            </div>
            
            <div class="card shadow">
                <div class="card-body">
                    <form action="<cfoutput>#application.basePath#</cfoutput>/form-save.cfm" method="POST" id="intakeForm" novalidate>
                        
                        <!--- Include form_id if editing a draft --->
                        <cfif draftId GT 0>
                            <input type="hidden" name="form_id" value="<cfoutput>#draftId#</cfoutput>">
                        </cfif>
                        
                        <!--- Step 1: Project Type Selection --->
                        <div class="form-step active" id="step1">
                            <h4 class="mb-4 text-center">What type of project do you need?</h4>
                            
                            <div class="row justify-content-center">
                                <cfif structKeyExists(application, "projectTypes")>
                                    <cfloop collection="#application.projectTypes#" item="typeKey">
                                        <cfset projectType = application.projectTypes[typeKey]>
                                        <div class="col-md-4 mb-3">
                                            <div class="project-type-card card h-100" onclick="selectProjectType('<cfoutput>#typeKey#</cfoutput>')">
                                                <div class="card-body text-center p-4">
                                                    <i class="fas <cfoutput>#projectType.icon#</cfoutput> fa-3x mb-3" style="color: #0d6efd;"></i>
                                                    <h5 class="card-title"><cfoutput>#projectType.name#</cfoutput></h5>
                                                    <p class="card-text text-muted"><cfoutput>#projectType.description#</cfoutput></p>
                                                    <input type="radio" name="project_type" id="project_<cfoutput>#typeKey#</cfoutput>" value="<cfoutput>#typeKey#</cfoutput>" class="d-none" required>
                                                </div>
                                            </div>
                                        </div>
                                    </cfloop>
                                <cfelse>
                                    <!--- Fallback if projectTypes not defined --->
                                    <div class="col-md-4 mb-3">
                                        <div class="project-type-card card h-100" onclick="selectProjectType('website')">
                                            <div class="card-body text-center p-4">
                                                <i class="fas fa-globe fa-3x mb-3" style="color: #0d6efd;"></i>
                                                <h5 class="card-title">Website Development</h5>
                                                <p class="card-text text-muted">Custom websites, e-commerce, corporate sites</p>
                                                <input type="radio" name="project_type" id="project_website" value="website" class="d-none" required>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-md-4 mb-3">
                                        <div class="project-type-card card h-100" onclick="selectProjectType('mobile')">
                                            <div class="card-body text-center p-4">
                                                <i class="fas fa-mobile-alt fa-3x mb-3" style="color: #0d6efd;"></i>
                                                <h5 class="card-title">Mobile App Development</h5>
                                                <p class="card-text text-muted">iOS, Android, and cross-platform apps</p>
                                                <input type="radio" name="project_type" id="project_mobile" value="mobile" class="d-none" required>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-md-4 mb-3">
                                        <div class="project-type-card card h-100" onclick="selectProjectType('saas')">
                                            <div class="card-body text-center p-4">
                                                <i class="fas fa-cloud fa-3x mb-3" style="color: #0d6efd;"></i>
                                                <h5 class="card-title">SaaS Application</h5>
                                                <p class="card-text text-muted">Cloud-based software platforms</p>
                                                <input type="radio" name="project_type" id="project_saas" value="saas" class="d-none" required>
                                            </div>
                                        </div>
                                    </div>
                                </cfif>
                            </div>
                        </div>

                        <!--- Step 2: Service Selection --->
                        <div class="form-step" id="step2" style="display: none;">
                            <h4 class="mb-4">Select your specific service</h4>
                            
                            <div class="accordion" id="serviceAccordion">
                                <!--- Will be populated dynamically based on project type --->
                            </div>
                        </div>

                        <!--- Step 3: Basic Information --->
                        <div class="form-step" id="step3" style="display: none;">
                            <h4 class="mb-4">Tell us about yourself</h4>
                            
                            <div class="row">
                                <div class="col-md-6 mb-3">
                                    <label class="form-label">First Name <span class="text-danger">*</span></label>
                                    <input type="text" class="form-control" name="first_name" required>
                                </div>
                                <div class="col-md-6 mb-3">
                                    <label class="form-label">Last Name <span class="text-danger">*</span></label>
                                    <input type="text" class="form-control" name="last_name" required>
                                </div>
                            </div>
                            
                            <div class="row">
                                <div class="col-md-6 mb-3">
                                    <label class="form-label">Email <span class="text-danger">*</span></label>
                                    <input type="email" class="form-control" name="email" value="<cfoutput>#session.user.email#</cfoutput>" required>
                                </div>
                                <div class="col-md-6 mb-3">
                                    <label class="form-label">Phone Number <span class="text-danger">*</span></label>
                                    <input type="tel" class="form-control" name="phone_number" required>
                                </div>
                            </div>

                            <div class="row">
                                <div class="col-md-6 mb-3">
                                    <label class="form-label">Company/Organization Name <span class="text-danger">*</span></label>
                                    <input type="text" class="form-control" name="company_name" required>
                                </div>
                                <div class="col-md-6 mb-3">
                                    <label class="form-label">Industry/Business Type <span class="text-danger">*</span></label>
                                    <input type="text" class="form-control" name="industry" placeholder="e.g., Healthcare, Retail, Education" required>
                                </div>
                            </div>

                            <div class="row">
                                <div class="col-md-6 mb-3">
                                    <label class="form-label">Website (if existing) <span class="text-danger">*</span><br><small class="text-muted">Enter URL or type "no" if you don't have a website</small></label>
                                    <input type="text" class="form-control" name="current_website" placeholder="https://example.com or 'no'" required>
                                </div>
                                <div class="col-md-6 mb-3">
                                    <label class="form-label">Preferred Contact Method <span class="text-danger">*</span></label>
                                    <select class="form-select" name="preferred_contact_method" required>
                                        <option value="email">Email</option>
                                        <option value="phone">Phone</option>
                                        <option value="text">Text Message</option>
                                        <option value="whatsapp">WhatsApp</option>
                                    </select>
                                </div>
                            </div>
                        </div>

                        <!--- Step 4: Project Details --->
                        <div class="form-step" id="step4" style="display: none;">
                            <h4 class="mb-4">Project Details</h4>
                            
                            <div class="mb-3">
                                <label class="form-label">Project Description <span class="text-danger">*</span></label>
                                <textarea class="form-control" name="project_description" rows="4" required 
                                    placeholder="Please describe your project, what you want to achieve, and any specific requirements..."></textarea>
                            </div>

                            <div class="row">
                                <div class="col-md-6 mb-3">
                                    <label class="form-label">Target Audience <span class="text-danger">*</span></label>
                                    <input type="text" class="form-control" name="target_audience" 
                                        placeholder="Who is your primary audience?" required>
                                </div>
                                <div class="col-md-6 mb-3">
                                    <label class="form-label">Geographic Target <span class="text-danger">*</span></label>
                                    <select class="form-select" name="geographic_target" required>
                                        <option value="" selected disabled>Please select...</option>
                                        <option value="local">Local (City/Region)</option>
                                        <option value="national">National</option>
                                        <option value="international">International</option>
                                        <option value="specific">Specific Countries/Regions</option>
                                    </select>
                                </div>
                            </div>

                            <div class="row">
                                <div class="col-md-6 mb-3">
                                    <label class="form-label">Project Timeline <span class="text-danger">*</span></label>
                                    <select class="form-select" name="timeline" required>
                                        <option value="" selected disabled>Please select...</option>
                                        <option value="asap">ASAP</option>
                                        <option value="1_month">Within 1 month</option>
                                        <option value="2_months">Within 2 months</option>
                                        <option value="3_months">Within 3 months</option>
                                        <option value="6_months">Within 6 months</option>
                                        <option value="flexible">Flexible</option>
                                    </select>
                                </div>
                                <div class="col-md-6 mb-3">
                                    <label class="form-label">Budget Range <span class="text-danger">*</span></label>
                                    <select class="form-select" name="budget_range" required>
                                        <option value="" selected disabled>Please select...</option>
                                        <option value="under_1k">Under $1,000</option>
                                        <option value="1k_5k">$1,000 - $5,000</option>
                                        <option value="5k_10k">$5,000 - $10,000</option>
                                        <option value="10k_25k">$10,000 - $25,000</option>
                                        <option value="25k_50k">$25,000 - $50,000</option>
                                        <option value="50k_plus">$50,000+</option>
                                        <option value="not_sure">Not sure yet</option>
                                    </select>
                                </div>
                            </div>

                            <div id="serviceSpecificQuestions">
                                <!--- Dynamic questions based on service type will be inserted here --->
                            </div>
                        </div>

                        <!--- Step 5: Design & Functionality --->
                        <div class="form-step" id="step5" style="display: none;">
                            <h4 class="mb-4">Design & Functionality Preferences</h4>
                            
                            <div class="mb-3">
                                <label class="form-label">Design Style Preference <span class="text-danger">*</span></label>
                                <select class="form-select" name="design_style" required>
                                    <option value="">Select...</option>
                                    <option value="modern_minimal">Modern & Minimal</option>
                                    <option value="corporate_professional">Corporate & Professional</option>
                                    <option value="creative_bold">Creative & Bold</option>
                                    <option value="friendly_approachable">Friendly & Approachable</option>
                                    <option value="elegant_sophisticated">Elegant & Sophisticated</option>
                                    <option value="tech_futuristic">Tech & Futuristic</option>
                                    <option value="no_preference">No Preference</option>
                                </select>
                            </div>

                            <div class="mb-3">
                                <label class="form-label">Color Preferences <span class="text-danger">*</span> <small class="text-muted">(Select at least one)</small></label>
                                <div class="color-palette-container">
                                    <div class="row g-2 mb-3">
                                        <!--- Popular Colors --->
                                        <div class="col-3 col-md-2">
                                            <div class="color-option" data-color="#FF0000" style="background-color: #FF0000;" title="Red">
                                                <input type="checkbox" name="color_preferences[]" value="#FF0000" class="color-checkbox">
                                                <i class="fas fa-check color-check"></i>
                                            </div>
                                            <small class="d-block text-center mt-1">Red</small>
                                        </div>
                                        <div class="col-3 col-md-2">
                                            <div class="color-option" data-color="#FF6B6B" style="background-color: #FF6B6B;" title="Light Red">
                                                <input type="checkbox" name="color_preferences[]" value="#FF6B6B" class="color-checkbox">
                                                <i class="fas fa-check color-check"></i>
                                            </div>
                                            <small class="d-block text-center mt-1">Light Red</small>
                                        </div>
                                        <div class="col-3 col-md-2">
                                            <div class="color-option" data-color="#4ECDC4" style="background-color: #4ECDC4;" title="Teal">
                                                <input type="checkbox" name="color_preferences[]" value="#4ECDC4" class="color-checkbox">
                                                <i class="fas fa-check color-check"></i>
                                            </div>
                                            <small class="d-block text-center mt-1">Teal</small>
                                        </div>
                                        <div class="col-3 col-md-2">
                                            <div class="color-option" data-color="#45B7D1" style="background-color: #45B7D1;" title="Sky Blue">
                                                <input type="checkbox" name="color_preferences[]" value="#45B7D1" class="color-checkbox">
                                                <i class="fas fa-check color-check"></i>
                                            </div>
                                            <small class="d-block text-center mt-1">Sky Blue</small>
                                        </div>
                                        <div class="col-3 col-md-2">
                                            <div class="color-option" data-color="#0000FF" style="background-color: #0000FF;" title="Blue">
                                                <input type="checkbox" name="color_preferences[]" value="#0000FF" class="color-checkbox">
                                                <i class="fas fa-check color-check"></i>
                                            </div>
                                            <small class="d-block text-center mt-1">Blue</small>
                                        </div>
                                        <div class="col-3 col-md-2">
                                            <div class="color-option" data-color="#1E3A8A" style="background-color: #1E3A8A;" title="Navy">
                                                <input type="checkbox" name="color_preferences[]" value="#1E3A8A" class="color-checkbox">
                                                <i class="fas fa-check color-check"></i>
                                            </div>
                                            <small class="d-block text-center mt-1">Navy</small>
                                        </div>
                                        <div class="col-3 col-md-2">
                                            <div class="color-option" data-color="#00FF00" style="background-color: #00FF00;" title="Green">
                                                <input type="checkbox" name="color_preferences[]" value="#00FF00" class="color-checkbox">
                                                <i class="fas fa-check color-check"></i>
                                            </div>
                                            <small class="d-block text-center mt-1">Green</small>
                                        </div>
                                        <div class="col-3 col-md-2">
                                            <div class="color-option" data-color="#10B981" style="background-color: #10B981;" title="Emerald">
                                                <input type="checkbox" name="color_preferences[]" value="#10B981" class="color-checkbox">
                                                <i class="fas fa-check color-check"></i>
                                            </div>
                                            <small class="d-block text-center mt-1">Emerald</small>
                                        </div>
                                        <div class="col-3 col-md-2">
                                            <div class="color-option" data-color="#FFFF00" style="background-color: #FFFF00;" title="Yellow">
                                                <input type="checkbox" name="color_preferences[]" value="#FFFF00" class="color-checkbox">
                                                <i class="fas fa-check color-check"></i>
                                            </div>
                                            <small class="d-block text-center mt-1">Yellow</small>
                                        </div>
                                        <div class="col-3 col-md-2">
                                            <div class="color-option" data-color="#FFA500" style="background-color: #FFA500;" title="Orange">
                                                <input type="checkbox" name="color_preferences[]" value="#FFA500" class="color-checkbox">
                                                <i class="fas fa-check color-check"></i>
                                            </div>
                                            <small class="d-block text-center mt-1">Orange</small>
                                        </div>
                                        <div class="col-3 col-md-2">
                                            <div class="color-option" data-color="#800080" style="background-color: #800080;" title="Purple">
                                                <input type="checkbox" name="color_preferences[]" value="#800080" class="color-checkbox">
                                                <i class="fas fa-check color-check"></i>
                                            </div>
                                            <small class="d-block text-center mt-1">Purple</small>
                                        </div>
                                        <div class="col-3 col-md-2">
                                            <div class="color-option" data-color="#FFC0CB" style="background-color: #FFC0CB;" title="Pink">
                                                <input type="checkbox" name="color_preferences[]" value="#FFC0CB" class="color-checkbox">
                                                <i class="fas fa-check color-check"></i>
                                            </div>
                                            <small class="d-block text-center mt-1">Pink</small>
                                        </div>
                                        <div class="col-3 col-md-2">
                                            <div class="color-option" data-color="#000000" style="background-color: #000000;" title="Black">
                                                <input type="checkbox" name="color_preferences[]" value="#000000" class="color-checkbox">
                                                <i class="fas fa-check color-check"></i>
                                            </div>
                                            <small class="d-block text-center mt-1">Black</small>
                                        </div>
                                        <div class="col-3 col-md-2">
                                            <div class="color-option" data-color="#6B7280" style="background-color: #6B7280;" title="Gray">
                                                <input type="checkbox" name="color_preferences[]" value="#6B7280" class="color-checkbox">
                                                <i class="fas fa-check color-check"></i>
                                            </div>
                                            <small class="d-block text-center mt-1">Gray</small>
                                        </div>
                                        <div class="col-3 col-md-2">
                                            <div class="color-option" data-color="#FFFFFF" style="background-color: #FFFFFF; border: 1px solid #E5E7EB;" title="White">
                                                <input type="checkbox" name="color_preferences[]" value="#FFFFFF" class="color-checkbox">
                                                <i class="fas fa-check color-check" style="color: #333;"></i>
                                            </div>
                                            <small class="d-block text-center mt-1">White</small>
                                        </div>
                                        <div class="col-3 col-md-2">
                                            <div class="color-option" data-color="#D4A574" style="background-color: #D4A574;" title="Tan">
                                                <input type="checkbox" name="color_preferences[]" value="#D4A574" class="color-checkbox">
                                                <i class="fas fa-check color-check"></i>
                                            </div>
                                            <small class="d-block text-center mt-1">Tan</small>
                                        </div>
                                        <div class="col-3 col-md-2">
                                            <div class="color-option" data-color="#8B4513" style="background-color: #8B4513;" title="Brown">
                                                <input type="checkbox" name="color_preferences[]" value="#8B4513" class="color-checkbox">
                                                <i class="fas fa-check color-check"></i>
                                            </div>
                                            <small class="d-block text-center mt-1">Brown</small>
                                        </div>
                                        <div class="col-3 col-md-2">
                                            <div class="color-option" data-color="#FFD700" style="background-color: #FFD700;" title="Gold">
                                                <input type="checkbox" name="color_preferences[]" value="#FFD700" class="color-checkbox">
                                                <i class="fas fa-check color-check"></i>
                                            </div>
                                            <small class="d-block text-center mt-1">Gold</small>
                                        </div>
                                    </div>
                                    
                                    <!--- Custom Color Picker --->
                                    <div class="mt-3">
                                        <label class="form-label"><small>Or add custom colors:</small></label>
                                        <div class="input-group" style="max-width: 300px;">
                                            <input type="color" class="form-control form-control-color" id="customColorPicker" value="#563d7c">
                                            <button type="button" class="btn btn-outline-primary" id="addCustomColor">
                                                <i class="fas fa-plus"></i> Add Color
                                            </button>
                                        </div>
                                        <div id="customColorsContainer" class="row g-2 mt-2"></div>
                                    </div>
                                    
                                    <!--- Hidden input to track if at least one color is selected --->
                                    <input type="hidden" name="color_validation" id="colorValidation" value="" required>
                                </div>
                            </div>

                            <div class="mb-3">
                                <label class="form-label">Reference Websites <span class="text-danger">*</span> <small class="text-muted">(Minimum 3 URLs required)</small></label>
                                <div id="referenceWebsitesContainer">
                                    <div class="reference-url-group mb-3 p-3 border rounded">
                                        <div class="row">
                                            <div class="col-md-6 mb-2">
                                                <input type="url" class="form-control reference-url" name="reference_websites[]" 
                                                    placeholder="https://example.com" data-required="true">
                                            </div>
                                            <div class="col-md-6 mb-2">
                                                <input type="text" class="form-control" name="reference_descriptions[]" 
                                                    placeholder="What do you like about this website?" data-required="true">
                                            </div>
                                        </div>
                                        <button type="button" class="btn btn-sm btn-outline-danger remove-url-btn" style="display: none;">
                                            <i class="fas fa-times"></i> Remove
                                        </button>
                                    </div>
                                    <div class="reference-url-group mb-3 p-3 border rounded">
                                        <div class="row">
                                            <div class="col-md-6 mb-2">
                                                <input type="url" class="form-control reference-url" name="reference_websites[]" 
                                                    placeholder="https://example.com" data-required="true">
                                            </div>
                                            <div class="col-md-6 mb-2">
                                                <input type="text" class="form-control" name="reference_descriptions[]" 
                                                    placeholder="What do you like about this website?" data-required="true">
                                            </div>
                                        </div>
                                        <button type="button" class="btn btn-sm btn-outline-danger remove-url-btn" style="display: none;">
                                            <i class="fas fa-times"></i> Remove
                                        </button>
                                    </div>
                                    <div class="reference-url-group mb-3 p-3 border rounded">
                                        <div class="row">
                                            <div class="col-md-6 mb-2">
                                                <input type="url" class="form-control reference-url" name="reference_websites[]" 
                                                    placeholder="https://example.com" data-required="true">
                                            </div>
                                            <div class="col-md-6 mb-2">
                                                <input type="text" class="form-control" name="reference_descriptions[]" 
                                                    placeholder="What do you like about this website?" data-required="true">
                                            </div>
                                        </div>
                                        <button type="button" class="btn btn-sm btn-outline-danger remove-url-btn" style="display: none;">
                                            <i class="fas fa-times"></i> Remove
                                        </button>
                                    </div>
                                </div>
                                <button type="button" class="btn btn-sm btn-outline-primary" id="addReferenceUrl">
                                    <i class="fas fa-plus"></i> Add Another Reference Website
                                </button>
                            </div>

                            <div class="mb-3">
                                <label class="form-label">Key Features Needed</label>
                                <div class="row">
                                    <div class="col-md-6">
                                        <div class="form-check mb-2">
                                            <input class="form-check-input" type="checkbox" name="features" value="contact_forms" id="feat1">
                                            <label class="form-check-label" for="feat1">Contact Forms</label>
                                        </div>
                                        <div class="form-check mb-2">
                                            <input class="form-check-input" type="checkbox" name="features" value="blog" id="feat2">
                                            <label class="form-check-label" for="feat2">Blog/News Section</label>
                                        </div>
                                        <div class="form-check mb-2">
                                            <input class="form-check-input" type="checkbox" name="features" value="gallery" id="feat3">
                                            <label class="form-check-label" for="feat3">Photo/Video Gallery</label>
                                        </div>
                                        <div class="form-check mb-2">
                                            <input class="form-check-input" type="checkbox" name="features" value="social_media" id="feat4">
                                            <label class="form-check-label" for="feat4">Social Media Integration</label>
                                        </div>
                                    </div>
                                    <div class="col-md-6">
                                        <div class="form-check mb-2">
                                            <input class="form-check-input" type="checkbox" name="features" value="user_accounts" id="feat5">
                                            <label class="form-check-label" for="feat5">User Accounts/Login</label>
                                        </div>
                                        <div class="form-check mb-2">
                                            <input class="form-check-input" type="checkbox" name="features" value="payment" id="feat6">
                                            <label class="form-check-label" for="feat6">Payment Processing</label>
                                        </div>
                                        <div class="form-check mb-2">
                                            <input class="form-check-input" type="checkbox" name="features" value="booking" id="feat7">
                                            <label class="form-check-label" for="feat7">Booking/Scheduling</label>
                                        </div>
                                        <div class="form-check mb-2">
                                            <input class="form-check-input" type="checkbox" name="features" value="multi_language" id="feat8">
                                            <label class="form-check-label" for="feat8">Multi-language Support</label>
                                        </div>
                                    </div>
                                </div>
                                <div class="mt-3">
                                    <div class="form-check mb-2">
                                        <input class="form-check-input" type="checkbox" name="features" value="other" id="featOther" onchange="toggleOtherFeatures(this)">
                                        <label class="form-check-label" for="featOther">Other (please specify)</label>
                                    </div>
                                    <textarea class="form-control mt-2" name="other_features" id="otherFeatures" rows="2" 
                                        placeholder="Please describe any other features you need..." style="display: none;"></textarea>
                                </div>
                            </div>
                        </div>

                        <!--- Step 6: Additional Information --->
                        <div class="form-step" id="step6" style="display: none;">
                            <h4 class="mb-4">Additional Information</h4>
                            
                            <div class="mb-3">
                                <label class="form-label">Do you have existing branding materials? <span class="text-danger">*</span></label>
                                <select class="form-select" name="has_branding" required>
                                    <option value="">Select...</option>
                                    <option value="yes_complete">Yes, complete brand guide</option>
                                    <option value="yes_logo">Yes, logo only</option>
                                    <option value="yes_some">Yes, some materials</option>
                                    <option value="no">No, need branding help</option>
                                </select>
                            </div>

                            <div class="mb-3">
                                <label class="form-label">Do you need content writing services? <span class="text-danger">*</span></label>
                                <select class="form-select" name="need_content_writing" required>
                                    <option value="">Select...</option>
                                    <option value="yes_all">Yes, for all content</option>
                                    <option value="yes_some">Yes, for some pages</option>
                                    <option value="no_have">No, I have content ready</option>
                                    <option value="no_will_provide">No, I will provide later</option>
                                </select>
                            </div>

                            <div class="mb-3">
                                <label class="form-label">Do you need ongoing maintenance? <span class="text-danger">*</span></label>
                                <select class="form-select" name="need_maintenance" required>
                                    <option value="">Select...</option>
                                    <option value="yes_monthly">Yes, monthly maintenance</option>
                                    <option value="yes_quarterly">Yes, quarterly check-ups</option>
                                    <option value="yes_as_needed">Yes, as needed</option>
                                    <option value="no">No, just the initial build</option>
                                </select>
                            </div>

                            <div class="mb-3">
                                <label class="form-label">Additional Comments or Special Requirements <span class="text-danger">*</span></label>
                                <textarea class="form-control" name="additional_comments" rows="4" 
                                    placeholder="Please share any other information that might help us understand your needs better" required></textarea>
                            </div>

                            <div class="mb-3">
                                <label class="form-label">How did you hear about us? <span class="text-danger">*</span></label>
                                <select class="form-select" name="referral_source" required>
                                    <option value="" selected disabled>Please select...</option>
                                    <option value="google">Google Search</option>
                                    <option value="social_media">Social Media</option>
                                    <option value="referral">Friend/Colleague Referral</option>
                                    <option value="previous_client">Previous Client</option>
                                    <option value="other">Other</option>
                                </select>
                            </div>
                        </div>

                        <!--- Navigation Buttons --->
                        <div class="mt-4 d-flex justify-content-between">
                            <button type="button" class="btn btn-secondary" id="prevBtn" style="display: none;">
                                <i class="fas fa-arrow-left"></i> Previous
                            </button>
                            <button type="button" class="btn btn-primary ms-auto" id="nextBtn">
                                Next <i class="fas fa-arrow-right"></i>
                            </button>
                            <button type="submit" name="action" value="submit" class="btn btn-success ms-auto" id="submitBtn" style="display: none;">
                                <i class="fas fa-check"></i> Submit Form
                            </button>
                        </div>
                        
                        <!--- Save as Draft --->
                        <div class="mt-3 text-center">
                            <button type="button" id="saveDraftBtn" class="btn btn-outline-secondary btn-sm" onclick="saveDraft()">
                                <i class="fas fa-save"></i> Save as Draft
                            </button>
                            <span id="draftStatus" class="ms-2 text-muted small"></span>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>

<!--- Validation Error Modal --->
<div class="modal fade" id="validationModal" tabindex="-1" aria-labelledby="validationModalLabel" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header bg-warning text-dark">
                <h5 class="modal-title" id="validationModalLabel">
                    <i class="fas fa-exclamation-triangle"></i> Required Fields Missing
                </h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <p class="mb-3">Please complete the following required fields before proceeding:</p>
                <ul id="errorList" class="list-unstyled"></ul>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-primary" data-bs-dismiss="modal">OK, I'll fix it</button>
            </div>
        </div>
    </div>
</div>

<style>
.color-palette-container {
    padding: 15px;
    background: #f8f9fa;
    border-radius: 8px;
}

.color-option {
    width: 50px;
    height: 50px;
    border-radius: 8px;
    cursor: pointer;
    position: relative;
    transition: all 0.2s ease;
    box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

.color-option:hover {
    transform: scale(1.1);
    box-shadow: 0 4px 8px rgba(0,0,0,0.2);
}

.color-checkbox {
    position: absolute;
    opacity: 0;
    width: 100%;
    height: 100%;
    cursor: pointer;
}

.color-check {
    position: absolute;
    top: 50%;
    left: 50%;
    transform: translate(-50%, -50%);
    color: white;
    font-size: 20px;
    display: none;
    filter: drop-shadow(0 1px 2px rgba(0,0,0,0.5));
}

.color-checkbox:checked ~ .color-check {
    display: block;
}

.custom-color-item {
    position: relative;
}

.remove-custom-color {
    position: absolute;
    top: -5px;
    right: -5px;
    width: 20px;
    height: 20px;
    border-radius: 50%;
    background: #dc3545;
    color: white;
    border: none;
    font-size: 12px;
    cursor: pointer;
    display: flex;
    align-items: center;
    justify-content: center;
    padding: 0;
}
.service-option {
    cursor: pointer;
    transition: all 0.3s;
}
.service-option:hover {
    background-color: #f8f9fa;
    border-color: #0d6efd !important;
}
.service-option input:checked + label {
    color: #0d6efd;
    font-weight: 500;
}
.form-step {
    min-height: 400px;
}
.project-type-card {
    cursor: pointer;
    transition: all 0.3s;
    border: 2px solid #dee2e6;
}
.project-type-card:hover {
    border-color: #0d6efd;
    transform: translateY(-5px);
    box-shadow: 0 5px 15px rgba(0,0,0,0.1);
}
.project-type-card.selected {
    border-color: #0d6efd;
    background-color: #f0f6ff;
}
.field-error {
    border-color: #dc3545 !important;
    animation: shake 0.5s;
}
@keyframes shake {
    0%, 100% { transform: translateX(0); }
    10%, 30%, 50%, 70%, 90% { transform: translateX(-5px); }
    20%, 40%, 60%, 80% { transform: translateX(5px); }
}
.error-item {
    padding: 8px 12px;
    margin-bottom: 8px;
    background-color: #fff3cd;
    border-radius: 5px;
    border-left: 4px solid #ffc107;
}
</style>

<script>
// Form wizard functionality
let currentStep = <cfoutput>#startStep#</cfoutput>;

// Function to manage required attributes based on step visibility
function updateRequiredFields() {
    // We don't need to manage required attributes anymore
    // We're using data-required and custom validation
    // This function is kept for compatibility but does nothing
}

// Mark all required fields with data attribute
document.addEventListener('DOMContentLoaded', function() {
    document.querySelectorAll('[required]').forEach(field => {
        field.setAttribute('data-required', 'true');
    });
    updateRequiredFields();
});
const totalSteps = 6;
let selectedProjectType = '<cfoutput>#preSelectedType#</cfoutput>' || null;
let preSelectedCategory = '<cfoutput>#preSelectedCategory#</cfoutput>' || null;
let preSelectedService = '<cfoutput>#preSelectedService#</cfoutput>' || null;
const fromAI = <cfoutput>#fromAI#</cfoutput>;

// Pre-select data if coming from AI or draft
<cfif fromAI OR fromDraft>
    document.addEventListener('DOMContentLoaded', function() {
        <cfif len(preSelectedType)>
            // Select the project type
            selectedProjectType = '<cfoutput>#preSelectedType#</cfoutput>';
            const projectRadio = document.getElementById('project_<cfoutput>#preSelectedType#</cfoutput>');
            if (projectRadio) {
                projectRadio.checked = true;
                const card = projectRadio.closest('.project-type-card');
                if (card) card.classList.add('selected');
            }
        </cfif>
        
        // Hide previous steps based on startStep
        for (let i = 1; i < <cfoutput>#startStep#</cfoutput>; i++) {
            document.getElementById('step' + i).style.display = 'none';
        }
        document.getElementById('step<cfoutput>#startStep#</cfoutput>').style.display = 'block';
        
        <cfif startStep EQ 2>
            // Load services for the selected type
            loadServicesForProjectType();
            
            // Pre-select service if provided
            <cfif len(preSelectedService)>
                setTimeout(() => {
                    const serviceRadio = document.querySelector('input[name="service_type"][value="<cfoutput>#preSelectedService#</cfoutput>"]');
                    if (serviceRadio) {
                        serviceRadio.checked = true;
                        const serviceCard = serviceRadio.closest('.service-option');
                        if (serviceCard) serviceCard.style.borderColor = '#0d6efd';
                    }
                }, 500);
            </cfif>
        <cfelseif startStep GTE 3>
            // If we're at step 3 or beyond, ensure service type is set
            <cfif len(preSelectedService)>
                const existingServiceInput = document.querySelector('input[name="service_type"][type="hidden"]');
                if (!existingServiceInput) {
                    const serviceTypeInput = document.createElement('input');
                    serviceTypeInput.type = 'hidden';
                    serviceTypeInput.name = 'service_type';
                    serviceTypeInput.value = '<cfoutput>#preSelectedService#</cfoutput>';
                    document.getElementById('intakeForm').appendChild(serviceTypeInput);
                }
            </cfif>
        </cfif>
        
        // Update progress bar
        updateProgressBar();
        updateButtons();
        
        // Add project description if provided
        <cfif len(form.project_description)>
            const descField = document.querySelector('textarea[name="project_description"]');
            if (descField) {
                descField.value = '<cfoutput>#jsStringFormat(form.project_description)#</cfoutput>';
            }
        </cfif>
        
        // Show draft saved message for AI
        <cfif fromAI AND startStep EQ 3>
            const alertDiv = document.createElement('div');
            alertDiv.className = 'alert alert-success alert-dismissible fade show mt-3';
            alertDiv.innerHTML = `
                <i class="fas fa-check-circle"></i> Your form has been auto-saved as a draft based on your chat conversation.
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            `;
            document.querySelector('.card-body').insertBefore(alertDiv, document.querySelector('.card-body').firstChild);
        </cfif>
        
        // Show editing draft message
        <cfif fromDraft>
            const alertDiv = document.createElement('div');
            alertDiv.className = 'alert alert-info alert-dismissible fade show mt-3';
            alertDiv.innerHTML = `
                <i class="fas fa-info-circle"></i> You are editing draft form #<cfoutput>#draftId#</cfoutput>
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            `;
            document.querySelector('.card-body').insertBefore(alertDiv, document.querySelector('.card-body').firstChild);
        </cfif>
    });
</cfif>

document.getElementById('nextBtn').addEventListener('click', function() {
    if (validateStep(currentStep)) {
        if (currentStep < totalSteps) {
            document.getElementById('step' + currentStep).style.display = 'none';
            currentStep++;
            document.getElementById('step' + currentStep).style.display = 'block';
            updateProgressBar();
            updateButtons();
            updateRequiredFields();
            
            // Load services when reaching step 2
            if (currentStep === 2) {
                loadServicesForProjectType();
            }
            // Load service-specific questions when reaching step 4
            if (currentStep === 4) {
                loadServiceSpecificQuestions();
            }
        }
    }
});

document.getElementById('prevBtn').addEventListener('click', function() {
    // Don't allow going back from step 3 only
    if (currentStep === 3) {
        return;
    }
    
    if (currentStep > 1) {
        document.getElementById('step' + currentStep).style.display = 'none';
        currentStep--;
        document.getElementById('step' + currentStep).style.display = 'block';
        updateProgressBar();
        updateButtons();
        updateRequiredFields();
        
        // Special handling when going back to step 2
        if (currentStep === 2) {
            loadServicesForProjectType();
        }
    }
});

function updateProgressBar() {
    const progress = (currentStep / totalSteps) * 100;
    document.getElementById('progressBar').style.width = progress + '%';
    document.getElementById('progressBar').textContent = 'Step ' + currentStep + ' of ' + totalSteps;
}

function updateButtons() {
    // Hide previous button on step 1 or step 3 only
    document.getElementById('prevBtn').style.display = (currentStep === 1 || currentStep === 3) ? 'none' : 'inline-block';
    document.getElementById('nextBtn').style.display = currentStep === totalSteps ? 'none' : 'inline-block';
    document.getElementById('submitBtn').style.display = currentStep === totalSteps ? 'inline-block' : 'none';
}

function toggleOtherFeatures(checkbox) {
    const otherTextarea = document.getElementById('otherFeatures');
    if (checkbox.checked) {
        otherTextarea.style.display = 'block';
        otherTextarea.focus();
    } else {
        otherTextarea.style.display = 'none';
        otherTextarea.value = '';
    }
}

function validateStep(step) {
    const currentStepElement = document.getElementById('step' + step);
    // Only get visible required fields with data-required attribute
    const requiredFields = currentStepElement.querySelectorAll('[data-required="true"]:not([style*="display: none"])');
    let isValid = true;
    let errors = [];
    
    // Clear previous error styles
    currentStepElement.querySelectorAll('.field-error').forEach(field => {
        field.classList.remove('field-error');
    });
    
    requiredFields.forEach(field => {
        // Special validation for website field - removed URL prefix requirement
        if (field.name === 'current_website' && field.value) {
            const value = field.value.toLowerCase().trim();
            // Just check it's not empty and not just 'no' - allow any website format
            if (value.length === 0) {
                isValid = false;
                field.classList.add('field-error');
                errors.push('Please enter your website URL or "no" if you don\'t have one');
                return;
            }
        }
        
        if (!field.value && field.type !== 'radio' && field.type !== 'checkbox') {
            isValid = false;
            field.classList.add('field-error');
            
            // Get field label
            const label = field.previousElementSibling || 
                         currentStepElement.querySelector(`label[for="${field.id}"]`) ||
                         { textContent: field.name };
            errors.push(label.textContent.replace('*', '').trim());
            
        } else if (field.type === 'radio') {
            const radioGroup = currentStepElement.querySelectorAll('input[name="' + field.name + '"]');
            const isChecked = Array.from(radioGroup).some(radio => radio.checked);
            if (!isChecked) {
                isValid = false;
                // For radio groups, find the section title
                const container = field.closest('.form-step');
                const title = container.querySelector('h4')?.textContent || field.name;
                if (!errors.includes(title)) {
                    errors.push(title);
                }
            }
        } else {
            field.classList.remove('field-error');
        }
    });
    
    // Check for design preferences step validations
    if (step === 5) { // Design Preferences step (Step 5: Design & Functionality)
        // Check color preferences
        const selectedColors = currentStepElement.querySelectorAll('.color-checkbox:checked');
        if (selectedColors.length === 0) {
            isValid = false;
            errors.push('Please select at least one color preference');
        }
        
        // Check reference websites minimum requirement
        const referenceUrls = currentStepElement.querySelectorAll('input[name="reference_websites[]"]');
        const filledUrls = Array.from(referenceUrls).filter(input => input.value.trim() !== '');
        
        if (filledUrls.length < 3) {
            isValid = false;
            referenceUrls.forEach(input => {
                if (!input.value.trim()) {
                    input.classList.add('field-error');
                }
            });
            errors.push('Please provide at least 3 reference website URLs');
        }
    }
    
    // Check for features in step 5
    if (step === 5) { // Design & Functionality step where features are located
        const checkboxes = currentStepElement.querySelectorAll('input[type="checkbox"][name="features"]');
        const hasChecked = Array.from(checkboxes).some(cb => cb.checked);
        const otherCheckbox = document.getElementById('featOther');
        const otherFeatures = document.getElementById('otherFeatures');
        const hasOtherText = otherFeatures && otherFeatures.value.trim().length > 0;
        
        if (!hasChecked && !hasOtherText) {
            isValid = false;
            errors.push('Please select at least one feature or describe other features needed');
        }
        
        // If "Other" is checked, require the text field
        if (otherCheckbox && otherCheckbox.checked && !hasOtherText) {
            isValid = false;
            errors.push('Please describe the other features you need');
            otherFeatures.classList.add('field-error');
        }
    }
    
    if (!isValid) {
        showValidationModal(errors);
    }
    
    return isValid;
}

function showValidationModal(errors) {
    const errorList = document.getElementById('errorList');
    errorList.innerHTML = '';
    
    errors.forEach(error => {
        const li = document.createElement('li');
        li.className = 'error-item';
        li.innerHTML = `<i class="fas fa-exclamation-circle text-warning me-2"></i>${error}`;
        errorList.appendChild(li);
    });
    
    const modalElement = document.getElementById('validationModal');
    
    // Remove any existing modal instance to prevent conflicts
    const existingModal = bootstrap.Modal.getInstance(modalElement);
    if (existingModal) {
        existingModal.dispose();
    }
    
    const modal = new bootstrap.Modal(modalElement, {
        backdrop: 'static',
        keyboard: false
    });
    
    // Remove existing event listeners to prevent duplicates
    const newModalElement = modalElement.cloneNode(true);
    modalElement.parentNode.replaceChild(newModalElement, modalElement);
    
    // Add fresh event listeners
    newModalElement.addEventListener('shown.bs.modal', function () {
        // Bootstrap manages aria-hidden, we just need to focus
        const okButton = newModalElement.querySelector('.btn-primary');
        if (okButton) {
            // Use requestAnimationFrame for better timing
            requestAnimationFrame(() => {
                okButton.focus();
            });
        }
    });
    
    // Show the modal with the new element
    const newModal = new bootstrap.Modal(newModalElement);
    newModal.show();
}

function loadServiceSpecificQuestions() {
    const selectedService = document.querySelector('input[name="service_type"]:checked');
    if (selectedService) {
        const category = selectedService.dataset.category;
        const service = selectedService.dataset.service;
        const container = document.getElementById('serviceSpecificQuestions');
        
        // Clear existing questions
        container.innerHTML = '';
        
        // Add service-specific questions based on category
        let specificQuestions = '';
        
        if (category === 'ecommerce') {
            specificQuestions = `
                <h5 class="mt-4 mb-3">E-commerce Specific Details</h5>
                <div class="row">
                    <div class="col-md-6 mb-3">
                        <label class="form-label">Number of Products</label>
                        <select class="form-select" name="num_products">
                            <option value="">Select...</option>
                            <option value="under_50">Under 50</option>
                            <option value="50_200">50-200</option>
                            <option value="200_500">200-500</option>
                            <option value="500_1000">500-1000</option>
                            <option value="over_1000">Over 1000</option>
                        </select>
                    </div>
                    <div class="col-md-6 mb-3">
                        <label class="form-label">Product Categories</label>
                        <input type="text" class="form-control" name="product_categories" 
                            placeholder="e.g., Clothing, Electronics, Books">
                    </div>
                </div>
                <div class="mb-3">
                    <label class="form-label">Payment Methods Needed</label>
                    <div class="form-check">
                        <input class="form-check-input" type="checkbox" name="payment_methods" value="credit_card" id="pm1">
                        <label class="form-check-label" for="pm1">Credit/Debit Cards</label>
                    </div>
                    <div class="form-check">
                        <input class="form-check-input" type="checkbox" name="payment_methods" value="paypal" id="pm2">
                        <label class="form-check-label" for="pm2">PayPal</label>
                    </div>
                    <div class="form-check">
                        <input class="form-check-input" type="checkbox" name="payment_methods" value="stripe" id="pm3">
                        <label class="form-check-label" for="pm3">Stripe</label>
                    </div>
                </div>
            `;
        } else if (category === 'booking_service') {
            specificQuestions = `
                <h5 class="mt-4 mb-3">Booking System Details</h5>
                <div class="row">
                    <div class="col-md-6 mb-3">
                        <label class="form-label">Type of Appointments</label>
                        <input type="text" class="form-control" name="appointment_types" 
                            placeholder="e.g., Consultation, Treatment, Service">
                    </div>
                    <div class="col-md-6 mb-3">
                        <label class="form-label">Average Appointment Duration</label>
                        <select class="form-select" name="appointment_duration">
                            <option value="">Select...</option>
                            <option value="15_min">15 minutes</option>
                            <option value="30_min">30 minutes</option>
                            <option value="1_hour">1 hour</option>
                            <option value="2_hours">2 hours</option>
                            <option value="variable">Variable</option>
                        </select>
                    </div>
                </div>
            `;
        } else if (category === 'educational') {
            specificQuestions = `
                <h5 class="mt-4 mb-3">Educational Platform Details</h5>
                <div class="row">
                    <div class="col-md-6 mb-3">
                        <label class="form-label">Number of Courses/Programs</label>
                        <input type="text" class="form-control" name="num_courses" 
                            placeholder="Approximate number">
                    </div>
                    <div class="col-md-6 mb-3">
                        <label class="form-label">Student Capacity</label>
                        <select class="form-select" name="student_capacity">
                            <option value="">Select...</option>
                            <option value="under_100">Under 100</option>
                            <option value="100_500">100-500</option>
                            <option value="500_1000">500-1000</option>
                            <option value="over_1000">Over 1000</option>
                        </select>
                    </div>
                </div>
            `;
        }
        
        container.innerHTML = specificQuestions;
    }
}

// Remove invalid class on input
document.addEventListener('input', function(e) {
    if (e.target.classList.contains('is-invalid')) {
        e.target.classList.remove('is-invalid');
    }
});

// Project type selection
function selectProjectType(type) {
    selectedProjectType = type;
    
    // Update UI
    document.querySelectorAll('.project-type-card').forEach(card => {
        card.classList.remove('selected');
    });
    event.currentTarget.classList.add('selected');
    
    // Check the radio button
    document.getElementById('project_' + type).checked = true;
}

// Load services based on project type
function loadServicesForProjectType() {
    const container = document.getElementById('serviceAccordion');
    container.innerHTML = '';
    
    let categories = {};
    if (selectedProjectType === 'website') {
        <cfif structKeyExists(application, "serviceCategories")>
            categories = <cfoutput>#serializeJSON(application.serviceCategories)#</cfoutput>;
        <cfelse>
            categories = {};
        </cfif>
    } else if (selectedProjectType === 'mobile') {
        <cfif structKeyExists(application, "mobileCategories")>
            categories = <cfoutput>#serializeJSON(application.mobileCategories)#</cfoutput>;
        <cfelse>
            categories = {};
        </cfif>
    } else if (selectedProjectType === 'saas') {
        <cfif structKeyExists(application, "saasCategories")>
            categories = <cfoutput>#serializeJSON(application.saasCategories)#</cfoutput>;
        <cfelse>
            categories = {};
        </cfif>
    }
    
    let catIndex = 0;
    for (const [catKey, category] of Object.entries(categories)) {
        catIndex++;
        const accordionItem = `
            <div class="accordion-item mb-2">
                <h2 class="accordion-header">
                    <button class="accordion-button ${catIndex > 1 ? 'collapsed' : ''}" type="button" 
                            data-bs-toggle="collapse" data-bs-target="#serviceCat${catIndex}">
                        <i class="fas ${category.icon} me-2"></i>
                        <strong>${category.name}</strong>
                    </button>
                </h2>
                <div id="serviceCat${catIndex}" class="accordion-collapse collapse ${catIndex === 1 ? 'show' : ''}" 
                     data-bs-parent="#serviceAccordion">
                    <div class="accordion-body">
                        <div class="row">
                            ${Object.entries(category.services).map(([serviceKey, serviceName]) => `
                                <div class="col-md-6 mb-2">
                                    <div class="form-check service-option p-3 border rounded">
                                        <input class="form-check-input" type="radio" name="service_type" 
                                               id="service_${catKey}_${serviceKey}" 
                                               value="${catKey}_${serviceKey}" 
                                               data-category="${catKey}"
                                               data-service="${serviceKey}" required>
                                        <label class="form-check-label w-100" for="service_${catKey}_${serviceKey}">
                                            ${serviceName}
                                        </label>
                                    </div>
                                </div>
                            `).join('')}
                        </div>
                    </div>
                </div>
            </div>
        `;
        container.innerHTML += accordionItem;
    }
}

let currentFormId = <cfoutput>#draftId#</cfoutput>;

// Save draft function
function saveDraft() {
    const form = document.getElementById('intakeForm');
    const data = {};
    
    // Collect all form data including from hidden steps
    const allInputs = form.querySelectorAll('input, select, textarea');
    
    allInputs.forEach(field => {
        const name = field.name;
        if (!name) return;
        
        if (field.type === 'radio') {
            if (field.checked) {
                data[name] = field.value;
            }
        } else if (field.type === 'checkbox') {
            if (field.checked) {
                // Handle array field names (e.g., color_preferences[])
                const fieldName = name.endsWith('[]') ? name.slice(0, -2) : name;
                
                // Handle multiple checkboxes with same name (like features)
                if (fieldName === 'features' || fieldName === 'payment_methods') {
                    if (!data[fieldName]) data[fieldName] = [];
                    data[fieldName].push(field.value);
                } else {
                    if (!data[fieldName]) data[fieldName] = [];
                    if (!Array.isArray(data[fieldName])) data[fieldName] = [data[fieldName]];
                    data[fieldName].push(field.value);
                }
            }
        } else {
            // For regular inputs, selects, and textareas
            if (field.value) {
                if (name.endsWith('[]')) {
                    // Handle array fields
                    const cleanName = name.slice(0, -2);
                    if (!data[cleanName]) data[cleanName] = [];
                    data[cleanName].push(field.value);
                } else {
                    data[name] = field.value;
                }
            }
        }
    });
    
    // Combine reference websites and descriptions into objects
    if (data.reference_websites && data.reference_descriptions) {
        const websites = [];
        for (let i = 0; i < data.reference_websites.length; i++) {
            if (data.reference_websites[i]) {
                websites.push({
                    url: data.reference_websites[i],
                    description: data.reference_descriptions[i] || ''
                });
            }
        }
        data.reference_websites = websites;
        delete data.reference_descriptions;
    }
    
    // Add current step info
    data.current_step = currentStep;
    
    // Debug: Log the data being saved
    console.log('Saving draft data:', data);
    
    // Show saving status
    const statusSpan = document.getElementById('draftStatus');
    statusSpan.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Saving...';
    
    fetch('<cfoutput>#application.basePath#</cfoutput>/api/save-draft.cfm', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({
            formId: currentFormId,
            formData: data
        })
    })
    .then(response => response.json())
    .then(result => {
        if (result.success) {
            currentFormId = result.formId;
            
            // Update the hidden form_id field if it exists, or create it
            let formIdField = document.querySelector('input[name="form_id"]');
            if (!formIdField) {
                formIdField = document.createElement('input');
                formIdField.type = 'hidden';
                formIdField.name = 'form_id';
                document.getElementById('intakeForm').appendChild(formIdField);
            }
            formIdField.value = result.formId;
            
            statusSpan.innerHTML = '<i class="fas fa-check text-success"></i> Draft saved';
            setTimeout(() => {
                statusSpan.innerHTML = '';
            }, 3000);
        } else {
            console.error('Save failed:', result);
            statusSpan.innerHTML = '<i class="fas fa-exclamation-triangle text-danger"></i> Save failed: ' + (result.error || 'Unknown error');
        }
    })
    .catch(error => {
        console.error('Save error:', error);
        statusSpan.innerHTML = '<i class="fas fa-exclamation-triangle text-danger"></i> Save failed';
    });
}

// Auto-save when coming from AI
<cfif fromAI AND startStep EQ 3>
    document.addEventListener('DOMContentLoaded', function() {
        setTimeout(() => {
            saveDraft();
        }, 1000);
    });
</cfif>

// Load draft data when editing
<cfif fromDraft AND NOT structIsEmpty(draftData)>
    document.addEventListener('DOMContentLoaded', function() {
        // Populate form fields with draft data
        <cfloop collection="#draftData#" item="fieldName">
            <cfif fieldName NEQ "current_step">
                (function() {
                    <cfif isArray(draftData[fieldName])>
                        // Handle array fields like checkboxes
                        <cfloop array="#draftData[fieldName]#" index="value">
                            <cfif isSimpleValue(value)>
                            {
                                // Try both with and without []
                                let chk = document.querySelector('[name="<cfoutput>#fieldName#</cfoutput>"][value="<cfoutput>#jsStringFormat(value)#</cfoutput>"]');
                                if (!chk) {
                                    chk = document.querySelector('[name="<cfoutput>#fieldName#</cfoutput>[]"][value="<cfoutput>#jsStringFormat(value)#</cfoutput>"]');
                                }
                                
                                // If checkbox doesn't exist and it's a color preference, create it as a custom color
                                if (!chk && '<cfoutput>#fieldName#</cfoutput>' === 'color_preferences') {
                                    // Add custom color
                                    const customColorsContainer = document.getElementById('customColorsContainer');
                                    if (customColorsContainer) {
                                        const colorDiv = document.createElement('div');
                                        colorDiv.className = 'col-3 col-md-2 custom-color-item';
                                        colorDiv.innerHTML = '<div class="color-option" data-color="<cfoutput>#jsStringFormat(value)#</cfoutput>" style="background-color: <cfoutput>#jsStringFormat(value)#</cfoutput>;" title="Custom Color">' +
                                            '<input type="checkbox" name="color_preferences[]" value="<cfoutput>#jsStringFormat(value)#</cfoutput>" class="color-checkbox" checked>' +
                                            '<i class="fas fa-check color-check"></i>' +
                                            '<button type="button" class="remove-custom-color" onclick="this.closest(\'.custom-color-item\').remove(); window.updateColorValidation();">' +
                                            '<i class="fas fa-times"></i>' +
                                            '</button>' +
                                            '</div>' +
                                            '<small class="d-block text-center mt-1">Custom</small>';
                                        customColorsContainer.appendChild(colorDiv);
                                        
                                        // Update validation
                                        if (window.updateColorValidation) {
                                            window.updateColorValidation();
                                        }
                                    }
                                } else if (chk) {
                                    chk.checked = true;
                                }
                            }
                            </cfif>
                        </cfloop>
                    <cfelse>
                        const field = document.querySelector('[name="<cfoutput>#fieldName#</cfoutput>"]');
                        if (field) {
                            field.value = '<cfoutput>#jsStringFormat(draftData[fieldName])#</cfoutput>';
                        }
                    </cfif>
                })();
            </cfif>
        </cfloop>
        
        // Handle reference websites if they exist
        <cfif structKeyExists(draftData, "reference_websites") AND isArray(draftData.reference_websites)>
            const referenceContainer = document.getElementById('referenceWebsitesContainer');
            const existingGroups = referenceContainer.querySelectorAll('.reference-url-group');
            
            <cfloop from="1" to="#arrayLen(draftData.reference_websites)#" index="idx">
                <cfset website = draftData.reference_websites[idx]>
                <cfif isStruct(website)>
                    if (<cfoutput>#idx#</cfoutput> <= existingGroups.length) {
                        // Fill existing fields
                        const group = existingGroups[<cfoutput>#idx-1#</cfoutput>];
                        const urlInput = group.querySelector('input[name="reference_websites[]"]');
                        const descInput = group.querySelector('input[name="reference_descriptions[]"]');
                        if (urlInput) urlInput.value = '<cfoutput>#jsStringFormat(website.url)#</cfoutput>';
                        if (descInput) descInput.value = '<cfoutput>#jsStringFormat(website.description ?: "")#</cfoutput>';
                    } else {
                        // Add new fields for additional URLs
                        const newGroup = document.createElement('div');
                        newGroup.className = 'reference-url-group mb-3 p-3 border rounded';
                        newGroup.innerHTML = '<div class="row">' +
                            '<div class="col-md-6 mb-2">' +
                                '<input type="url" class="form-control reference-url" name="reference_websites[]" ' +
                                    'placeholder="https://example.com" data-required="true" value="<cfoutput>#jsStringFormat(website.url)#</cfoutput>">' +
                            '</div>' +
                            '<div class="col-md-6 mb-2">' +
                                '<input type="text" class="form-control" name="reference_descriptions[]" ' +
                                    'placeholder="What do you like about this website?" data-required="true" value="<cfoutput>#jsStringFormat(website.description ?: "")#</cfoutput>">' +
                            '</div>' +
                            '</div>' +
                            '<button type="button" class="btn btn-sm btn-outline-danger remove-url-btn">' +
                                '<i class="fas fa-times"></i> Remove' +
                            '</button>';
                        referenceContainer.appendChild(newGroup);
                    }
                </cfif>
            </cfloop>
        </cfif>
        
        // Pre-select service if available
        <cfif len(preSelectedService)>
            const serviceRadio = document.querySelector('input[name="service_type"][value="<cfoutput>#preSelectedService#</cfoutput>"]');
            if (serviceRadio) {
                serviceRadio.checked = true;
                const serviceCard = serviceRadio.closest('.service-option');
                if (serviceCard) serviceCard.style.borderColor = '#0d6efd';
            }
        </cfif>
        
        // Load other_features if exists and show textarea if "other" is checked
        <cfif structKeyExists(draftData, "other_features") AND len(draftData.other_features)>
            const otherFeaturesField = document.getElementById('otherFeatures');
            if (otherFeaturesField) {
                otherFeaturesField.value = '<cfoutput>#jsStringFormat(draftData.other_features)#</cfoutput>';
                
                // If other_features has content, check the "Other" checkbox and show textarea
                const otherCheckbox = document.getElementById('featOther');
                if (otherCheckbox && '<cfoutput>#jsStringFormat(draftData.other_features)#</cfoutput>'.trim()) {
                    otherCheckbox.checked = true;
                    otherFeaturesField.style.display = 'block';
                }
            }
        </cfif>
    });
</cfif>

// Add form submission validation
document.getElementById('intakeForm').addEventListener('submit', function(e) {
    // Only prevent default if validation fails
    const submitButton = e.submitter;
    
    // If it's the submit button (not save draft), validate current step
    if (submitButton && submitButton.name === 'action' && submitButton.value === 'submit') {
        // Only validate the current step
        if (!validateStep(currentStep)) {
            e.preventDefault();
            return false;
        }
        
        // Remove required attribute from all fields to prevent browser validation
        // We're handling validation manually
        document.querySelectorAll('[required]').forEach(field => {
            field.removeAttribute('required');
        });
    }
});

// Color Palette Management
document.addEventListener('DOMContentLoaded', function() {
    const colorValidation = document.getElementById('colorValidation');
    const customColorPicker = document.getElementById('customColorPicker');
    const addCustomColorBtn = document.getElementById('addCustomColor');
    const customColorsContainer = document.getElementById('customColorsContainer');
    
    // Function to update color validation
    window.updateColorValidation = function() {
        const selectedColors = document.querySelectorAll('.color-checkbox:checked');
        const colorValidation = document.getElementById('colorValidation');
        if (selectedColors.length > 0) {
            colorValidation.value = 'valid';
        } else {
            colorValidation.value = '';
        }
    }
    
    // Add click handlers to all color checkboxes
    document.querySelectorAll('.color-checkbox').forEach(checkbox => {
        checkbox.addEventListener('change', updateColorValidation);
    });
    
    // Custom color management
    let customColorCount = 0;
    
    addCustomColorBtn.addEventListener('click', function() {
        const color = customColorPicker.value;
        customColorCount++;
        
        const colorDiv = document.createElement('div');
        colorDiv.className = 'col-3 col-md-2 custom-color-item';
        colorDiv.innerHTML = `
            <div class="color-option" data-color="${color}" style="background-color: ${color};" title="Custom Color">
                <input type="checkbox" name="color_preferences[]" value="${color}" class="color-checkbox" checked>
                <i class="fas fa-check color-check"></i>
                <button type="button" class="remove-custom-color" onclick="this.closest('.custom-color-item').remove(); window.updateColorValidation();">
                    <i class="fas fa-times"></i>
                </button>
            </div>
            <small class="d-block text-center mt-1">Custom</small>
        `;
        
        customColorsContainer.appendChild(colorDiv);
        
        // Add event listener to new checkbox
        const newCheckbox = colorDiv.querySelector('.color-checkbox');
        newCheckbox.addEventListener('change', updateColorValidation);
        
        updateColorValidation();
        
        // Generate a new random color for next selection
        const randomColor = '#' + Math.floor(Math.random()*16777215).toString(16).padStart(6, '0');
        customColorPicker.value = randomColor;
    });
});

// Reference Websites Management
document.addEventListener('DOMContentLoaded', function() {
    const container = document.getElementById('referenceWebsitesContainer');
    const addButton = document.getElementById('addReferenceUrl');
    
    // Function to update remove button visibility
    function updateRemoveButtons() {
        const groups = container.querySelectorAll('.reference-url-group');
        groups.forEach((group, index) => {
            const removeBtn = group.querySelector('.remove-url-btn');
            // Show remove button only if there are more than 3 URLs
            if (groups.length > 3) {
                removeBtn.style.display = 'block';
            } else {
                removeBtn.style.display = 'none';
            }
        });
    }
    
    // Add new URL input
    addButton.addEventListener('click', function() {
        const newGroup = document.createElement('div');
        newGroup.className = 'reference-url-group mb-3 p-3 border rounded';
        newGroup.innerHTML = `
            <div class="row">
                <div class="col-md-6 mb-2">
                    <input type="url" class="form-control reference-url" name="reference_websites[]" 
                        placeholder="https://example.com" data-required="true">
                </div>
                <div class="col-md-6 mb-2">
                    <input type="text" class="form-control" name="reference_descriptions[]" 
                        placeholder="What do you like about this website?" data-required="true">
                </div>
            </div>
            <button type="button" class="btn btn-sm btn-outline-danger remove-url-btn">
                <i class="fas fa-times"></i> Remove
            </button>
        `;
        container.appendChild(newGroup);
        
        // Add remove event listener to new button
        const removeBtn = newGroup.querySelector('.remove-url-btn');
        removeBtn.addEventListener('click', function() {
            newGroup.remove();
            updateRemoveButtons();
        });
        
        updateRemoveButtons();
    });
    
    // Add remove event listeners to existing buttons
    container.querySelectorAll('.remove-url-btn').forEach(btn => {
        btn.addEventListener('click', function() {
            btn.closest('.reference-url-group').remove();
            updateRemoveButtons();
        });
    });
    
    // Initial button state
    updateRemoveButtons();
});
</script>

<cfinclude template="includes/footer.cfm">