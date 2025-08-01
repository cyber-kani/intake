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

<!--- Skip session check for testing --->

<cfparam name="form.message" default="">
<cfparam name="form.conversationHistory" default="[]">
<cfparam name="form.projectInfo" default="{}">

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
    
    <!--- Build basic system prompt --->
    <cfset systemPrompt = "You are a friendly AI assistant helping users complete their project intake form. Be conversational and ask ONLY ONE QUESTION AT A TIME.

Current stage: #currentStage#

">
    
    <!--- Add stage-specific prompts --->
    <cfswitch expression="#currentStage#">
        <cfcase value="project_type">
            <cfset systemPrompt &= "Ask what they want to build. When they respond, show them specific service options as a numbered list.">
        </cfcase>
        
        <cfcase value="basic_info">
            <cfset systemPrompt &= "Collect basic information one at a time: company name, industry, name, email, phone.">
        </cfcase>
        
        <cfdefaultcase>
            <cfset systemPrompt &= "Continue collecting information for stage: #currentStage#">
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
    
    <!--- Create a simple test response for now --->
    <cfset aiResponse = "I understand you said: #userMessage#. Let me help you with that.">
    
    <cfif findNoCase("website", userMessage)>
        <cfset aiResponse = "Great! What type of website do you need?

1. E-commerce Website - Online store with shopping cart
2. Corporate Website - Professional business site
3. Portfolio Website - Showcase your work
4. Blog Website - Content publishing
5. Other - Something different

Which option best fits your needs?">
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
            "response": "I encountered an error. Please try again."
        }>
        <cfoutput>#serializeJSON(response)#</cfoutput>
    </cfcatch>
</cftry>