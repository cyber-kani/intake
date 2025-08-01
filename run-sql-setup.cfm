<cfsetting showdebugoutput="false">
<cfheader name="Content-Type" value="text/plain">

<!--- Security check - only run from localhost --->
<cfif cgi.remote_addr NEQ "127.0.0.1" AND cgi.remote_addr NEQ "::1">
    <cfoutput>Access denied. This script can only be run from localhost.</cfoutput>
    <cfabort>
</cfif>

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
        <cfoutput>Added reference_id column
</cfoutput>
        
        <!--- Create index --->
        <cfquery datasource="clitools">
            CREATE INDEX idx_reference_id ON IntakeForms(reference_id)
        </cfquery>
        <cfoutput>Created index on reference_id
</cfoutput>
    <cfelse>
        <cfoutput>reference_id column already exists
</cfoutput>
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
        <cfoutput>Updated #qMissing.recordCount# existing records with reference IDs
</cfoutput>
    <cfelse>
        <cfoutput>All records already have reference IDs
</cfoutput>
    </cfif>
    
    <cfoutput>Setup complete!</cfoutput>
    
    <cfcatch>
        <cfoutput>Error: #cfcatch.message#
#cfcatch.detail#</cfoutput>
    </cfcatch>
</cftry>