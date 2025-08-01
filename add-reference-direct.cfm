<!--- Direct SQL execution to add reference_id column --->
<cftry>
    <!--- Add the column --->
    <cfquery datasource="clitools">
        ALTER TABLE IntakeForms ADD reference_id VARCHAR(8)
    </cfquery>
    
    <cfoutput>SUCCESS: Added reference_id column<br></cfoutput>
    
    <!--- Create index --->
    <cfquery datasource="clitools">
        CREATE INDEX idx_reference_id ON IntakeForms(reference_id)
    </cfquery>
    
    <cfoutput>SUCCESS: Created index on reference_id<br></cfoutput>
    
    <!--- Update existing records --->
    <cfquery datasource="clitools">
        UPDATE IntakeForms 
        SET reference_id = LEFT(REPLACE(NEWID(), '-', ''), 8)
        WHERE reference_id IS NULL
    </cfquery>
    
    <cfoutput>SUCCESS: Updated existing records with reference IDs<br></cfoutput>
    
    <cfoutput><h3>All done! Reference ID column has been added.</h3></cfoutput>
    
    <cfcatch>
        <cfoutput>
            ERROR: #cfcatch.message#<br>
            Detail: #cfcatch.detail#
        </cfoutput>
    </cfcatch>
</cftry>