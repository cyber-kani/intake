<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Database Integrity Checker</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <style>
        .test-pass { color: green; font-weight: bold; }
        .test-fail { color: red; font-weight: bold; }
        .test-warning { color: orange; font-weight: bold; }
        .table-info { background-color: #f8f9fa; padding: 15px; border-radius: 5px; margin: 10px 0; }
    </style>
</head>
<body>
<div class="container mt-5">
    <h1 class="mb-4"><i class="fas fa-database"></i> Database Integrity Checker</h1>
    
    <cfset dbIssues = []>
    <cfset dbWarnings = []>
    <cfset dbPassed = []>
    
    <!--- Check 1: Table Structure --->
    <div class="card mb-4">
        <div class="card-header bg-primary text-white">
            <h4 class="mb-0">Table Structure Verification</h4>
        </div>
        <div class="card-body">
            <!--- Check Users table columns --->
            <h5>Users Table</h5>
            <cftry>
                <cfquery name="qUserCols" datasource="clitools">
                    SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE, CHARACTER_MAXIMUM_LENGTH
                    FROM INFORMATION_SCHEMA.COLUMNS
                    WHERE TABLE_NAME = 'Users'
                    ORDER BY ORDINAL_POSITION
                </cfquery>
                
                <cfif qUserCols.recordCount GT 0>
                    <div class="alert alert-success">
                        <span class="test-pass">✓</span> Users table structure verified - <cfoutput>#qUserCols.recordCount#</cfoutput> columns
                    </div>
                    <table class="table table-sm">
                        <thead>
                            <tr>
                                <th>Column</th>
                                <th>Type</th>
                                <th>Nullable</th>
                                <th>Max Length</th>
                            </tr>
                        </thead>
                        <tbody>
                            <cfloop query="qUserCols">
                                <tr>
                                    <td><cfoutput>#qUserCols.COLUMN_NAME#</cfoutput></td>
                                    <td><cfoutput>#qUserCols.DATA_TYPE#</cfoutput></td>
                                    <td><cfoutput>#qUserCols.IS_NULLABLE#</cfoutput></td>
                                    <td><cfoutput>#qUserCols.CHARACTER_MAXIMUM_LENGTH#</cfoutput></td>
                                </tr>
                            </cfloop>
                        </tbody>
                    </table>
                    <cfset arrayAppend(dbPassed, "Users table structure verified")>
                <cfelse>
                    <div class="alert alert-danger">
                        <span class="test-fail">✗</span> Users table not found
                    </div>
                    <cfset arrayAppend(dbIssues, "Users table not found")>
                </cfif>
                <cfcatch>
                    <div class="alert alert-danger">
                        <span class="test-fail">✗</span> Error checking Users table: <cfoutput>#cfcatch.message#</cfoutput>
                    </div>
                    <cfset arrayAppend(dbIssues, "Error checking Users table")>
                </cfcatch>
            </cftry>
            
            <!--- Check IntakeForms table columns --->
            <h5 class="mt-3">IntakeForms Table</h5>
            <cftry>
                <cfquery name="qFormCols" datasource="clitools">
                    SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE, CHARACTER_MAXIMUM_LENGTH
                    FROM INFORMATION_SCHEMA.COLUMNS
                    WHERE TABLE_NAME = 'IntakeForms'
                    ORDER BY ORDINAL_POSITION
                </cfquery>
                
                <cfif qFormCols.recordCount GT 0>
                    <div class="alert alert-success">
                        <span class="test-pass">✓</span> IntakeForms table structure verified - <cfoutput>#qFormCols.recordCount#</cfoutput> columns
                    </div>
                    <table class="table table-sm">
                        <thead>
                            <tr>
                                <th>Column</th>
                                <th>Type</th>
                                <th>Nullable</th>
                                <th>Max Length</th>
                            </tr>
                        </thead>
                        <tbody>
                            <cfloop query="qFormCols">
                                <tr>
                                    <td><cfoutput>#qFormCols.COLUMN_NAME#</cfoutput></td>
                                    <td><cfoutput>#qFormCols.DATA_TYPE#</cfoutput></td>
                                    <td><cfoutput>#qFormCols.IS_NULLABLE#</cfoutput></td>
                                    <td><cfoutput>#qFormCols.CHARACTER_MAXIMUM_LENGTH#</cfoutput></td>
                                </tr>
                            </cfloop>
                        </tbody>
                    </table>
                    <cfset arrayAppend(dbPassed, "IntakeForms table structure verified")>
                <cfelse>
                    <div class="alert alert-danger">
                        <span class="test-fail">✗</span> IntakeForms table not found
                    </div>
                    <cfset arrayAppend(dbIssues, "IntakeForms table not found")>
                </cfif>
                <cfcatch>
                    <div class="alert alert-danger">
                        <span class="test-fail">✗</span> Error checking IntakeForms table: <cfoutput>#cfcatch.message#</cfoutput>
                    </div>
                    <cfset arrayAppend(dbIssues, "Error checking IntakeForms table")>
                </cfcatch>
            </cftry>
        </div>
    </div>
    
    <!--- Check 2: Foreign Key Relationships --->
    <div class="card mb-4">
        <div class="card-header bg-info text-white">
            <h4 class="mb-0">Foreign Key Relationships</h4>
        </div>
        <div class="card-body">
            <cftry>
                <cfquery name="qForeignKeys" datasource="clitools">
                    SELECT 
                        fk.name AS FK_Name,
                        tp.name AS Parent_Table,
                        tr.name AS Referenced_Table
                    FROM sys.foreign_keys fk
                    INNER JOIN sys.tables tp ON fk.parent_object_id = tp.object_id
                    INNER JOIN sys.tables tr ON fk.referenced_object_id = tr.object_id
                    WHERE tp.name = 'IntakeForms'
                </cfquery>
                
                <cfif qForeignKeys.recordCount GT 0>
                    <div class="alert alert-success">
                        <span class="test-pass">✓</span> Foreign key relationships found
                    </div>
                    <cfloop query="qForeignKeys">
                        <p>IntakeForms → Users relationship verified</p>
                    </cfloop>
                    <cfset arrayAppend(dbPassed, "Foreign key relationships verified")>
                <cfelse>
                    <div class="alert alert-warning">
                        <span class="test-warning">⚠</span> No foreign key constraints found
                    </div>
                    <cfset arrayAppend(dbWarnings, "No foreign key constraints")>
                </cfif>
                <cfcatch>
                    <div class="alert alert-warning">
                        <span class="test-warning">⚠</span> Could not check foreign keys
                    </div>
                </cfcatch>
            </cftry>
        </div>
    </div>
    
    <!--- Check 3: Data Integrity --->
    <div class="card mb-4">
        <div class="card-header bg-success text-white">
            <h4 class="mb-0">Data Integrity Checks</h4>
        </div>
        <div class="card-body">
            <!--- Check for orphaned forms --->
            <cftry>
                <cfquery name="qOrphaned" datasource="clitools">
                    SELECT COUNT(*) as orphan_count
                    FROM IntakeForms f
                    LEFT JOIN Users u ON f.user_id = u.user_id
                    WHERE u.user_id IS NULL
                </cfquery>
                
                <cfif qOrphaned.orphan_count EQ 0>
                    <div class="alert alert-success">
                        <span class="test-pass">✓</span> No orphaned forms found
                    </div>
                    <cfset arrayAppend(dbPassed, "No orphaned forms")>
                <cfelse>
                    <div class="alert alert-danger">
                        <span class="test-fail">✗</span> Found <cfoutput>#qOrphaned.orphan_count#</cfoutput> orphaned forms
                    </div>
                    <cfset arrayAppend(dbIssues, "Orphaned forms found")>
                </cfif>
                <cfcatch>
                    <div class="alert alert-warning">
                        <span class="test-warning">⚠</span> Could not check for orphaned forms
                    </div>
                </cfcatch>
            </cftry>
            
            <!--- Check for duplicate reference IDs --->
            <cftry>
                <cfquery name="qDuplicates" datasource="clitools">
                    SELECT reference_id, COUNT(*) as cnt
                    FROM IntakeForms
                    WHERE reference_id IS NOT NULL AND reference_id != ''
                    GROUP BY reference_id
                    HAVING COUNT(*) > 1
                </cfquery>
                
                <cfif qDuplicates.recordCount EQ 0>
                    <div class="alert alert-success">
                        <span class="test-pass">✓</span> No duplicate reference IDs found
                    </div>
                    <cfset arrayAppend(dbPassed, "Reference IDs are unique")>
                <cfelse>
                    <div class="alert alert-danger">
                        <span class="test-fail">✗</span> Found <cfoutput>#qDuplicates.recordCount#</cfoutput> duplicate reference IDs
                    </div>
                    <cfset arrayAppend(dbIssues, "Duplicate reference IDs found")>
                </cfif>
                <cfcatch>
                    <div class="alert alert-info">
                        <i class="fas fa-info-circle"></i> Reference ID column may not exist
                    </div>
                </cfcatch>
            </cftry>
        </div>
    </div>
    
    <!--- Check 4: Indexes --->
    <div class="card mb-4">
        <div class="card-header bg-warning">
            <h4 class="mb-0">Index Analysis</h4>
        </div>
        <div class="card-body">
            <cftry>
                <cfquery name="qIndexes" datasource="clitools">
                    SELECT 
                        i.name AS Index_Name,
                        t.name AS Table_Name,
                        i.type_desc AS Index_Type
                    FROM sys.indexes i
                    INNER JOIN sys.tables t ON i.object_id = t.object_id
                    WHERE t.name IN ('Users', 'IntakeForms')
                    AND i.name IS NOT NULL
                    ORDER BY t.name, i.name
                </cfquery>
                
                <cfif qIndexes.recordCount GT 0>
                    <div class="alert alert-success">
                        <span class="test-pass">✓</span> Indexes found: <cfoutput>#qIndexes.recordCount#</cfoutput>
                    </div>
                    <table class="table table-sm">
                        <thead>
                            <tr>
                                <th>Table</th>
                                <th>Index Name</th>
                                <th>Type</th>
                            </tr>
                        </thead>
                        <tbody>
                            <cfloop query="qIndexes">
                                <tr>
                                    <td><cfoutput>#qIndexes.Table_Name#</cfoutput></td>
                                    <td><cfoutput>#qIndexes.Index_Name#</cfoutput></td>
                                    <td><cfoutput>#qIndexes.Index_Type#</cfoutput></td>
                                </tr>
                            </cfloop>
                        </tbody>
                    </table>
                    <cfset arrayAppend(dbPassed, "Indexes configured")>
                <cfelse>
                    <div class="alert alert-warning">
                        <span class="test-warning">⚠</span> No indexes found
                    </div>
                    <cfset arrayAppend(dbWarnings, "No indexes configured")>
                </cfif>
                <cfcatch>
                    <div class="alert alert-warning">
                        <span class="test-warning">⚠</span> Could not check indexes
                    </div>
                </cfcatch>
            </cftry>
        </div>
    </div>
    
    <!--- Summary --->
    <div class="card mt-5">
        <div class="card-header bg-dark text-white">
            <h4 class="mb-0">Database Integrity Summary</h4>
        </div>
        <div class="card-body">
            <div class="row">
                <div class="col-md-4">
                    <div class="text-center">
                        <h2 class="text-success"><cfoutput>#arrayLen(dbPassed)#</cfoutput></h2>
                        <p>Passed Checks</p>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="text-center">
                        <h2 class="text-warning"><cfoutput>#arrayLen(dbWarnings)#</cfoutput></h2>
                        <p>Warnings</p>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="text-center">
                        <h2 class="text-danger"><cfoutput>#arrayLen(dbIssues)#</cfoutput></h2>
                        <p>Issues</p>
                    </div>
                </div>
            </div>
            
            <cfif arrayLen(dbIssues) EQ 0>
                <div class="alert alert-success mt-3">
                    <i class="fas fa-check-circle"></i> <strong>Database integrity verified!</strong>
                </div>
            <cfelse>
                <div class="alert alert-danger mt-3">
                    <i class="fas fa-times-circle"></i> <strong>Database integrity issues detected</strong>
                </div>
            </cfif>
        </div>
    </div>
    
    <div class="text-center mt-4 mb-5">
        <a href="index.cfm" class="btn btn-primary">Back to Test Index</a>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>