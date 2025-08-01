<!DOCTYPE html>
<html lang="en" class="h-100">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Customer Intake Form</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <link href="<cfoutput>#application.basePath#</cfoutput>/css/style.css" rel="stylesheet">
    <style>
        body {
            min-height: 100vh;
            display: flex;
            flex-direction: column;
        }
        main {
            flex: 1 0 auto;
        }
        .footer {
            flex-shrink: 0;
        }
    </style>
</head>
<body class="d-flex flex-column h-100">
    <nav class="navbar navbar-expand-lg navbar-dark bg-primary">
        <div class="container">
            <a class="navbar-brand" href="<cfoutput>#application.basePath#</cfoutput>/dashboard.cfm">
                <i class="fas fa-clipboard-list"></i> Customer Intake Portal
            </a>
            <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
                <span class="navbar-toggler-icon"></span>
            </button>
            <div class="collapse navbar-collapse" id="navbarNav">
                <ul class="navbar-nav ms-auto">
                    <cfif session.isLoggedIn>
                        <li class="nav-item">
                            <a class="nav-link" href="<cfoutput>#application.basePath#</cfoutput>/dashboard.cfm">
                                <i class="fas fa-folder"></i> My Forms
                            </a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" href="<cfoutput>#application.basePath#</cfoutput>/index.cfm?new=true">
                                <i class="fas fa-plus-circle"></i> New Form
                            </a>
                        </li>
                        <cfif structKeyExists(session, "user") AND structKeyExists(session.user, "email") AND listFindNoCase(arrayToList(application.adminEmails), session.user.email)>
                            <li class="nav-item">
                                <a class="nav-link" href="<cfoutput>#application.basePath#</cfoutput>/admin/">
                                    <i class="fas fa-user-shield"></i> Admin
                                </a>
                            </li>
                        </cfif>
                        <li class="nav-item dropdown">
                            <a class="nav-link dropdown-toggle" href="#" id="navbarDropdown" role="button" data-bs-toggle="dropdown">
                                <cfif len(session.user.profilePicture)>
                                    <img src="<cfoutput>#session.user.profilePicture#</cfoutput>" alt="Profile" class="rounded-circle" style="width: 25px; height: 25px; margin-right: 5px;">
                                <cfelse>
                                    <i class="fas fa-user-circle"></i>
                                </cfif>
                                <cfoutput>#session.user.displayName#</cfoutput>
                            </a>
                            <ul class="dropdown-menu dropdown-menu-end">
                                <li><a class="dropdown-item" href="<cfoutput>#application.basePath#</cfoutput>/logout.cfm">
                                    <i class="fas fa-sign-out-alt"></i> Logout
                                </a></li>
                            </ul>
                        </li>
                    <cfelse>
                        <li class="nav-item">
                            <a class="nav-link" href="<cfoutput>#application.basePath#</cfoutput>/login.cfm">
                                <i class="fab fa-google"></i> Sign in with Google
                            </a>
                        </li>
                    </cfif>
                </ul>
            </div>
        </div>
    </nav>

    <main>