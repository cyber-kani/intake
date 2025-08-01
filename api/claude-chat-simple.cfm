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
    <cfset systemPrompt = "You are an assistant collecting form information. Be VERY brief. Ask short questions. Only ask for: project type, service type, first name, last name, email, phone, company name, and project description.

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
                <cfset systemPrompt &= "Ask: Your first name?">
            <cfelseif NOT structKeyExists(collected, "last_name")>
                <cfset systemPrompt &= "Ask: Your last name?">
            <cfelseif NOT structKeyExists(collected, "email")>
                <cfset systemPrompt &= "Ask: Your email?">
            <cfelseif NOT structKeyExists(collected, "phone")>
                <cfset systemPrompt &= "Ask: Your phone number?">
            <cfelseif NOT structKeyExists(collected, "company")>
                <cfset systemPrompt &= "Ask: Company name?">
            <cfelse>
                <cfset systemPrompt &= "Say: Thanks! Now tell me about your project.">
            </cfif>
        </cfcase>
        
        <cfcase value="project_details">
            <cfset systemPrompt &= "Ask: Describe your project briefly.">
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
            "temperature": 0.3,
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
                <cfset updatedProjectInfo.stage = "project_details">
            </cfif>
        </cfcase>
        
        <cfcase value="project_details">
            <cfset updatedProjectInfo.projectDetails = {"description": userMessage}>
            <cfset updatedProjectInfo.stage = "complete">
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