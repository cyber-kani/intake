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
    
    <!--- Build system prompt - testing the problematic concatenation --->
    <cfset projectInfoJSON = "">
    <cftry>
        <cfset projectInfoJSON = serializeJSON(currentProjectInfo)>
        <cfcatch>
            <cfset projectInfoJSON = "{}">
        </cfcatch>
    </cftry>
    
    <cfset systemPrompt = "You are a friendly AI assistant helping users complete their project intake form. Be conversational and ask ONLY ONE QUESTION AT A TIME.

Current stage: ">
    
    <!--- Test concatenation --->
    <cfset systemPrompt = systemPrompt & currentStage>
    <cfset systemPrompt = systemPrompt & chr(10) & "Project info so far: ">
    <cfset systemPrompt = systemPrompt & projectInfoJSON>
    <cfset systemPrompt = systemPrompt & chr(10) & chr(10)>
    
    <!--- Add stage-specific prompts with proper concatenation --->
    <cfswitch expression="#currentStage#">
        <cfcase value="project_type">
            <cfset systemPrompt = systemPrompt & "Ask what they want to build. When they respond, show them specific service options as a numbered list.

WEBSITE services:
1. E-commerce Website - Online store with shopping cart and payments
2. Corporate Website - Professional business site with company information
3. Portfolio Website - Showcase your work and achievements
4. Blog/News Website - Content publishing platform
5. Landing Page - Single page for product/service promotion

When they select a service, respond with: 'Great choice! I've selected [service] for you. Now, let me get some basic information about you and your company.'">
        </cfcase>
        
        <cfcase value="basic_info">
            <cfset collectedInfo = "{}">
            <cfif structKeyExists(currentProjectInfo, "basicInfo")>
                <cftry>
                    <cfset collectedInfo = serializeJSON(currentProjectInfo.basicInfo)>
                    <cfcatch>
                        <cfset collectedInfo = "{}">
                    </cfcatch>
                </cftry>
            </cfif>
            <cfset systemPrompt = systemPrompt & "STAGE 3: Basic Information Collection
Current collected info: ">
            <cfset systemPrompt = systemPrompt & collectedInfo>
            <cfset systemPrompt = systemPrompt & "

Ask for the NEXT piece of information that hasn't been collected yet.">
        </cfcase>
        
        <cfdefaultcase>
            <cfset systemPrompt = systemPrompt & "Continue collecting information for stage: ">
            <cfset systemPrompt = systemPrompt & currentStage>
        </cfdefaultcase>
    </cfswitch>
    
    <!--- Build messages array --->
    <cfset messages = []>
    
    <!--- Add conversation history --->
    <cfloop array="#conversationHistory#" index="msg">
        <cfset arrayAppend(messages, msg)>
    </cfloop>
    
    <!--- Add current user message --->
    <cfset arrayAppend(messages, {
        "role": "user",
        "content": userMessage
    })>
    
    <!--- Call Claude API --->
    <cfset apiUrl = "https://api.anthropic.com/v1/messages">
    <cfset apiKey = application.claudeApiKey>
    
    <cfhttp url="#apiUrl#" method="POST" timeout="30" result="httpResult">
        <cfhttpparam type="header" name="x-api-key" value="#apiKey#">
        <cfhttpparam type="header" name="anthropic-version" value="2023-06-01">
        <cfhttpparam type="header" name="content-type" value="application/json">
        <cfhttpparam type="body" value='#serializeJSON({
            "model": "claude-3-haiku-20240307",
            "max_tokens": 1000,
            "temperature": 0.7,
            "system": systemPrompt,
            "messages": messages
        })#'>
    </cfhttp>
    
    <cfif httpResult.statusCode EQ "200 OK">
        <cfset claudeResponse = deserializeJSON(httpResult.fileContent)>
        <cfset aiResponse = claudeResponse.content[1].text>
    <cfelse>
        <cfset aiResponse = "I'm having trouble connecting right now. Status: #httpResult.statusCode#">
    </cfif>
    
    <!--- Update conversation history --->
    <cfset arrayAppend(conversationHistory, {
        "role": "user",
        "content": userMessage
    })>
    <cfset arrayAppend(conversationHistory, {
        "role": "assistant",
        "content": aiResponse
    })>
    
    <!--- Create updated project info --->
    <cfset updatedProjectInfo = duplicate(currentProjectInfo)>
    
    <!--- Check if user selected a number --->
    <cfif currentStage EQ "project_type" AND reFind("^\d+$", trim(userMessage))>
        <cfset selectedNum = val(userMessage)>
        <cfif selectedNum EQ 1>
            <cfset updatedProjectInfo.project_type = "website">
            <cfset updatedProjectInfo.service_category = "ecommerce">
            <cfset updatedProjectInfo.service_type = "ecommerce_standard">
            <cfset updatedProjectInfo.stage = "basic_info">
        <cfelseif selectedNum EQ 2>
            <cfset updatedProjectInfo.project_type = "website">
            <cfset updatedProjectInfo.service_category = "corporate">
            <cfset updatedProjectInfo.service_type = "corporate_standard">
            <cfset updatedProjectInfo.stage = "basic_info">
        <cfelseif selectedNum EQ 3>
            <cfset updatedProjectInfo.project_type = "website">
            <cfset updatedProjectInfo.service_category = "corporate">
            <cfset updatedProjectInfo.service_type = "portfolio">
            <cfset updatedProjectInfo.stage = "basic_info">
        </cfif>
    </cfif>
    
    <!--- Return response --->
    <cfset response = {
        "success": true,
        "response": aiResponse,
        "projectInfo": updatedProjectInfo,
        "conversationHistory": conversationHistory,
        "isComplete": false
    }>
    
    <cfoutput>#serializeJSON(response)#</cfoutput>
    
    <cfcatch>
        <cfset response = {
            "success": false,
            "error": cfcatch.message,
            "detail": structKeyExists(cfcatch, "detail") ? cfcatch.detail : "",
            "line": structKeyExists(cfcatch, "tagcontext") AND arrayLen(cfcatch.tagcontext) ? cfcatch.tagcontext[1].line : "",
            "type": structKeyExists(cfcatch, "type") ? cfcatch.type : "",
            "response": "Error occurred"
        }>
        <cfoutput>#serializeJSON(response)#</cfoutput>
    </cfcatch>
</cftry>