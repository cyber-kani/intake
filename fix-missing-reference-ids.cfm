<!--- Fix missing reference IDs --->
<cfset db = createObject("component", "components.Database")>

<cfquery name="qMissing" datasource="clitools">
    SELECT form_id
    FROM IntakeForms
    WHERE reference_id IS NULL OR reference_id = ''
</cfquery>

<cfoutput>
<h3>Fixing missing reference IDs...</h3>
<p>Found #qMissing.recordCount# forms without reference IDs</p>
</cfoutput>

<cfloop query="qMissing">
    <!--- Generate unique reference ID --->
    <cfset chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789">
    <cfset refId = "">
    <cfset isUnique = false>
    
    <cfloop condition="NOT isUnique">
        <cfset refId = "">
        <cfloop from="1" to="8" index="i">
            <cfset refId = refId & mid(chars, randRange(1, len(chars)), 1)>
        </cfloop>
        
        <!--- Check if this ID already exists --->
        <cfquery name="qCheck" datasource="clitools">
            SELECT COUNT(*) as idCount
            FROM IntakeForms
            WHERE reference_id = <cfqueryparam value="#refId#" cfsqltype="cf_sql_varchar">
        </cfquery>
        
        <cfif qCheck.idCount EQ 0>
            <cfset isUnique = true>
        </cfif>
    </cfloop>
    
    <!--- Update the form with the new reference ID --->
    <cfquery datasource="clitools">
        UPDATE IntakeForms
        SET reference_id = <cfqueryparam value="#refId#" cfsqltype="cf_sql_varchar">
        WHERE form_id = <cfqueryparam value="#qMissing.form_id#" cfsqltype="cf_sql_integer">
    </cfquery>
    
    <cfoutput>
    <p>Updated form #qMissing.form_id# with reference ID: #refId#</p>
    </cfoutput>
</cfloop>

<cfoutput>
<p><strong>Done!</strong> All forms now have reference IDs.</p>
<p><a href="dashboard.cfm">Back to Dashboard</a></p>
</cfoutput>