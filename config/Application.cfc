<cfcomponent output="false">
    <!--- 
        Security Component for Config Directory
        This prevents direct access to configuration files via HTTP
    --->
    
    <cffunction name="onRequestStart" returnType="boolean" output="false">
        <cfargument name="targetPage" type="string" required="true">
        
        <!--- Block all direct access to this directory --->
        <cfheader statuscode="403" statustext="Forbidden">
        <cfcontent type="text/html">
        <cfoutput>
        <!DOCTYPE html>
        <html>
        <head>
            <title>403 Forbidden</title>
        </head>
        <body>
            <h1>403 Forbidden</h1>
            <p>Access to this directory is forbidden.</p>
        </body>
        </html>
        </cfoutput>
        <cfabort>
        
        <cfreturn false>
    </cffunction>
    
    <cffunction name="onRequest" returnType="void" output="true">
        <cfargument name="targetPage" type="string" required="true">
        <!--- This should never execute due to onRequestStart blocking --->
        <cfabort>
    </cffunction>
</cfcomponent>