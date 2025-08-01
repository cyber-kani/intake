<!--- Only allow admin access --->
<cfif NOT structKeyExists(session, "user") OR NOT structKeyExists(session.user, "email") OR 
      NOT listFindNoCase(arrayToList(application.adminEmails), session.user.email)>
    <cfoutput>Access denied. Admin only.</cfoutput>
    <cfabort>
</cfif>

<h2>Setting up Reference ID column</h2>

<cftry>
    <!--- Check if column exists --->
    <cfquery name="qCheck" datasource="clitools">
        SELECT COUNT(*) as cnt
        FROM INFORMATION_SCHEMA.COLUMNS
        WHERE TABLE_NAME = 'IntakeForms'
        AND COLUMN_NAME = 'reference_id'
    </cfquery>
    
    <cfif qCheck.cnt EQ 0>
        <!--- Add the column --->
        <cfquery datasource="clitools">
            ALTER TABLE IntakeForms ADD reference_id VARCHAR(8)
        </cfquery>
        <p>✓ Added reference_id column</p>
        
        <!--- Create index --->
        <cfquery datasource="clitools">
            CREATE INDEX idx_reference_id ON IntakeForms(reference_id)
        </cfquery>
        <p>✓ Created index on reference_id</p>
    <cfelse>
        <p>Reference ID column already exists</p>
    </cfif>
    
    <!--- Update existing records without reference_id --->
    <cfquery name="qMissing" datasource="clitools">
        SELECT form_id
        FROM IntakeForms
        WHERE reference_id IS NULL OR reference_id = ''
    </cfquery>
    
    <cfif qMissing.recordCount GT 0>
        <cfloop query="qMissing">
            <cfset refId = "">
            <cfset chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789">
            <cfloop from="1" to="8" index="i">
                <cfset refId &= mid(chars, randRange(1, len(chars)), 1)>
            </cfloop>
            
            <cfquery datasource="clitools">
                UPDATE IntakeForms
                SET reference_id = <cfqueryparam value="#refId#" cfsqltype="cf_sql_varchar">
                WHERE form_id = <cfqueryparam value="#qMissing.form_id#" cfsqltype="cf_sql_integer">
            </cfquery>
        </cfloop>
        <p>✓ Updated <cfoutput>#qMissing.recordCount#</cfoutput> existing records with reference IDs</p>
    <cfelse>
        <p>All records already have reference IDs</p>
    </cfif>
    
    <p><strong>Setup complete!</strong></p>
    
    <cfcatch>
        <p style="color: red;">Error: <cfoutput>#cfcatch.message#</cfoutput></p>
        <cfif structKeyExists(cfcatch, "detail")>
            <p style="color: red;">Detail: <cfoutput>#cfcatch.detail#</cfoutput></p>
        </cfif>
    </cfcatch>
</cftry>

<p><a href="<cfoutput>#application.basePath#</cfoutput>/dashboard.cfm">Back to Dashboard</a></p>