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

<cftry>
    <!--- Test without session check --->
    <cfset requestData = getHTTPRequestData()>
    <cfset jsonData = deserializeJSON(toString(requestData.content))>
    
    <cfset response = {
        "success": true,
        "response": "Test response - your message was: #jsonData.message#",
        "projectInfo": jsonData.projectInfo,
        "conversationHistory": [
            {"role": "user", "content": jsonData.message},
            {"role": "assistant", "content": "Test response - your message was: #jsonData.message#"}
        ],
        "isComplete": false
    }>
    
    <cfoutput>#serializeJSON(response)#</cfoutput>
    
    <cfcatch>
        <cfset response = {
            "success": false,
            "error": cfcatch.message,
            "line": structKeyExists(cfcatch, "tagcontext") AND arrayLen(cfcatch.tagcontext) ? cfcatch.tagcontext[1].line : ""
        }>
        <cfoutput>#serializeJSON(response)#</cfoutput>
    </cfcatch>
</cftry>