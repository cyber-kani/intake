<cfsetting showdebugoutput="false">
<cfheader name="Access-Control-Allow-Origin" value="*">
<cfheader name="Access-Control-Allow-Methods" value="GET, POST, OPTIONS">
<cfheader name="Access-Control-Allow-Headers" value="Content-Type">
<cfcontent type="application/json">

<!--- Handle OPTIONS request --->
<cfif cgi.request_method EQ "OPTIONS">
    <cfheader statuscode="204" statustext="No Content">
    <cfabort>
</cfif>

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
    
    <!--- Build system prompt --->
    <cfset systemPrompt = "You are a concise AI assistant for categorizing web development projects. Keep responses VERY SHORT (1-2 sentences max).

Your task:
1. First identify if they need a WEBSITE, MOBILE APP, or SAAS platform
2. Once you know the type, show them specific service options to choose from
3. When they confirm a specific service, respond with: 'Excellent! Setting up your [service name] form now...'

When showing options, format them as a numbered list with clear descriptions.

WEBSITE services:
1. E-commerce Website - Online store with shopping cart and payments
2. Corporate Website - Professional business site with company information
3. Portfolio Website - Showcase your work and achievements
4. Blog/News Website - Content publishing platform
5. Landing Page - Single page for product/service promotion
6. Booking/Appointment Site - Schedule services and appointments
7. Educational Website - Online courses and learning platform
8. Restaurant/Hotel Website - Menu, ordering, reservations, and bookings
9. Real Estate Website - Property listings and searches
10. Healthcare Website - Medical practice or health services
11. Non-profit Website - Charity or community organization
12. Custom Website - Other specific requirements

MOBILE services:
1. iOS App - iPhone/iPad application
2. Android App - Android phone/tablet application
3. Cross-platform App - Works on both iOS and Android
4. Mobile Game - Gaming application
5. E-commerce App - Mobile shopping application
6. Enterprise App - Internal business application
7. Social App - Social networking or communication
8. Utility App - Tools, calculators, or productivity

SAAS services:
1. Project Management System - Task and team collaboration
2. CRM System - Customer relationship management
3. Analytics Dashboard - Data visualization and reporting
4. Communication Platform - Chat, video, or messaging
5. Accounting Software - Financial management tools
6. Custom SaaS Platform - Other web-based software

Examples:
User: 'I need a website'
You: 'Great! What type of website do you need?

1. E-commerce Website - Online store with shopping cart
2. Corporate Website - Professional business site
3. Portfolio Website - Showcase your work
4. Blog/News Website - Content publishing
5. Landing Page - Single page promotion
[continue list...]

Which option best fits your needs?'

User: 'I need number 2, a corporate website'
You: 'Excellent! Setting up your Corporate Website form now...'

User: 'I want to sell products online'
You: 'Perfect! Do you need:
1. E-commerce Website - Full online store with catalog
2. E-commerce Mobile App - Shopping app for phones

Which would you prefer?'

Always show clear numbered options when the type is identified.">
    
    <!--- Build messages array for Claude --->
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
        
        <!--- Add to conversation history --->
        <cfset arrayAppend(conversationHistory, {
            "role": "user",
            "content": userMessage
        })>
        <cfset arrayAppend(conversationHistory, {
            "role": "assistant",
            "content": aiResponse
        })>
        
        <!--- Check if project type was identified --->
        <cfset isComplete = false>
        <cfset identifiedType = "">
        <cfset identifiedCategory = "">
        <cfset identifiedService = "">
        
        <!--- Check for completion phrases --->
        <cfif findNoCase("Setting up your", aiResponse) AND findNoCase("form now", aiResponse)>
            <!--- Extract type and category from response --->
            
            <!--- Extract service from response --->
            <!--- Website services --->
            <cfif findNoCase("E-commerce Website", aiResponse)>
                <cfset identifiedType = "website">
                <cfset identifiedCategory = "ecommerce">
                <cfset identifiedService = "ecommerce_standard">
                <cfset isComplete = true>
            <cfelseif findNoCase("Corporate Website", aiResponse)>
                <cfset identifiedType = "website">
                <cfset identifiedCategory = "corporate">
                <cfset identifiedService = "corporate_standard">
                <cfset isComplete = true>
            <cfelseif findNoCase("Portfolio Website", aiResponse)>
                <cfset identifiedType = "website">
                <cfset identifiedCategory = "corporate">
                <cfset identifiedService = "portfolio">
                <cfset isComplete = true>
            <cfelseif findNoCase("Blog/News Website", aiResponse) OR findNoCase("Blog Website", aiResponse)>
                <cfset identifiedType = "website">
                <cfset identifiedCategory = "content_management">
                <cfset identifiedService = "blog_news">
                <cfset isComplete = true>
            <cfelseif findNoCase("Landing Page", aiResponse)>
                <cfset identifiedType = "website">
                <cfset identifiedCategory = "landing_page">
                <cfset identifiedService = "landing_page">
                <cfset isComplete = true>
            <cfelseif findNoCase("Booking/Appointment Site", aiResponse) OR findNoCase("Booking Site", aiResponse)>
                <cfset identifiedType = "website">
                <cfset identifiedCategory = "booking_service">
                <cfset identifiedService = "booking_standard">
                <cfset isComplete = true>
            <cfelseif findNoCase("Educational Website", aiResponse)>
                <cfset identifiedType = "website">
                <cfset identifiedCategory = "educational">
                <cfset identifiedService = "educational_standard">
                <cfset isComplete = true>
            <cfelseif findNoCase("Restaurant/Hotel Website", aiResponse) OR findNoCase("Restaurant Website", aiResponse) OR findNoCase("Hotel Website", aiResponse)>
                <cfset identifiedType = "website">
                <cfset identifiedCategory = "restaurant_food">
                <cfset identifiedService = "restaurant_standard">
                <cfset isComplete = true>
            <cfelseif findNoCase("Real Estate Website", aiResponse)>
                <cfset identifiedType = "website">
                <cfset identifiedCategory = "real_estate">
                <cfset identifiedService = "real_estate_standard">
                <cfset isComplete = true>
            <cfelseif findNoCase("Healthcare Website", aiResponse)>
                <cfset identifiedType = "website">
                <cfset identifiedCategory = "healthcare">
                <cfset identifiedService = "healthcare_standard">
                <cfset isComplete = true>
            <cfelseif findNoCase("Non-profit Website", aiResponse)>
                <cfset identifiedType = "website">
                <cfset identifiedCategory = "non_profit">
                <cfset identifiedService = "non_profit_standard">
                <cfset isComplete = true>
            <cfelseif findNoCase("Custom Website", aiResponse)>
                <cfset identifiedType = "website">
                <cfset identifiedCategory = "custom_web">
                <cfset identifiedService = "custom_web">
                <cfset isComplete = true>
            
            <!--- Mobile services --->
            <cfelseif findNoCase("iOS App", aiResponse)>
                <cfset identifiedType = "mobile">
                <cfset identifiedCategory = "ios_app">
                <cfset identifiedService = "ios_app">
                <cfset isComplete = true>
            <cfelseif findNoCase("Android App", aiResponse)>
                <cfset identifiedType = "mobile">
                <cfset identifiedCategory = "android_app">
                <cfset identifiedService = "android_app">
                <cfset isComplete = true>
            <cfelseif findNoCase("Cross-platform App", aiResponse)>
                <cfset identifiedType = "mobile">
                <cfset identifiedCategory = "cross_platform">
                <cfset identifiedService = "cross_platform">
                <cfset isComplete = true>
            <cfelseif findNoCase("Mobile Game", aiResponse)>
                <cfset identifiedType = "mobile">
                <cfset identifiedCategory = "mobile_game">
                <cfset identifiedService = "mobile_game">
                <cfset isComplete = true>
            <cfelseif findNoCase("E-commerce App", aiResponse)>
                <cfset identifiedType = "mobile">
                <cfset identifiedCategory = "mobile_commerce">
                <cfset identifiedService = "mobile_commerce">
                <cfset isComplete = true>
            <cfelseif findNoCase("Enterprise App", aiResponse)>
                <cfset identifiedType = "mobile">
                <cfset identifiedCategory = "enterprise_mobile">
                <cfset identifiedService = "enterprise_mobile">
                <cfset isComplete = true>
            <cfelseif findNoCase("Social App", aiResponse)>
                <cfset identifiedType = "mobile">
                <cfset identifiedCategory = "social_mobile">
                <cfset identifiedService = "social_mobile">
                <cfset isComplete = true>
            <cfelseif findNoCase("Utility App", aiResponse)>
                <cfset identifiedType = "mobile">
                <cfset identifiedCategory = "utility_mobile">
                <cfset identifiedService = "utility_mobile">
                <cfset isComplete = true>
            
            <!--- SaaS services --->
            <cfelseif findNoCase("Project Management System", aiResponse)>
                <cfset identifiedType = "saas">
                <cfset identifiedCategory = "project_management">
                <cfset identifiedService = "project_management">
                <cfset isComplete = true>
            <cfelseif findNoCase("CRM System", aiResponse)>
                <cfset identifiedType = "saas">
                <cfset identifiedCategory = "crm_sales">
                <cfset identifiedService = "crm_sales">
                <cfset isComplete = true>
            <cfelseif findNoCase("Analytics Dashboard", aiResponse)>
                <cfset identifiedType = "saas">
                <cfset identifiedCategory = "analytics_reporting">
                <cfset identifiedService = "analytics_reporting">
                <cfset isComplete = true>
            <cfelseif findNoCase("Communication Platform", aiResponse)>
                <cfset identifiedType = "saas">
                <cfset identifiedCategory = "communication">
                <cfset identifiedService = "communication">
                <cfset isComplete = true>
            <cfelseif findNoCase("Accounting Software", aiResponse)>
                <cfset identifiedType = "saas">
                <cfset identifiedCategory = "finance_accounting">
                <cfset identifiedService = "finance_accounting">
                <cfset isComplete = true>
            <cfelseif findNoCase("Custom SaaS Platform", aiResponse)>
                <cfset identifiedType = "saas">
                <cfset identifiedCategory = "custom_saas">
                <cfset identifiedService = "custom_saas">
                <cfset isComplete = true>
            </cfif>
        </cfif>
        
        <!--- Update project info if type identified --->
        <cfif len(identifiedType)>
            <cfset currentProjectInfo.type = identifiedType>
            <cfset currentProjectInfo.category = identifiedCategory>
            <cfset currentProjectInfo.service = identifiedService>
            <cfset currentProjectInfo.description = userMessage>
        </cfif>
        
        <!--- Prepare response --->
        <cfset result = {
            "success": true,
            "response": aiResponse,
            "projectInfo": currentProjectInfo,
            "isComplete": isComplete,
            "conversationHistory": conversationHistory
        }>
    <cfelse>
        <!--- Log error for debugging --->
        <cfset errorInfo = {
            "statusCode": httpResult.statusCode,
            "errorDetail": httpResult.fileContent,
            "apiKeyLength": len(apiKey),
            "headers": httpResult.responseHeader
        }>
        
        <!--- Add error info to response for debugging --->
        <cfset debugInfo = " [Debug: Status=" & httpResult.statusCode & ", Error=" & left(httpResult.fileContent, 100) & "]">
        
        <!--- Use fallback response if API fails --->
        <cfset fallbackResponse = "I understand you're looking for help with a project. Could you tell me more about what you need? Are you looking to build a website, mobile app, or software platform?">
        
        <cfset result = {
            "success": true,
            "response": fallbackResponse & debugInfo,
            "projectInfo": currentProjectInfo,
            "isComplete": false,
            "conversationHistory": conversationHistory,
            "debug": errorInfo
        }>
    </cfif>
    
    <cfoutput>#serializeJSON(result)#</cfoutput>
    
    <cfcatch>
        <cfset errorResult = {
            "success": false,
            "error": cfcatch.message,
            "detail": cfcatch.detail ?: "",
            "type": cfcatch.type ?: "",
            "response": "I apologize, but I'm having trouble processing your request. Could you please tell me: Are you looking to build a website, mobile app, or software platform?"
        }>
        <cfoutput>#serializeJSON(errorResult)#</cfoutput>
    </cfcatch>
</cftry>