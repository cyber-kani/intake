<cfcomponent displayname="Database" output="false">
    
    <!--- Generate unique reference ID --->
    <cffunction name="generateReferenceId" access="private" returntype="string" output="false">
        <cfset var chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789">
        <cfset var refId = "">
        <cfset var isUnique = false>
        
        <cfloop condition="NOT isUnique">
            <!--- Generate 8 character ID --->
            <cfset refId = "">
            <cfloop from="1" to="8" index="i">
                <cfset refId &= mid(chars, randRange(1, len(chars)), 1)>
            </cfloop>
            
            <!--- Check if unique --->
            <cfquery name="qCheck" datasource="clitools">
                SELECT COUNT(*) as cnt
                FROM IntakeForms
                WHERE reference_id = <cfqueryparam value="#refId#" cfsqltype="cf_sql_varchar">
            </cfquery>
            
            <cfif qCheck.cnt EQ 0>
                <cfset isUnique = true>
            </cfif>
        </cfloop>
        
        <!--- Log for debugging --->
        <cflog file="reference-id-generation" text="Generated reference ID: #refId#">
        
        <cfreturn refId>
    </cffunction>
    
    <!--- Get user by Google ID --->
    <cffunction name="getUserByGoogleId" access="public" returntype="query" output="false">
        <cfargument name="googleId" type="string" required="true">
        
        <cfquery name="qUser" datasource="clitools">
            SELECT user_id, google_id, email, display_name, profile_picture, created_at, last_login
            FROM Users
            WHERE google_id = <cfqueryparam value="#arguments.googleId#" cfsqltype="cf_sql_varchar">
        </cfquery>
        
        <cfreturn qUser>
    </cffunction>
    
    <!--- Create new user --->
    <cffunction name="createUser" access="public" returntype="numeric" output="false">
        <cfargument name="googleId" type="string" required="true">
        <cfargument name="email" type="string" required="true">
        <cfargument name="displayName" type="string" required="true">
        <cfargument name="profilePicture" type="string" required="false" default="">
        
        <cfquery name="qInsert" datasource="clitools" result="result">
            INSERT INTO Users (google_id, email, display_name, profile_picture, last_login)
            VALUES (
                <cfqueryparam value="#arguments.googleId#" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="#arguments.email#" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="#arguments.displayName#" cfsqltype="cf_sql_nvarchar">,
                <cfqueryparam value="#arguments.profilePicture#" cfsqltype="cf_sql_varchar">,
                GETDATE()
            )
        </cfquery>
        
        <cfreturn result.identitycol>
    </cffunction>
    
    <!--- Update user last login --->
    <cffunction name="updateLastLogin" access="public" returntype="void" output="false">
        <cfargument name="userId" type="numeric" required="true">
        
        <cfquery datasource="clitools">
            UPDATE Users
            SET last_login = GETDATE()
            WHERE user_id = <cfqueryparam value="#arguments.userId#" cfsqltype="cf_sql_integer">
        </cfquery>
    </cffunction>
    
    <!--- Get user forms --->
    <cffunction name="getUserForms" access="public" returntype="query" output="false">
        <cfargument name="userId" type="numeric" required="true">
        
        <cfquery name="qForms" datasource="clitools">
            SELECT form_id, form_code, reference_id, service_type, first_name, last_name, email, 
                   is_finalized, created_at, submitted_at, form_data
            FROM IntakeForms
            WHERE user_id = <cfqueryparam value="#arguments.userId#" cfsqltype="cf_sql_integer">
            ORDER BY created_at DESC
        </cfquery>
        
        <cfreturn qForms>
    </cffunction>
    
    <!--- Get form by ID --->
    <cffunction name="getFormById" access="public" returntype="query" output="false">
        <cfargument name="formId" type="numeric" required="true">
        <cfargument name="userId" type="numeric" required="true">
        
        <cfquery name="qForm" datasource="clitools">
            SELECT *
            FROM IntakeForms
            WHERE form_id = <cfqueryparam value="#arguments.formId#" cfsqltype="cf_sql_integer">
              AND user_id = <cfqueryparam value="#arguments.userId#" cfsqltype="cf_sql_integer">
        </cfquery>
        
        <cfreturn qForm>
    </cffunction>
    
    <!--- Get form by Reference ID --->
    <cffunction name="getFormByReferenceId" access="public" returntype="query" output="false">
        <cfargument name="referenceId" type="string" required="true">
        <cfargument name="userId" type="numeric" required="true">
        
        <cfquery name="qForm" datasource="clitools">
            SELECT *
            FROM IntakeForms
            WHERE reference_id = <cfqueryparam value="#arguments.referenceId#" cfsqltype="cf_sql_varchar">
              AND user_id = <cfqueryparam value="#arguments.userId#" cfsqltype="cf_sql_integer">
        </cfquery>
        
        <cfreturn qForm>
    </cffunction>
    
    <!--- Get form by Form Code --->
    <cffunction name="getFormByCode" access="public" returntype="query" output="false">
        <cfargument name="formCode" type="string" required="true">
        <cfargument name="userId" type="numeric" required="false" default="0">
        
        <cfquery name="qForm" datasource="clitools">
            SELECT *
            FROM IntakeForms
            WHERE reference_id = <cfqueryparam value="#arguments.formCode#" cfsqltype="cf_sql_varchar">
            <cfif arguments.userId GT 0>
                AND user_id = <cfqueryparam value="#arguments.userId#" cfsqltype="cf_sql_integer">
            </cfif>
        </cfquery>
        
        <cfreturn qForm>
    </cffunction>
    
    <!--- Create new form --->
    <cffunction name="createForm" access="public" returntype="numeric" output="false">
        <cfargument name="formData" type="struct" required="true">
        <cfargument name="userId" type="numeric" required="true">
        
        <!--- Generate unique reference ID --->
        <cfset var referenceId = generateReferenceId()>
        
        <!--- Log the reference ID generation --->
        <cflog file="intake-debug" text="Creating new form with reference_id: #referenceId# for user: #arguments.userId#">
        
        <cfquery name="qInsert" datasource="clitools" result="result">
            INSERT INTO IntakeForms (
                user_id, reference_id, project_type, service_type, first_name, last_name,
                phone_number, email, company_name,
                form_data
            ) VALUES (
                <cfqueryparam value="#arguments.userId#" cfsqltype="cf_sql_integer">,
                <cfqueryparam value="#referenceId#" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="#arguments.formData.project_type#" cfsqltype="cf_sql_varchar" null="#NOT structKeyExists(arguments.formData, 'project_type') OR len(trim(arguments.formData.project_type)) EQ 0#">,
                <cfqueryparam value="#arguments.formData.service_type#" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="#arguments.formData.first_name#" cfsqltype="cf_sql_nvarchar">,
                <cfqueryparam value="#arguments.formData.last_name#" cfsqltype="cf_sql_nvarchar">,
                <cfqueryparam value="#arguments.formData.phone_number#" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="#arguments.formData.email#" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="#arguments.formData.company_name#" cfsqltype="cf_sql_nvarchar" null="#NOT structKeyExists(arguments.formData, 'company_name') OR len(trim(arguments.formData.company_name)) EQ 0#">,
                <cfqueryparam value="#serializeJSON(arguments.formData)#" cfsqltype="cf_sql_nvarchar">
            )
        </cfquery>
        
        <!--- Verify the reference_id was saved --->
        <cfquery name="qVerify" datasource="clitools">
            SELECT reference_id
            FROM IntakeForms
            WHERE form_id = <cfqueryparam value="#result.identitycol#" cfsqltype="cf_sql_integer">
        </cfquery>
        
        <cflog file="intake-debug" text="Created form_id: #result.identitycol#, reference_id in DB: #qVerify.reference_id#">
        
        <cfreturn result.identitycol>
    </cffunction>
    
    <!--- Update form --->
    <cffunction name="updateForm" access="public" returntype="void" output="false">
        <cfargument name="formId" type="numeric" required="true">
        <cfargument name="formData" type="struct" required="true">
        <cfargument name="userId" type="numeric" required="true">
        
        <!--- First check if this form has a reference_id --->
        <cfquery name="qCheckRef" datasource="clitools">
            SELECT reference_id
            FROM IntakeForms
            WHERE form_id = <cfqueryparam value="#arguments.formId#" cfsqltype="cf_sql_integer">
        </cfquery>
        
        <!--- If no reference_id, generate one --->
        <cfif NOT len(trim(qCheckRef.reference_id))>
            <cfset var referenceId = generateReferenceId()>
            <cfquery datasource="clitools">
                UPDATE IntakeForms
                SET reference_id = <cfqueryparam value="#referenceId#" cfsqltype="cf_sql_varchar">
                WHERE form_id = <cfqueryparam value="#arguments.formId#" cfsqltype="cf_sql_integer">
            </cfquery>
        </cfif>
        
        <cfquery datasource="clitools">
            UPDATE IntakeForms
            SET project_type = <cfqueryparam value="#arguments.formData.project_type#" cfsqltype="cf_sql_varchar" null="#NOT structKeyExists(arguments.formData, 'project_type') OR len(trim(arguments.formData.project_type)) EQ 0#">,
                service_type = <cfqueryparam value="#arguments.formData.service_type#" cfsqltype="cf_sql_varchar">,
                first_name = <cfqueryparam value="#arguments.formData.first_name#" cfsqltype="cf_sql_nvarchar">,
                last_name = <cfqueryparam value="#arguments.formData.last_name#" cfsqltype="cf_sql_nvarchar">,
                phone_number = <cfqueryparam value="#arguments.formData.phone_number#" cfsqltype="cf_sql_varchar">,
                email = <cfqueryparam value="#arguments.formData.email#" cfsqltype="cf_sql_varchar">,
                company_name = <cfqueryparam value="#arguments.formData.company_name#" cfsqltype="cf_sql_nvarchar" null="#NOT structKeyExists(arguments.formData, 'company_name') OR len(trim(arguments.formData.company_name)) EQ 0#">,
                form_data = <cfqueryparam value="#serializeJSON(arguments.formData)#" cfsqltype="cf_sql_nvarchar">,
                updated_at = GETDATE()
            WHERE form_id = <cfqueryparam value="#arguments.formId#" cfsqltype="cf_sql_integer">
              AND user_id = <cfqueryparam value="#arguments.userId#" cfsqltype="cf_sql_integer">
              AND is_finalized = 0
        </cfquery>
    </cffunction>
    
    <!--- Finalize form --->
    <cffunction name="finalizeForm" access="public" returntype="void" output="false">
        <cfargument name="formId" type="numeric" required="true">
        <cfargument name="userId" type="numeric" required="true">
        
        <!--- First check if this form has a reference_id --->
        <cfquery name="qCheckRef" datasource="clitools">
            SELECT reference_id
            FROM IntakeForms
            WHERE form_id = <cfqueryparam value="#arguments.formId#" cfsqltype="cf_sql_integer">
        </cfquery>
        
        <!--- If no reference_id, generate one --->
        <cfif NOT len(trim(qCheckRef.reference_id))>
            <cfset var referenceId = generateReferenceId()>
            <cfquery datasource="clitools">
                UPDATE IntakeForms
                SET reference_id = <cfqueryparam value="#referenceId#" cfsqltype="cf_sql_varchar">
                WHERE form_id = <cfqueryparam value="#arguments.formId#" cfsqltype="cf_sql_integer">
            </cfquery>
        </cfif>
        
        <cfquery datasource="clitools">
            UPDATE IntakeForms
            SET is_finalized = 1,
                submitted_at = GETDATE(),
                updated_at = GETDATE()
            WHERE form_id = <cfqueryparam value="#arguments.formId#" cfsqltype="cf_sql_integer">
              AND user_id = <cfqueryparam value="#arguments.userId#" cfsqltype="cf_sql_integer">
              AND is_finalized = 0
        </cfquery>
    </cffunction>
    
    <!--- Delete form (admin only) --->
    <cffunction name="deleteForm" access="public" returntype="boolean" output="false">
        <cfargument name="formId" type="numeric" required="true">
        
        <cftry>
            <cfquery datasource="clitools">
                DELETE FROM IntakeForms
                WHERE form_id = <cfqueryparam value="#arguments.formId#" cfsqltype="cf_sql_integer">
            </cfquery>
            
            <cfreturn true>
            
            <cfcatch>
                <cfreturn false>
            </cfcatch>
        </cftry>
    </cffunction>
    
</cfcomponent>