<!--- Check form 41 --->
<cfquery name="qCheck" datasource="clitools">
    SELECT form_id, reference_id, created_at, updated_at, is_finalized
    FROM IntakeForms
    WHERE form_id >= 38
    ORDER BY form_id DESC
</cfquery>

<cfoutput>
<h3>Recent Forms</h3>
<table border="1" cellpadding="5">
    <tr>
        <th>Form ID</th>
        <th>Reference ID</th>
        <th>Created</th>
        <th>Updated</th>
        <th>Finalized</th>
    </tr>
    <cfloop query="qCheck">
    <tr>
        <td>#qCheck.form_id#</td>
        <td><cfif len(qCheck.reference_id)>#qCheck.reference_id#<cfelse><strong>MISSING</strong></cfif></td>
        <td>#dateFormat(qCheck.created_at, "mm/dd/yyyy hh:nn")#</td>
        <td><cfif isDate(qCheck.updated_at)>#dateFormat(qCheck.updated_at, "mm/dd/yyyy hh:nn")#<cfelse>-</cfif></td>
        <td>#yesNoFormat(qCheck.is_finalized)#</td>
    </tr>
    </cfloop>
</table>
</cfoutput>