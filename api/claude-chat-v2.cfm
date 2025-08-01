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

<!--- Check if user is logged in --->
<cftry>
    <cfif NOT structKeyExists(session, "isLoggedIn") OR NOT session.isLoggedIn>
        <cfset response = {
            "success": false,
            "error": "Not authenticated",
            "response": "Please log in to continue.",
            "hasSession": structKeyExists(session, "isLoggedIn"),
            "sessionValue": structKeyExists(session, "isLoggedIn") ? session.isLoggedIn : "no key"
        }>
        <cfoutput>#serializeJSON(response)#</cfoutput>
        <cfabort>
    </cfif>
    <cfcatch>
        <cfset response = {
            "success": false,
            "error": "Session error",
            "detail": cfcatch.message
        }>
        <cfoutput>#serializeJSON(response)#</cfoutput>
        <cfabort>
    </cfcatch>
</cftry>

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
    
    <!--- Define collection stages --->
    <cfset stages = [
        "project_type",
        "service_type", 
        "basic_info",
        "project_details",
        "design_features",
        "additional_info"
    ]>
    
    <!--- Determine current stage --->
    <cfset currentStage = "project_type">
    <cfif structKeyExists(currentProjectInfo, "stage")>
        <cfset currentStage = currentProjectInfo.stage>
    </cfif>
    
    <!--- Build system prompt based on current stage --->
    <cfset projectInfoJSON = "">
    <cftry>
        <cfset projectInfoJSON = serializeJSON(currentProjectInfo)>
        <cfcatch>
            <cfset projectInfoJSON = "{}">
        </cfcatch>
    </cftry>
    
    <cfset systemPrompt = "You are a friendly AI assistant helping users complete their project intake form. Be conversational and ask ONLY ONE QUESTION AT A TIME. Never show lists like 'Company Name:', 'Industry:', etc. Just ask natural questions.

Current stage: #currentStage#
Project info so far: #projectInfoJSON#

IMPORTANT RULES:
1. Ask only ONE question at a time
2. Be conversational and natural
3. Never show bullet lists of what you need to collect
4. Guide them step by step
5. Use the examples provided but make it conversational

">
    
    <!--- Stage-specific prompts --->
    <cfswitch expression="#currentStage#">
        <cfcase value="project_type">
            <cfset systemPrompt &= "
STAGE 1: Project Type Selection
Ask what they want to build. When they respond, show them specific service options as a numbered list.

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

MOBILE APP services:
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

When they select a service, respond with: 'Great choice! I've selected [service] for you. Now, let me get some basic information about you and your company.'">
        </cfcase>
        
        <cfcase value="service_type">
            <cfset systemPrompt &= "
STAGE 2: Confirming Service Selection
The user should have already selected their service type. If not, show them the options again.
Once confirmed, say: 'Perfect! Now I need to collect some basic information about you and your company.'">
        </cfcase>
        
        <cfcase value="basic_info">
            <cfset collectedInfo = "{}">
            <cfif structKeyExists(currentProjectInfo, 'basicInfo')>
                <cfset collectedInfo = serializeJSON(currentProjectInfo.basicInfo)>
            </cfif>
            <cfset systemPrompt &= "
STAGE 3: Basic Information Collection
You need to collect information ONE AT A TIME in this order:

1. Company/Organization name
2. Industry/Business type  
3. First name and last name (can ask together)
4. Email 
5. Phone number

Current collected info: #collectedInfo#

Ask for the NEXT piece of information that hasn't been collected yet. Include examples:

For company: 'What is your company or organization name? (e.g., ABC Technologies, John's Bakery, Creative Studios Ltd.)'

For industry: 'What industry or business type are you in? (e.g., Healthcare, Retail, Education, Technology, Restaurant, Real Estate)'

For name: 'Could you please provide your first and last name?'

For email: 'What's the best email address to reach you? (e.g., john@company.com)'

For phone: 'What's your phone number? (e.g., +1-555-123-4567, 07774806456)'

Once you have ALL required info, say: 'Thank you! Now let's talk about your project details.'">
        </cfcase>
        
        <cfcase value="project_details">
            <cfset projectDetailsInfo = "{}">
            <cfif structKeyExists(currentProjectInfo, 'projectDetails')>
                <cfset projectDetailsInfo = serializeJSON(currentProjectInfo.projectDetails)>
            </cfif>
            <cfset systemPrompt &= "
STAGE 4: Project Details
Collect these ONE AT A TIME:

1. Project description
2. Target audience  
3. Main goals
4. Competitor examples (optional)

Current collected: #projectDetailsInfo#

Ask for the NEXT uncollected item with examples:

For description: 'Please describe your project in detail. What do you want this #structKeyExists(currentProjectInfo, "service_type") ? currentProjectInfo.service_type : "project"# to do? 
(e.g., "I want a portfolio to showcase my photography work with galleries and client testimonials", 
"We need an online store to sell handmade jewelry with payment processing and inventory management")'

For audience: 'Who is your target audience? 
(e.g., "Small business owners in the UK", "Young professionals aged 25-40", "Local customers in New York")'

For goals: 'What are your main goals with this project? 
(e.g., "Generate more leads", "Increase online sales by 50%", "Build brand awareness", "Streamline customer bookings")'

For competitors: 'Are there any websites you like or competitors we should look at for inspiration? (This is optional - you can say "none" if you don't have any)'

Once complete, say: 'Excellent! Now let's discuss your design preferences and features.'">
        </cfcase>
        
        <cfcase value="design_features">
            <cfset designFeaturesInfo = "{}">
            <cfif structKeyExists(currentProjectInfo, 'designFeatures')>
                <cfset designFeaturesInfo = serializeJSON(currentProjectInfo.designFeatures)>
            </cfif>
            <cfset systemPrompt &= "
STAGE 5: Design & Features
Ask about these ONE AT A TIME:

1. Color preferences (show as numbered list)
2. Key features needed (show as numbered list)

Current collected: #designFeaturesInfo#

For colors (if not collected): 'What colors would you like for your #structKeyExists(currentProjectInfo, "service_type") ? currentProjectInfo.service_type : "project"#? Please select from:

1. Blue - Professional and trustworthy
2. Green - Fresh and natural  
3. Red - Bold and energetic
4. Purple - Creative and luxurious
5. Orange - Friendly and vibrant
6. Yellow - Optimistic and cheerful
7. Pink - Playful and modern
8. Gray - Sleek and sophisticated
9. Black/White - Minimal and elegant

You can select multiple colors by typing the numbers (e.g., "1, 4, 9" for Blue, Purple, and Black/White)'

For features (if colors collected): 'Which features do you need? Select all that apply:

1. Contact Forms - Let visitors get in touch
2. Blog/News Section - Share updates and articles
3. Photo/Video Gallery - Showcase visual content
4. Social Media Integration - Connect social accounts
5. User Accounts/Login - Member area access
6. Payment Processing - Accept online payments
7. Booking/Scheduling - Allow appointments
8. Multi-language Support - Multiple languages
9. Live Chat - Real-time customer support
10. Email Newsletter - Collect subscribers
11. Search Functionality - Find content easily
12. Other - Please specify

Type the numbers for features you need (e.g., "1, 3, 4" for Contact Forms, Gallery, and Social Media)'

Once complete, say: 'Almost done! Just a few final questions about your timeline and budget.'">
        </cfcase>
        
        <cfcase value="additional_info">
            <cfset additionalInfoData = "{}">
            <cfif structKeyExists(currentProjectInfo, 'additionalInfo')>
                <cfset additionalInfoData = serializeJSON(currentProjectInfo.additionalInfo)>
            </cfif>
            <cfset systemPrompt &= "
STAGE 6: Additional Information
Ask ONE AT A TIME:

1. Timeline
2. Budget (optional)
3. Additional requirements

Current collected: #additionalInfoData#

For timeline: 'When do you need this project completed?
(e.g., "Within 2 weeks", "By end of March", "ASAP", "In 2-3 months", "No rush")'

For budget: 'Do you have a budget range in mind? This helps us tailor the solution to your needs. (This is optional - you can say "skip" if you prefer not to share)
(e.g., "$1,000-$2,500", "Under $5,000", "$10,000+", "Not sure yet")'

For additional: 'Do you have any other requirements or special requests? (You can say "no" if nothing else)'

Once all collected or skipped, say: 'Perfect! I have all the information I need. Your project intake form is complete and ready to submit. Click the submit button below to send your request.'">
        </cfcase>
        
        <cfcase value="complete">
            <cfset systemPrompt &= "
All information has been collected. Respond with: 'Your form is complete and ready to submit! Click the submit button below to send your project request.'">
        </cfcase>
    </cfswitch>
    
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
        
        <!--- Extract information based on current stage and user response --->
        <cfset updatedProjectInfo = duplicate(currentProjectInfo)>
        
        <cfswitch expression="#currentStage#">
            <cfcase value="project_type">
                <!--- Check if user selected a service --->
                <cfif reFind("^\d+$", trim(userMessage))>
                    <cfset selectedNum = val(userMessage)>
                    <!--- Map number to service based on context in conversation --->
                    <cfset conversationText = "">
                    <cfloop array="#conversationHistory#" index="msg">
                        <cfset conversationText &= msg.content & " ">
                    </cfloop>
                    <cfif findNoCase("website", conversationText)>
                        <cfset websiteServices = {
                            "1": {type: "website", category: "ecommerce", service: "ecommerce_standard"},
                            "2": {type: "website", category: "corporate", service: "corporate_standard"},
                            "3": {type: "website", category: "corporate", service: "portfolio"},
                            "4": {type: "website", category: "content_management", service: "blog_news"},
                            "5": {type: "website", category: "landing_page", service: "landing_page"},
                            "6": {type: "website", category: "booking_service", service: "booking_standard"},
                            "7": {type: "website", category: "educational", service: "educational_standard"},
                            "8": {type: "website", category: "restaurant", service: "restaurant_standard"},
                            "9": {type: "website", category: "real_estate", service: "real_estate_standard"},
                            "10": {type: "website", category: "healthcare", service: "healthcare_standard"},
                            "11": {type: "website", category: "nonprofit", service: "nonprofit_standard"},
                            "12": {type: "website", category: "custom", service: "custom_website"}
                        }>
                        <cfif structKeyExists(websiteServices, toString(selectedNum))>
                            <cfset updatedProjectInfo.project_type = websiteServices[toString(selectedNum)].type>
                            <cfset updatedProjectInfo.service_category = websiteServices[toString(selectedNum)].category>
                            <cfset updatedProjectInfo.service_type = websiteServices[toString(selectedNum)].service>
                            <cfset updatedProjectInfo.stage = "basic_info">
                        </cfif>
                    <cfelseif findNoCase("mobile", conversationText) OR findNoCase("app", conversationText)>
                        <cfset mobileServices = {
                            "1": {type: "mobile_app", category: "ios", service: "ios_app"},
                            "2": {type: "mobile_app", category: "android", service: "android_app"},
                            "3": {type: "mobile_app", category: "cross_platform", service: "cross_platform_app"},
                            "4": {type: "mobile_app", category: "game", service: "mobile_game"},
                            "5": {type: "mobile_app", category: "ecommerce", service: "ecommerce_app"},
                            "6": {type: "mobile_app", category: "enterprise", service: "enterprise_app"},
                            "7": {type: "mobile_app", category: "social", service: "social_app"},
                            "8": {type: "mobile_app", category: "utility", service: "utility_app"}
                        }>
                        <cfif structKeyExists(mobileServices, toString(selectedNum))>
                            <cfset updatedProjectInfo.project_type = mobileServices[toString(selectedNum)].type>
                            <cfset updatedProjectInfo.service_category = mobileServices[toString(selectedNum)].category>
                            <cfset updatedProjectInfo.service_type = mobileServices[toString(selectedNum)].service>
                            <cfset updatedProjectInfo.stage = "basic_info">
                        </cfif>
                    <cfelseif findNoCase("saas", conversationText) OR findNoCase("software", conversationText)>
                        <cfset saasServices = {
                            "1": {type: "saas", category: "project_management", service: "project_management_system"},
                            "2": {type: "saas", category: "crm", service: "crm_system"},
                            "3": {type: "saas", category: "analytics", service: "analytics_dashboard"},
                            "4": {type: "saas", category: "communication", service: "communication_platform"},
                            "5": {type: "saas", category: "accounting", service: "accounting_software"},
                            "6": {type: "saas", category: "custom", service: "custom_saas"}
                        }>
                        <cfif structKeyExists(saasServices, toString(selectedNum))>
                            <cfset updatedProjectInfo.project_type = saasServices[toString(selectedNum)].type>
                            <cfset updatedProjectInfo.service_category = saasServices[toString(selectedNum)].category>
                            <cfset updatedProjectInfo.service_type = saasServices[toString(selectedNum)].service>
                            <cfset updatedProjectInfo.stage = "basic_info">
                        </cfif>
                    </cfif>
                </cfif>
            </cfcase>
            
            <cfcase value="basic_info">
                <!--- Extract contact information from response --->
                <cfif NOT structKeyExists(updatedProjectInfo, "basicInfo")>
                    <cfset updatedProjectInfo.basicInfo = {}>
                </cfif>
                
                <!--- Look for company name (usually the first thing provided) --->
                <cfif findNoCase("company", aiResponse) OR findNoCase("organization", aiResponse)>
                    <cfset updatedProjectInfo.basicInfo.company = trim(userMessage)>
                <cfelseif findNoCase("industry", aiResponse) OR findNoCase("business type", aiResponse)>
                    <cfset updatedProjectInfo.basicInfo.industry = trim(userMessage)>
                <cfelseif findNoCase("name", aiResponse) AND findNoCase("first", aiResponse)>
                    <!--- Parse name --->
                    <cfset nameParts = listToArray(trim(userMessage), " ")>
                    <cfif arrayLen(nameParts) GTE 2>
                        <cfset updatedProjectInfo.basicInfo.first_name = nameParts[1]>
                        <cfset updatedProjectInfo.basicInfo.last_name = nameParts[arrayLen(nameParts)]>
                    </cfif>
                </cfif>
                
                <!--- Extract email if present --->
                <cfset emailPattern = "[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}">
                <cfset emailMatch = reFind(emailPattern, userMessage, 1, true)>
                <cfif emailMatch.pos[1] GT 0>
                    <cfset updatedProjectInfo.basicInfo.email = mid(userMessage, emailMatch.pos[1], emailMatch.len[1])>
                </cfif>
                
                <!--- Extract phone if present --->
                <cfset phonePattern = "[\d\s\-\(\)\.]+">
                <cfset phoneMatch = reFind(phonePattern, userMessage, 1, true)>
                <cfif phoneMatch.pos[1] GT 0 AND phoneMatch.len[1] GTE 7>
                    <cfset updatedProjectInfo.basicInfo.phone = trim(mid(userMessage, phoneMatch.pos[1], phoneMatch.len[1]))>
                </cfif>
                
                <!--- Check if we have enough info to move to next stage --->
                <cfif structKeyExists(updatedProjectInfo.basicInfo, "email") AND 
                      structKeyExists(updatedProjectInfo.basicInfo, "phone")>
                    <cfset updatedProjectInfo.stage = "project_details">
                </cfif>
            </cfcase>
            
            <cfcase value="project_details">
                <cfif NOT structKeyExists(updatedProjectInfo, "projectDetails")>
                    <cfset updatedProjectInfo.projectDetails = {}>
                </cfif>
                
                <!--- Determine which info we're collecting based on AI response --->
                <cfif findNoCase("describe your project", aiResponse)>
                    <cfset updatedProjectInfo.projectDetails.description = userMessage>
                <cfelseif findNoCase("target audience", aiResponse)>
                    <cfset updatedProjectInfo.projectDetails.audience = userMessage>
                <cfelseif findNoCase("main goals", aiResponse)>
                    <cfset updatedProjectInfo.projectDetails.objectives = userMessage>
                <cfelseif findNoCase("competitors", aiResponse) OR findNoCase("inspiration", aiResponse)>
                    <cfset updatedProjectInfo.projectDetails.competitors = userMessage>
                </cfif>
                
                <!--- Check if we have enough to move on --->
                <cfif structKeyExists(updatedProjectInfo.projectDetails, "description") AND
                      structKeyExists(updatedProjectInfo.projectDetails, "audience") AND
                      structKeyExists(updatedProjectInfo.projectDetails, "objectives")>
                    <cfset updatedProjectInfo.stage = "design_features">
                </cfif>
            </cfcase>
            
            <cfcase value="design_features">
                <cfif NOT structKeyExists(updatedProjectInfo, "designFeatures")>
                    <cfset updatedProjectInfo.designFeatures = {}>
                </cfif>
                <!--- Look for color mentions --->
                <cfset colors = ["blue", "green", "red", "purple", "orange", "yellow", "pink", "gray", "black", "white"]>
                <cfset selectedColors = []>
                <cfloop array="#colors#" index="color">
                    <cfif findNoCase(color, userMessage)>
                        <cfset arrayAppend(selectedColors, color)>
                    </cfif>
                </cfloop>
                <cfif arrayLen(selectedColors) GT 0>
                    <cfset updatedProjectInfo.designFeatures.colors = selectedColors>
                </cfif>
                <cfset updatedProjectInfo.stage = "additional_info">
            </cfcase>
            
            <cfcase value="additional_info">
                <cfif NOT structKeyExists(updatedProjectInfo, "additionalInfo")>
                    <cfset updatedProjectInfo.additionalInfo = {}>
                </cfif>
                <cfset updatedProjectInfo.additionalInfo.requirements = userMessage>
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
    <cfelse>
        <!--- Error handling --->
        <cfset response = {
            "success": false,
            "error": "API call failed",
            "detail": httpResult.statusCode,
            "response": "I'm having trouble connecting right now. Please try again."
        }>
        <cfoutput>#serializeJSON(response)#</cfoutput>
    </cfif>
    
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