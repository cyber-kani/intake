<cftry>
    <!--- Check if column exists --->
    <cfquery name="qCheck" datasource="clitools">
        SELECT COUNT(*) as cnt
        FROM INFORMATION_SCHEMA.COLUMNS
        WHERE TABLE_NAME = 'IntakeForms'
        AND COLUMN_NAME = 'reference_id'
    </cfquery>
    
    <cfif qCheck.cnt GT 0>
        <cfoutput>Column EXISTS!</cfoutput>
    <cfelse>
        <cfoutput>Column DOES NOT exist</cfoutput>
    </cfif>
    
    <cfcatch>
        <cfoutput>ERROR: #cfcatch.message#</cfoutput>
    </cfcatch>
</cftry>