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
    
    <!--- Build very simple system prompt --->
    <cfset systemPrompt = "You are a form assistant. CRITICAL RULE: You MUST ask ONLY ONE question at a time. Do NOT list multiple questions. Do NOT show a numbered list of questions. Ask ONE thing, wait for the answer, then ask the next thing.

Current stage: #currentStage#

">
    
    <!--- Add stage-specific prompts --->
    <cfswitch expression="#currentStage#">
        <cfcase value="project_type">
            <cfset systemPrompt &= "Ask: What do you need? (website, app, or software)">
        </cfcase>
        
        <cfcase value="service_type">
            <cfset systemPrompt &= "They said they need a #currentProjectInfo.project_type#. Show numbered options:
For website: 1. E-commerce 2. Corporate 3. Portfolio 4. Blog 5. Other
For app: 1. iOS 2. Android 3. Both
For software: 1. CRM 2. Dashboard 3. Other">
        </cfcase>
        
        <cfcase value="basic_info">
            <cfset collected = structKeyExists(currentProjectInfo, "basicInfo") ? currentProjectInfo.basicInfo : {}>
            <cfif NOT structKeyExists(collected, "first_name")>
                <cfset systemPrompt &= "Ask EXACTLY this and NOTHING else: 'What's your first name?'">
            <cfelseif NOT structKeyExists(collected, "last_name")>
                <cfset systemPrompt &= "Say EXACTLY this: 'Thanks! What's your last name?'">
            <cfelseif NOT structKeyExists(collected, "email")>
                <cfset systemPrompt &= "Say EXACTLY this: 'What's your email address?'">
            <cfelseif NOT structKeyExists(collected, "phone")>
                <cfset systemPrompt &= "Say EXACTLY this: 'What's your phone number?'">
            <cfelseif NOT structKeyExists(collected, "company")>
                <cfset systemPrompt &= "Say EXACTLY this: 'What's your company name?'">
            <cfelseif NOT structKeyExists(collected, "contact_method")>
                <cfset systemPrompt &= "Say EXACTLY this: 'How would you prefer to be contacted?
1. Email
2. Phone
3. Text Message
4. WhatsApp'">
            <cfelseif NOT structKeyExists(collected, "website")>
                <cfset systemPrompt &= "Say EXACTLY this: 'Do you have an existing website? (Enter URL or say no)'">
            <cfelse>
                <cfset systemPrompt &= "Say EXACTLY this: 'Thanks! Now let me get some project details.'">
                <cfset updatedProjectInfo.stage = "project_details">
            </cfif>
        </cfcase>
        
        <cfcase value="project_details">
            <cfset collected = structKeyExists(currentProjectInfo, "projectDetails") ? currentProjectInfo.projectDetails : {}>
            <cfif NOT structKeyExists(collected, "description")>
                <cfset systemPrompt &= "Say EXACTLY this: 'Please describe your project briefly.'">
            <cfelseif NOT structKeyExists(collected, "target_audience")>
                <cfset systemPrompt &= "Say EXACTLY this: 'Who is your target audience?'">
            <cfelseif NOT structKeyExists(collected, "geographic_target")>
                <cfset systemPrompt &= "Say EXACTLY this: 'Where will your project target?
1. Local (City/Region)
2. National
3. International
4. Specific Countries/Regions'">
            <cfelseif NOT structKeyExists(collected, "timeline")>
                <cfset systemPrompt &= "Say EXACTLY this: 'What's your project timeline?
1. ASAP
2. Within 1 month
3. Within 2 months
4. Within 3 months
5. Within 6 months
6. Flexible'">
            <cfelseif NOT structKeyExists(collected, "budget")>
                <cfset systemPrompt &= "Say EXACTLY this: 'What's your budget range?
1. Under $1,000
2. $1,000 - $5,000
3. $5,000 - $10,000
4. $10,000 - $25,000
5. $25,000 - $50,000
6. $50,000+
7. Not sure yet'">
            <cfelse>
                <cfset systemPrompt &= "Say EXACTLY this: 'Perfect! I have all the information I need. Click the submit button below to complete your form.'">
                <cfset updatedProjectInfo.stage = "complete">
            </cfif>
        </cfcase>
        
        <cfcase value="complete">
            <cfset systemPrompt &= "Say: All done! Click submit below.">
        </cfcase>
    </cfswitch>
    
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
    
    <cfset aiResponse = "Error connecting">
    <cfif httpResult.statusCode EQ "200 OK">
        <cfset claudeResponse = deserializeJSON(httpResult.fileContent)>
        <cfset aiResponse = claudeResponse.content[1].text>
    </cfif>
    
    <!--- Update conversation history --->
    <cfset arrayAppend(conversationHistory, {"role": "user", "content": userMessage})>
    <cfset arrayAppend(conversationHistory, {"role": "assistant", "content": aiResponse})>
    
    <!--- Update project info based on stage --->
    <cfset updatedProjectInfo = duplicate(currentProjectInfo)>
    
    <cfswitch expression="#currentStage#">
        <cfcase value="project_type">
            <cfif findNoCase("website", userMessage)>
                <cfset updatedProjectInfo.project_type = "website">
                <cfset updatedProjectInfo.stage = "service_type">
            <cfelseif findNoCase("app", userMessage) OR findNoCase("mobile", userMessage)>
                <cfset updatedProjectInfo.project_type = "mobile_app">
                <cfset updatedProjectInfo.stage = "service_type">
            <cfelseif findNoCase("software", userMessage) OR findNoCase("saas", userMessage)>
                <cfset updatedProjectInfo.project_type = "saas">
                <cfset updatedProjectInfo.stage = "service_type">
            </cfif>
        </cfcase>
        
        <cfcase value="service_type">
            <cfif isNumeric(trim(userMessage))>
                <cfset num = val(userMessage)>
                <cfif updatedProjectInfo.project_type EQ "website">
                    <cfswitch expression="#num#">
                        <cfcase value="1"><cfset updatedProjectInfo.service_type = "ecommerce_standard"></cfcase>
                        <cfcase value="2"><cfset updatedProjectInfo.service_type = "corporate_standard"></cfcase>
                        <cfcase value="3"><cfset updatedProjectInfo.service_type = "portfolio"></cfcase>
                        <cfcase value="4"><cfset updatedProjectInfo.service_type = "blog_news"></cfcase>
                        <cfcase value="5"><cfset updatedProjectInfo.service_type = "custom_website"></cfcase>
                    </cfswitch>
                </cfif>
                <cfset updatedProjectInfo.stage = "basic_info">
            </cfif>
        </cfcase>
        
        <cfcase value="basic_info">
            <cfif NOT structKeyExists(updatedProjectInfo, "basicInfo")>
                <cfset updatedProjectInfo.basicInfo = {}>
            </cfif>
            <cfset collected = updatedProjectInfo.basicInfo>
            
            <cfif NOT structKeyExists(collected, "first_name")>
                <cfset updatedProjectInfo.basicInfo.first_name = trim(userMessage)>
            <cfelseif NOT structKeyExists(collected, "last_name")>
                <cfset updatedProjectInfo.basicInfo.last_name = trim(userMessage)>
            <cfelseif NOT structKeyExists(collected, "email")>
                <cfif find("@", userMessage)>
                    <cfset updatedProjectInfo.basicInfo.email = trim(userMessage)>
                </cfif>
            <cfelseif NOT structKeyExists(collected, "phone")>
                <cfset updatedProjectInfo.basicInfo.phone = trim(userMessage)>
            <cfelseif NOT structKeyExists(collected, "company")>
                <cfset updatedProjectInfo.basicInfo.company = trim(userMessage)>
            <cfelseif NOT structKeyExists(collected, "contact_method")>
                <!--- Handle contact method selection --->
                <cfif isNumeric(trim(userMessage))>
                    <cfset num = val(userMessage)>
                    <cfswitch expression="#num#">
                        <cfcase value="1"><cfset updatedProjectInfo.basicInfo.contact_method = "email"></cfcase>
                        <cfcase value="2"><cfset updatedProjectInfo.basicInfo.contact_method = "phone"></cfcase>
                        <cfcase value="3"><cfset updatedProjectInfo.basicInfo.contact_method = "text"></cfcase>
                        <cfcase value="4"><cfset updatedProjectInfo.basicInfo.contact_method = "whatsapp"></cfcase>
                    </cfswitch>
                </cfif>
            <cfelseif NOT structKeyExists(collected, "website")>
                <cfset updatedProjectInfo.basicInfo.website = trim(userMessage)>
                <cfset updatedProjectInfo.stage = "project_details">
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
                <!--- Handle geographic target selection --->
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
                <!--- Handle timeline selection --->
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
                <!--- Handle budget selection --->
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
                <!--- Check if all required fields are collected --->
                <cfif structKeyExists(updatedProjectInfo.projectDetails, "budget")>
                    <cfset updatedProjectInfo.stage = "complete">
                </cfif>
            </cfif>
        </cfcase>
    </cfswitch>
    
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
            "response": "Error occurred"
        }>
        <cfoutput>#serializeJSON(response)#</cfoutput>
    </cfcatch>
</cftry>