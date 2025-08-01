<!--- Add form_code field --->
<cftry>
    <cfquery datasource="clitools">
        ALTER TABLE IntakeForms ADD form_code VARCHAR(8)
    </cfquery>
    <cfoutput>Added form_code field<br></cfoutput>
    
    <!--- Generate codes for existing forms --->
    <cfquery name="qForms" datasource="clitools">
        SELECT form_id FROM IntakeForms WHERE form_code IS NULL
    </cfquery>
    
    <cfloop query="qForms">
        <cfset code = "">
        <cfset chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789">
        <cfloop from="1" to="8" index="i">
            <cfset code &= mid(chars, randRange(1, len(chars)), 1)>
        </cfloop>
        
        <cfquery datasource="clitools">
            UPDATE IntakeForms 
            SET form_code = <cfqueryparam value="#code#" cfsqltype="cf_sql_varchar">
            WHERE form_id = <cfqueryparam value="#qForms.form_id#" cfsqltype="cf_sql_integer">
        </cfquery>
    </cfloop>
    
    <cfoutput>Updated #qForms.recordCount# forms with codes</cfoutput>
    
    <cfcatch>
        <cfoutput>Error: #cfcatch.message#</cfoutput>
    </cfcatch>
</cftry>