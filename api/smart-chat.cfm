<cfsetting showdebugoutput="false">
<cfheader name="Access-Control-Allow-Origin" value="*">
<cfheader name="Access-Control-Allow-Methods" value="GET, POST, OPTIONS">
<cfheader name="Access-Control-Allow-Headers" value="Content-Type">
<cfcontent type="application/json">

<!--- Handle OPTIONS request first --->
<cfif cgi.request_method EQ "OPTIONS">
    <cfheader statuscode="204" statustext="No Content">
    <cfabort>
</cfif>

<cftry>
    <!--- Parse JSON input --->
    <cfset requestData = getHTTPRequestData()>
    <cfset jsonData = deserializeJSON(toString(requestData.content))>
    
    <cfset userMessage = jsonData.message>
    <cfset conversationHistory = jsonData.conversationHistory>
    <cfset currentProjectInfo = jsonData.projectInfo>
    
    <!--- Determine current stage --->
    <cfset currentStage = "project_type">
    <cfif structKeyExists(currentProjectInfo, "stage")>
        <cfset currentStage = currentProjectInfo.stage>
    </cfif>
    
    <!--- Initialize response variables --->
    <cfset aiResponse = "">
    <cfset useAI = false>
    <cfset updatedProjectInfo = duplicate(currentProjectInfo)>
    
    <!--- CRITICAL: After service type is selected, NEVER use AI again --->
    <cfif structKeyExists(currentProjectInfo, "service_type") AND len(currentProjectInfo.service_type)>
        <cfset useAI = false>
    </cfif>
    
    <!--- IMPORTANT: Only use AI for project_type and service_type stages --->
    <!--- Handle stages --->
    <cfswitch expression="#currentStage#">
        <!--- Stage 1: Project Type (USE AI) --->
        <cfcase value="project_type">
            <cfset useAI = true>
            <cfset systemPrompt = "You are helping determine what type of project the user wants. Based on their message, determine if they want:
1. A website (any mention of website, site, web page, online presence)
2. A mobile app (any mention of app, mobile application, iOS, Android)
3. Software/SaaS (any mention of software, system, platform, SaaS, dashboard)

Respond ONLY with: 'I understand you need a [type]. Let me help you with that.'
Where [type] is either 'website', 'mobile app', or 'software platform'.

Then add: 'What kind of [type] are you looking for?'

If unclear, ask: 'Would you like to build a website, mobile app, or software platform?'">
        </cfcase>
        
        <!--- Stage 2: Service Type (NO AI - Simple questions only) --->
        <cfcase value="service_type">
            <cfset useAI = false> <!--- NEVER use AI for service type --->
            <cfif NOT structKeyExists(currentProjectInfo, "service_type") OR len(currentProjectInfo.service_type) EQ 0>
                <cfif updatedProjectInfo.project_type EQ "website">
                    <cfset aiResponse = "What type of website do you need?
1. E-commerce (Online store)
2. Corporate/Business website
3. Portfolio website
4. Blog/News website
5. Landing page
6. Other">
                <cfelseif updatedProjectInfo.project_type EQ "mobile_app">
                    <cfset aiResponse = "Which platform do you need?
1. iOS only
2. Android only
3. Both iOS and Android">
                <cfelse>
                    <cfset aiResponse = "What type of software do you need?
1. CRM System
2. Dashboard/Analytics
3. Management System
4. Other">
                </cfif>
            <cfelse>
                <!--- Service type already selected, don't use AI --->
                <cfset useAI = false>
                <cfset aiResponse = "Great! Now I need to collect some information from you. What's your first name?">
                <cfset updatedProjectInfo.stage = "basic_info">
            </cfif>
        </cfcase>
        
        <!--- All other stages: NO AI, just simple responses --->
        <cfdefaultcase>
            <cfset useAI = false>
            
            <cfswitch expression="#currentStage#">
                <!--- Basic Info --->
                <cfcase value="basic_info">
                    <cfset collected = structKeyExists(updatedProjectInfo, "basicInfo") ? updatedProjectInfo.basicInfo : {}>
                    <cfif NOT structKeyExists(collected, "first_name") OR NOT len(trim(structKeyExists(collected, "first_name") ? collected.first_name : ""))>
                        <cfset aiResponse = "What's your first name?">
                    <cfelseif NOT structKeyExists(collected, "last_name") OR len(collected.last_name) EQ 0>
                        <cfset aiResponse = "What's your last name?">
                    <cfelseif NOT structKeyExists(collected, "email") OR len(collected.email) EQ 0>
                        <cfset aiResponse = "What's your email address?">
                    <cfelseif NOT structKeyExists(collected, "phone") OR len(collected.phone) EQ 0>
                        <cfset aiResponse = "What's your phone number?">
                    <cfelseif NOT structKeyExists(collected, "company") OR len(collected.company) EQ 0>
                        <cfset aiResponse = "What's your company name?">
                    <cfelseif NOT structKeyExists(collected, "contact_method") OR len(collected.contact_method) EQ 0>
                        <cfset aiResponse = "How would you prefer to be contacted?
1. Email
2. Phone
3. Text Message
4. WhatsApp">
                    <cfelseif NOT structKeyExists(collected, "website") OR len(collected.website) EQ 0>
                        <cfset aiResponse = "Do you have an existing website? (Enter URL or type 'no')">
                    <cfelse>
                        <!--- Move to next stage and ask first question immediately --->
                        <cfset updatedProjectInfo.stage = "project_details">
                        <cfset aiResponse = "Please describe your project briefly:">
                    </cfif>
                </cfcase>
                
                <!--- Project Details --->
                <cfcase value="project_details">
                    <cfset collected = structKeyExists(updatedProjectInfo, "projectDetails") ? updatedProjectInfo.projectDetails : {}>
                    <cfif NOT structKeyExists(collected, "description") OR len(collected.description) EQ 0>
                        <cfset aiResponse = "Please describe your project briefly:">
                    <cfelseif NOT structKeyExists(collected, "target_audience") OR len(collected.target_audience) EQ 0>
                        <cfset aiResponse = "Who is your target audience?">
                    <cfelseif NOT structKeyExists(collected, "geographic_target") OR NOT len(trim(structKeyExists(collected, "geographic_target") ? collected.geographic_target : ""))>
                        <cfset aiResponse = "Where will your project target?
1. Local (City/Region)
2. National
3. International
4. Specific Countries/Regions">
                    <cfelseif NOT structKeyExists(collected, "timeline") OR len(collected.timeline) EQ 0>
                        <cfset aiResponse = "What's your project timeline?
1. ASAP
2. Within 1 month
3. Within 2 months
4. Within 3 months
5. Within 6 months
6. Flexible">
                    <cfelseif NOT structKeyExists(collected, "budget") OR len(collected.budget) EQ 0>
                        <cfset aiResponse = "What's your budget range?
1. Under $1,000
2. $1,000 - $5,000
3. $5,000 - $10,000
4. $10,000 - $25,000
5. $25,000 - $50,000
6. $50,000+
7. Not sure yet">
                    <cfelse>
                        <!--- Move to next stage and ask first question immediately --->
                        <cfset updatedProjectInfo.stage = "design_features">
                        <cfset aiResponse = "What colors would you like? (Type multiple colors separated by commas, e.g., 'blue, white, gray')">
                    </cfif>
                </cfcase>
                
                <!--- Design Features --->
                <cfcase value="design_features">
                    <cfset collected = structKeyExists(updatedProjectInfo, "designFeatures") ? updatedProjectInfo.designFeatures : {}>
                    <cfif NOT structKeyExists(collected, "colors") OR arrayLen(collected.colors) EQ 0>
                        <cfset aiResponse = "What colors would you like? (Type multiple colors separated by commas, e.g., 'blue, white, gray')">
                    <cfelseif NOT structKeyExists(collected, "style") OR len(collected.style) EQ 0>
                        <cfset aiResponse = "What design style do you prefer?
1. Modern & Minimal
2. Corporate & Professional
3. Creative & Bold
4. Friendly & Approachable
5. Elegant & Sophisticated
6. Tech & Futuristic
7. No Preference">
                    <cfelseif NOT structKeyExists(collected, "features") OR (structKeyExists(collected, "features") AND arrayLen(collected.features) EQ 0)>
                        <cfset aiResponse = "What features do you need? (Type multiple features separated by commas, e.g., 'contact form, gallery, blog')">
                    <cfelse>
                        <cfset aiResponse = "Perfect! I have all the information I need. Click the submit button below to complete your form.">
                        <cfset updatedProjectInfo.stage = "complete">
                    </cfif>
                </cfcase>
                
                <cfcase value="complete">
                    <cfset aiResponse = "Your form is complete! Click submit to send it.">
                </cfcase>
            </cfswitch>
        </cfdefaultcase>
    </cfswitch>
    
    <!--- If using AI, call Claude API --->
    <cfif useAI AND len(trim(aiResponse)) EQ 0>
        <!--- Build messages array --->
        <cfset messages = []>
        <cfloop array="#conversationHistory#" index="msg">
            <cfset arrayAppend(messages, msg)>
        </cfloop>
        <cfset arrayAppend(messages, {"role": "user", "content": userMessage})>
        
        <!--- Call Claude API --->
        <cfset apiUrl = "https://api.anthropic.com/v1/messages">
        <cfset apiKey = application.claudeApiKey>
        
        <cfhttp url="#apiUrl#" method="POST" timeout="30" result="httpResult">
            <cfhttpparam type="header" name="x-api-key" value="#apiKey#">
            <cfhttpparam type="header" name="anthropic-version" value="2023-06-01">
            <cfhttpparam type="header" name="content-type" value="application/json">
            <cfhttpparam type="body" value='#serializeJSON({
                "model": "claude-3-haiku-20240307",
                "max_tokens": 200,
                "temperature": 0.1,
                "system": systemPrompt,
                "messages": messages
            })#'>
        </cfhttp>
        
        <cfif httpResult.statusCode EQ "200 OK">
            <cfset claudeResponse = deserializeJSON(httpResult.fileContent)>
            <cfset aiResponse = claudeResponse.content[1].text>
        <cfelse>
            <cfset aiResponse = "I'm having trouble understanding. Could you tell me if you need a website, mobile app, or software platform?">
        </cfif>
    </cfif>
    
    <!--- Update conversation history --->
    <cfset arrayAppend(conversationHistory, {"role": "user", "content": userMessage})>
    <cfset arrayAppend(conversationHistory, {"role": "assistant", "content": aiResponse})>
    
    <!--- Process user response and update project info --->
    <cfswitch expression="#currentStage#">
        <cfcase value="project_type">
            <cfif findNoCase("website", userMessage) OR findNoCase("website", aiResponse)>
                <cfset updatedProjectInfo.project_type = "website">
                <cfset updatedProjectInfo.stage = "service_type">
            <cfelseif findNoCase("app", userMessage) OR findNoCase("mobile", userMessage) OR findNoCase("mobile app", aiResponse)>
                <cfset updatedProjectInfo.project_type = "mobile_app">
                <cfset updatedProjectInfo.stage = "service_type">
            <cfelseif findNoCase("software", userMessage) OR findNoCase("saas", userMessage) OR findNoCase("system", userMessage) OR findNoCase("software platform", aiResponse)>
                <cfset updatedProjectInfo.project_type = "saas">
                <cfset updatedProjectInfo.stage = "service_type">
            </cfif>
        </cfcase>
        
        <cfcase value="service_type">
            <cfif updatedProjectInfo.project_type EQ "website">
                <cfif findNoCase("ecommerce", userMessage) OR findNoCase("store", userMessage) OR findNoCase("shop", userMessage)>
                    <cfset updatedProjectInfo.service_type = "ecommerce_standard">
                    <cfset updatedProjectInfo.stage = "basic_info">
                <cfelseif findNoCase("corporate", userMessage) OR findNoCase("business", userMessage) OR findNoCase("company", userMessage)>
                    <cfset updatedProjectInfo.service_type = "corporate_standard">
                    <cfset updatedProjectInfo.stage = "basic_info">
                <cfelseif findNoCase("portfolio", userMessage) OR findNoCase("personal", userMessage)>
                    <cfset updatedProjectInfo.service_type = "portfolio">
                    <cfset updatedProjectInfo.stage = "basic_info">
                <cfelseif findNoCase("blog", userMessage) OR findNoCase("news", userMessage)>
                    <cfset updatedProjectInfo.service_type = "blog_news">
                    <cfset updatedProjectInfo.stage = "basic_info">
                <cfelseif findNoCase("landing", userMessage)>
                    <cfset updatedProjectInfo.service_type = "landing_page">
                    <cfset updatedProjectInfo.stage = "basic_info">
                <cfelseif isNumeric(trim(userMessage))>
                    <cfset num = val(userMessage)>
                    <cfswitch expression="#num#">
                        <cfcase value="1"><cfset updatedProjectInfo.service_type = "ecommerce_standard"></cfcase>
                        <cfcase value="2"><cfset updatedProjectInfo.service_type = "corporate_standard"></cfcase>
                        <cfcase value="3"><cfset updatedProjectInfo.service_type = "portfolio"></cfcase>
                        <cfcase value="4"><cfset updatedProjectInfo.service_type = "blog_news"></cfcase>
                        <cfcase value="5"><cfset updatedProjectInfo.service_type = "landing_page"></cfcase>
                        <cfcase value="6"><cfset updatedProjectInfo.service_type = "custom_website"></cfcase>
                    </cfswitch>
                    <cfset updatedProjectInfo.stage = "basic_info">
                </cfif>
                <!--- Force simple response after service selection --->
                <cfif structKeyExists(updatedProjectInfo, "service_type") AND len(updatedProjectInfo.service_type)>
                    <cfset aiResponse = "Great choice! Now I need to collect some information from you. What's your first name?">
                    <cfset useAI = false> <!--- IMPORTANT: Disable AI for this response --->
                    <cfset updatedProjectInfo.stage = "basic_info"> <!--- Move to next stage --->
                </cfif>
            <cfelseif updatedProjectInfo.project_type EQ "mobile_app">
                <cfif isNumeric(trim(userMessage))>
                    <cfset num = val(userMessage)>
                    <cfswitch expression="#num#">
                        <cfcase value="1"><cfset updatedProjectInfo.service_type = "ios_app"></cfcase>
                        <cfcase value="2"><cfset updatedProjectInfo.service_type = "android_app"></cfcase>
                        <cfcase value="3"><cfset updatedProjectInfo.service_type = "cross_platform_app"></cfcase>
                    </cfswitch>
                    <cfset updatedProjectInfo.stage = "basic_info">
                    <!--- Force simple response after service selection --->
                    <cfset aiResponse = "Perfect! Now I need to collect some information from you. What's your first name?">
                    <cfset useAI = false>
                </cfif>
            </cfif>
        </cfcase>
        
        <cfcase value="basic_info">
            <cfif NOT structKeyExists(updatedProjectInfo, "basicInfo")>
                <cfset updatedProjectInfo.basicInfo = {}>
            </cfif>
            <cfset collected = updatedProjectInfo.basicInfo>
            
            <cfif NOT structKeyExists(collected, "first_name") OR NOT len(trim(structKeyExists(collected, "first_name") ? collected.first_name : ""))>
                <cfset updatedProjectInfo.basicInfo.first_name = trim(userMessage)>
            <cfelseif NOT structKeyExists(collected, "last_name") OR NOT len(trim(structKeyExists(collected, "last_name") ? collected.last_name : ""))>
                <cfset updatedProjectInfo.basicInfo.last_name = trim(userMessage)>
            <cfelseif NOT structKeyExists(collected, "email")>
                <cfif find("@", userMessage) AND len(trim(userMessage)) GT 0>
                    <cfset updatedProjectInfo.basicInfo.email = trim(userMessage)>
                <cfelse>
                    <!--- Invalid email, don't save it --->
                </cfif>
            <cfelseif NOT structKeyExists(collected, "phone")>
                <cfset updatedProjectInfo.basicInfo.phone = trim(userMessage)>
            <cfelseif NOT structKeyExists(collected, "company")>
                <cfset updatedProjectInfo.basicInfo.company = trim(userMessage)>
            <cfelseif NOT structKeyExists(collected, "contact_method")>
                <cfif isNumeric(trim(userMessage))>
                    <cfset num = val(userMessage)>
                    <cfswitch expression="#num#">
                        <cfcase value="1"><cfset updatedProjectInfo.basicInfo.contact_method = "email"></cfcase>
                        <cfcase value="2"><cfset updatedProjectInfo.basicInfo.contact_method = "phone"></cfcase>
                        <cfcase value="3"><cfset updatedProjectInfo.basicInfo.contact_method = "text"></cfcase>
                        <cfcase value="4"><cfset updatedProjectInfo.basicInfo.contact_method = "whatsapp"></cfcase>
                    </cfswitch>
                <cfelse>
                    <!--- Text input - try to match --->
                    <cfif findNoCase("email", userMessage)>
                        <cfset updatedProjectInfo.basicInfo.contact_method = "email">
                    <cfelseif findNoCase("phone", userMessage)>
                        <cfset updatedProjectInfo.basicInfo.contact_method = "phone">
                    <cfelseif findNoCase("text", userMessage) OR findNoCase("sms", userMessage)>
                        <cfset updatedProjectInfo.basicInfo.contact_method = "text">
                    <cfelseif findNoCase("whatsapp", userMessage)>
                        <cfset updatedProjectInfo.basicInfo.contact_method = "whatsapp">
                    </cfif>
                </cfif>
            <cfelseif NOT structKeyExists(collected, "website")>
                <cfset updatedProjectInfo.basicInfo.website = trim(userMessage)>
            </cfif>
        </cfcase>
        
        <cfcase value="project_details">
            <cfif NOT structKeyExists(updatedProjectInfo, "projectDetails")>
                <cfset updatedProjectInfo.projectDetails = {}>
            </cfif>
            <cfset collected = updatedProjectInfo.projectDetails>
            
            <cfif NOT structKeyExists(collected, "description")>
                <cfset updatedProjectInfo.projectDetails.description = trim(userMessage)>
            <cfelseif NOT structKeyExists(collected, "target_audience")>
                <cfset updatedProjectInfo.projectDetails.target_audience = trim(userMessage)>
            <cfelseif NOT structKeyExists(collected, "geographic_target")>
                <cfif isNumeric(trim(userMessage))>
                    <cfset num = val(userMessage)>
                    <cfswitch expression="#num#">
                        <cfcase value="1"><cfset updatedProjectInfo.projectDetails.geographic_target = "local"></cfcase>
                        <cfcase value="2"><cfset updatedProjectInfo.projectDetails.geographic_target = "national"></cfcase>
                        <cfcase value="3"><cfset updatedProjectInfo.projectDetails.geographic_target = "international"></cfcase>
                        <cfcase value="4"><cfset updatedProjectInfo.projectDetails.geographic_target = "specific"></cfcase>
                    </cfswitch>
                </cfif>
            <cfelseif NOT structKeyExists(collected, "timeline")>
                <cfif isNumeric(trim(userMessage))>
                    <cfset num = val(userMessage)>
                    <cfswitch expression="#num#">
                        <cfcase value="1"><cfset updatedProjectInfo.projectDetails.timeline = "asap"></cfcase>
                        <cfcase value="2"><cfset updatedProjectInfo.projectDetails.timeline = "1_month"></cfcase>
                        <cfcase value="3"><cfset updatedProjectInfo.projectDetails.timeline = "2_months"></cfcase>
                        <cfcase value="4"><cfset updatedProjectInfo.projectDetails.timeline = "3_months"></cfcase>
                        <cfcase value="5"><cfset updatedProjectInfo.projectDetails.timeline = "6_months"></cfcase>
                        <cfcase value="6"><cfset updatedProjectInfo.projectDetails.timeline = "flexible"></cfcase>
                    </cfswitch>
                </cfif>
            <cfelseif NOT structKeyExists(collected, "budget")>
                <cfif isNumeric(trim(userMessage))>
                    <cfset num = val(userMessage)>
                    <cfswitch expression="#num#">
                        <cfcase value="1"><cfset updatedProjectInfo.projectDetails.budget = "under_1k"></cfcase>
                        <cfcase value="2"><cfset updatedProjectInfo.projectDetails.budget = "1k_5k"></cfcase>
                        <cfcase value="3"><cfset updatedProjectInfo.projectDetails.budget = "5k_10k"></cfcase>
                        <cfcase value="4"><cfset updatedProjectInfo.projectDetails.budget = "10k_25k"></cfcase>
                        <cfcase value="5"><cfset updatedProjectInfo.projectDetails.budget = "25k_50k"></cfcase>
                        <cfcase value="6"><cfset updatedProjectInfo.projectDetails.budget = "50k_plus"></cfcase>
                        <cfcase value="7"><cfset updatedProjectInfo.projectDetails.budget = "not_sure"></cfcase>
                    </cfswitch>
                </cfif>
            </cfif>
        </cfcase>
        
        <cfcase value="design_features">
            <cfif NOT structKeyExists(updatedProjectInfo, "designFeatures")>
                <cfset updatedProjectInfo.designFeatures = {}>
            </cfif>
            <cfset collected = updatedProjectInfo.designFeatures>
            
            <cfif NOT structKeyExists(collected, "colors") OR (structKeyExists(collected, "colors") AND isArray(collected.colors) AND NOT arrayLen(collected.colors))>
                <!--- Parse comma-separated colors --->
                <cfset colorList = []>
                <cfloop list="#userMessage#" index="color">
                    <cfset arrayAppend(colorList, trim(color))>
                </cfloop>
                <cfset updatedProjectInfo.designFeatures.colors = colorList>
            <cfelseif NOT structKeyExists(collected, "style") OR NOT len(trim(structKeyExists(collected, "style") ? collected.style : ""))>
                <cfif isNumeric(trim(userMessage))>
                    <cfset num = val(userMessage)>
                    <cfswitch expression="#num#">
                        <cfcase value="1"><cfset updatedProjectInfo.designFeatures.style = "modern_minimal"></cfcase>
                        <cfcase value="2"><cfset updatedProjectInfo.designFeatures.style = "corporate_professional"></cfcase>
                        <cfcase value="3"><cfset updatedProjectInfo.designFeatures.style = "creative_bold"></cfcase>
                        <cfcase value="4"><cfset updatedProjectInfo.designFeatures.style = "friendly_approachable"></cfcase>
                        <cfcase value="5"><cfset updatedProjectInfo.designFeatures.style = "elegant_sophisticated"></cfcase>
                        <cfcase value="6"><cfset updatedProjectInfo.designFeatures.style = "tech_futuristic"></cfcase>
                        <cfcase value="7"><cfset updatedProjectInfo.designFeatures.style = "no_preference"></cfcase>
                    </cfswitch>
                <cfelse>
                    <!--- Try text matching --->
                    <cfif findNoCase("modern", userMessage) OR findNoCase("minimal", userMessage)>
                        <cfset updatedProjectInfo.designFeatures.style = "modern_minimal">
                    <cfelseif findNoCase("corporate", userMessage) OR findNoCase("professional", userMessage)>
                        <cfset updatedProjectInfo.designFeatures.style = "corporate_professional">
                    </cfif>
                </cfif>
            <cfelseif NOT structKeyExists(collected, "features")>
                <!--- Parse comma-separated features --->
                <cfset featureList = []>
                <cfloop list="#userMessage#" index="feature">
                    <cfset arrayAppend(featureList, trim(feature))>
                </cfloop>
                <cfset updatedProjectInfo.designFeatures.features = featureList>
            </cfif>
        </cfcase>
    </cfswitch>
    
    <!--- Re-evaluate what question to ask after processing input --->
    <!--- IMPORTANT: Always re-evaluate to ensure we ask the next question --->
    <cfif len(trim(aiResponse)) EQ 0 OR currentStage NEQ "project_type">
        <cfswitch expression="#updatedProjectInfo.stage#">
            <cfcase value="basic_info">
                <cfset collected = structKeyExists(updatedProjectInfo, "basicInfo") ? updatedProjectInfo.basicInfo : {}>
                <cfif NOT structKeyExists(collected, "first_name") OR NOT len(trim(structKeyExists(collected, "first_name") ? collected.first_name : ""))>
                    <cfset aiResponse = "What's your first name?">
                <cfelseif NOT structKeyExists(collected, "last_name") OR NOT len(trim(structKeyExists(collected, "last_name") ? collected.last_name : ""))>
                    <cfset aiResponse = "What's your last name?">
                <cfelseif NOT structKeyExists(collected, "email") OR NOT len(trim(structKeyExists(collected, "email") ? collected.email : ""))>
                    <cfset aiResponse = "What's your email address?">
                <cfelseif NOT structKeyExists(collected, "phone") OR NOT len(trim(structKeyExists(collected, "phone") ? collected.phone : ""))>
                    <cfset aiResponse = "What's your phone number?">
                <cfelseif NOT structKeyExists(collected, "company") OR NOT len(trim(structKeyExists(collected, "company") ? collected.company : ""))>
                    <cfset aiResponse = "What's your company name?">
                <cfelseif NOT structKeyExists(collected, "contact_method") OR NOT len(trim(structKeyExists(collected, "contact_method") ? collected.contact_method : ""))>
                    <cfset aiResponse = "How would you prefer to be contacted?
1. Email
2. Phone
3. Text Message
4. WhatsApp">
                <cfelseif NOT structKeyExists(collected, "website") OR NOT len(trim(structKeyExists(collected, "website") ? collected.website : ""))>
                    <cfset aiResponse = "Do you have an existing website? (Enter URL or type 'no')">
                <cfelse>
                    <cfset updatedProjectInfo.stage = "project_details">
                    <cfset aiResponse = "Please describe your project briefly:">
                </cfif>
            </cfcase>
            
            <cfcase value="project_details">
                <cfset collected = structKeyExists(updatedProjectInfo, "projectDetails") ? updatedProjectInfo.projectDetails : {}>
                <cfif NOT structKeyExists(collected, "description") OR NOT len(trim(structKeyExists(collected, "description") ? collected.description : ""))>
                    <cfset aiResponse = "Please describe your project briefly:">
                <cfelseif NOT structKeyExists(collected, "target_audience") OR NOT len(trim(structKeyExists(collected, "target_audience") ? collected.target_audience : ""))>
                    <cfset aiResponse = "Who is your target audience?">
                <cfelseif NOT structKeyExists(collected, "geographic_target") OR NOT len(trim(structKeyExists(collected, "geographic_target") ? collected.geographic_target : ""))>
                    <cfset aiResponse = "Where will your project target?
1. Local (City/Region)
2. National
3. International
4. Specific Countries/Regions">
                <cfelseif NOT structKeyExists(collected, "timeline") OR NOT len(trim(structKeyExists(collected, "timeline") ? collected.timeline : ""))>
                    <cfset aiResponse = "What's your project timeline?
1. ASAP
2. Within 1 month
3. Within 2 months
4. Within 3 months
5. Within 6 months
6. Flexible">
                <cfelseif NOT structKeyExists(collected, "budget") OR NOT len(trim(structKeyExists(collected, "budget") ? collected.budget : ""))>
                    <cfset aiResponse = "What's your budget range?
1. Under $1,000
2. $1,000 - $5,000
3. $5,000 - $10,000
4. $10,000 - $25,000
5. $25,000 - $50,000
6. $50,000+
7. Not sure yet">
                <cfelse>
                    <cfset updatedProjectInfo.stage = "design_features">
                    <cfset aiResponse = "What colors would you like? (Type multiple colors separated by commas, e.g., 'blue, white, gray')">
                </cfif>
            </cfcase>
            
            <cfcase value="design_features">
                <cfset collected = structKeyExists(updatedProjectInfo, "designFeatures") ? updatedProjectInfo.designFeatures : {}>
                <cfif NOT structKeyExists(collected, "colors") OR (structKeyExists(collected, "colors") AND isArray(collected.colors) AND arrayLen(collected.colors) EQ 0)>
                    <cfset aiResponse = "What colors would you like? (Type multiple colors separated by commas, e.g., 'blue, white, gray')">
                <cfelseif NOT structKeyExists(collected, "style") OR len(trim(structKeyExists(collected, "style") ? collected.style : "")) EQ 0>
                    <cfset aiResponse = "What design style do you prefer?
1. Modern & Minimal
2. Corporate & Professional
3. Creative & Bold
4. Friendly & Approachable
5. Elegant & Sophisticated
6. Tech & Futuristic
7. No Preference">
                <cfelseif NOT structKeyExists(collected, "features") OR (structKeyExists(collected, "features") AND isArray(collected.features) AND arrayLen(collected.features) EQ 0)>
                    <cfset aiResponse = "What features do you need? (Type multiple features separated by commas, e.g., 'contact form, gallery, blog')">
                <cfelse>
                    <cfset updatedProjectInfo.stage = "complete">
                    <cfset aiResponse = "Perfect! I have all the information I need. Click the submit button below to complete your form.">
                </cfif>
            </cfcase>
        </cfswitch>
    </cfif>
    
    <!--- Debug log with more details --->
    <cftry>
        <cfset debugInfo = {
            "stage" = currentStage,
            "userMsg" = userMessage,
            "response" = aiResponse,
            "updatedStage" = updatedProjectInfo.stage
        }>
        <cflog file="smart-chat-debug" text="#serializeJSON(debugInfo)#">
        <cfcatch>
            <cflog file="smart-chat-debug" text="Stage: #currentStage#, UserMsg: #userMessage#, Response: #left(aiResponse, 100)#">
        </cfcatch>
    </cftry>
    
    <!--- Return response --->
    <cfset response = {
        "success": true,
        "response": aiResponse,
        "projectInfo": updatedProjectInfo,
        "conversationHistory": conversationHistory,
        "isComplete": updatedProjectInfo.stage EQ "complete"
    }>
    
    <cfoutput>#serializeJSON(response)#</cfoutput>
    
    <cfcatch>
        <cfset response = {
            "success": false,
            "error": cfcatch.message,
            "detail": structKeyExists(cfcatch, "detail") ? cfcatch.detail : "",
            "type": structKeyExists(cfcatch, "type") ? cfcatch.type : "",
            "response": "Sorry, I encountered an error. Please try again."
        }>
        <cflog file="smart-chat-error" text="Error: #cfcatch.message# - Detail: #structKeyExists(cfcatch, 'detail') ? cfcatch.detail : 'none'#">
        <cfoutput>#serializeJSON(response)#</cfoutput>
    </cfcatch>
</cftry>