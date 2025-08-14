<cfcomponent output="false">
    <cfset this.name = "CustomerIntakeForm">
    <cfset this.applicationTimeout = createTimeSpan(1,0,0,0)>
    <cfset this.sessionManagement = true>
    <cfset this.sessionTimeout = createTimeSpan(0,0,30,0)>
    <cfset this.setClientCookies = true>
    <cfset this.scriptProtect = "all">
    
    <!--- Database settings --->
    <cfset this.datasource = "clitools">
    
    <cffunction name="onApplicationStart" returnType="boolean" output="false">
        <!--- Application settings --->
        <cfset application.basePath = "/intake">
        <cfset application.googleCallbackURL = "https://clitools.app/intake/auth/callback.cfm">
        <cfset application.claudeApiUrl = "https://api.anthropic.com/v1/messages">
        
        <!--- Load configuration from database --->
        <cftry>
            <!--- First try to load from database --->
            <cfquery name="qConfig" datasource="clitools">
                SELECT config_key, config_value 
                FROM AppConfig
            </cfquery>
            
            <!--- Set application variables from database --->
            <cfloop query="qConfig">
                <cfswitch expression="#config_key#">
                    <cfcase value="ANTHROPIC_API_KEY">
                        <cfset application.anthropicApiKey = config_value>
                        <cfset application.claudeApiKey = config_value>
                    </cfcase>
                    <cfcase value="GOOGLE_CLIENT_ID">
                        <cfset application.googleClientId = config_value>
                    </cfcase>
                    <cfcase value="GOOGLE_CLIENT_SECRET">
                        <cfset application.googleClientSecret = config_value>
                    </cfcase>
                    <cfcase value="GOOGLE_API_KEY">
                        <cfset application.googleApiKey = config_value>
                    </cfcase>
                    <cfcase value="ADMIN_EMAILS">
                        <cfif len(config_value)>
                            <cfset application.adminEmails = listToArray(config_value)>
                        </cfif>
                    </cfcase>
                </cfswitch>
            </cfloop>
            
        <cfcatch>
            <!--- If database config fails, try loading from config file --->
            <cftry>
                <cfinclude template="config/config.cfm">
            <cfcatch>
                <!--- Last resort: set empty values --->
                <cfset application.anthropicApiKey = "">
                <cfset application.claudeApiKey = "">
                <cfset application.googleApiKey = "">
                <cfset application.googleClientId = "">
                <cfset application.googleClientSecret = "">
            </cfcatch>
            </cftry>
        </cfcatch>
        </cftry>
        
        <!--- Set default admin emails if not loaded from database --->
        <cfif NOT structKeyExists(application, "adminEmails") OR arrayLen(application.adminEmails) EQ 0>
            <cfset application.adminEmails = [
                "kanishka@cfnetworks.com"
            ]>
        </cfif>
        
        <!--- Project types --->
        <cfset application.projectTypes = {
            "website" = {
                "name" = "Website Development",
                "icon" = "fa-globe",
                "description" = "Custom websites, e-commerce, corporate sites, and web applications"
            },
            "mobile" = {
                "name" = "Mobile App Development", 
                "icon" = "fa-mobile-alt",
                "description" = "Native iOS, Android, and cross-platform mobile applications"
            },
            "saas" = {
                "name" = "SaaS Application",
                "icon" = "fa-cloud",
                "description" = "Software as a Service platforms and cloud-based applications"
            }
        }>
        
        <!--- Service categories and types --->
        <cfset application.serviceCategories = {
            "business_corporate" = {
                "name" = "Business & Corporate Websites",
                "icon" = "fa-building",
                "services" = {
                    "small_business" = "Small Business Website",
                    "corporate" = "Corporate Website",
                    "startup_launch" = "Startup Launch Page",
                    "company_portfolio" = "Company Portfolio / About Us Page",
                    "franchise" = "Franchise or Multi-Location Sites"
                }
            },
            "ecommerce" = {
                "name" = "E-commerce Websites",
                "icon" = "fa-shopping-cart",
                "services" = {
                    "online_store" = "Online Store (Shopify, WooCommerce)",
                    "marketplace" = "Marketplace (multi-vendor platforms)",
                    "subscription_store" = "Subscription-based Store",
                    "dropshipping" = "Dropshipping Website",
                    "product_landing" = "Product Landing Pages"
                }
            },
            "portfolio_creative" = {
                "name" = "Portfolio & Creative Sites",
                "icon" = "fa-palette",
                "services" = {
                    "photo_artist" = "Photographer or Artist Portfolio",
                    "designer_showcase" = "Graphic Designer Showcase",
                    "agency_portfolio" = "Agency Portfolio",
                    "personal_branding" = "Personal Branding Website"
                }
            },
            "booking_service" = {
                "name" = "Booking & Service-Based Websites",
                "icon" = "fa-calendar-check",
                "services" = {
                    "salon_spa" = "Salon / Spa / Clinic Booking Site",
                    "hotel_rental" = "Hotel or Vacation Rental Site",
                    "appointment" = "Appointment Scheduling Website",
                    "consulting" = "Consulting or Coaching Business",
                    "legal_financial" = "Legal or Financial Services"
                }
            },
            "informational" = {
                "name" = "Informational & Content Sites",
                "icon" = "fa-newspaper",
                "services" = {
                    "blog_magazine" = "Blog or Magazine",
                    "news_portal" = "News Portal",
                    "wiki_kb" = "Wiki or Knowledge Base",
                    "documentation" = "Documentation Hub"
                }
            },
            "educational" = {
                "name" = "Educational Websites",
                "icon" = "fa-graduation-cap",
                "services" = {
                    "elearning_lms" = "E-learning Platform (LMS)",
                    "course_platform" = "Online Course Platform",
                    "school_university" = "School or University Website",
                    "tutoring" = "Tutoring Platform"
                }
            },
            "membership_community" = {
                "name" = "Membership & Community Sites",
                "icon" = "fa-users",
                "services" = {
                    "forum" = "Online Forum",
                    "membership" = "Private Membership Site",
                    "coaching_group" = "Online Coaching Group",
                    "alumni_network" = "Alumni or Professional Networks"
                }
            },
            "saas_webapp" = {
                "name" = "SaaS & Web Applications",
                "icon" = "fa-cloud",
                "services" = {
                    "software_landing" = "Software Landing Page",
                    "dashboard_ui" = "Dashboard UI / Admin Panels",
                    "client_portal" = "Client Portals",
                    "internal_tools" = "Internal Company Tools"
                }
            },
            "nonprofit_gov" = {
                "name" = "Nonprofit & Government Websites",
                "icon" = "fa-hand-holding-heart",
                "services" = {
                    "ngo_charity" = "NGO or Charity Website",
                    "religious_org" = "Religious Organization Site",
                    "public_service" = "Public Service or Municipal Site",
                    "donation_platform" = "Donation Platforms"
                }
            },
            "event_promotion" = {
                "name" = "Event & Promotion Sites",
                "icon" = "fa-calendar-alt",
                "services" = {
                    "event_registration" = "Event Registration Site",
                    "conference_webinar" = "Conference or Webinar Hub",
                    "countdown_page" = "Launch Countdown Page",
                    "ticketing" = "Ticketing Platforms"
                }
            },
            "real_estate" = {
                "name" = "Real Estate & Property Sites",
                "icon" = "fa-home",
                "services" = {
                    "property_listings" = "Property Listings Site",
                    "agent_portfolio" = "Real Estate Agent Portfolio",
                    "booking_viewing" = "Booking/Viewing Platforms"
                }
            },
            "niche_specialized" = {
                "name" = "Niche & Specialized Websites",
                "icon" = "fa-rocket",
                "services" = {
                    "job_board" = "Job Board",
                    "directory_listing" = "Directory or Listing Site",
                    "affiliate_marketing" = "Affiliate Marketing Site",
                    "crypto_web3" = "Crypto / Web3 Dashboard",
                    "fitness_meal" = "Fitness Tracker / Meal Planner"
                }
            }
        }>
        
        <!--- Mobile app categories --->
        <cfset application.mobileCategories = {
            "business_productivity" = {
                "name" = "Business & Productivity",
                "icon" = "fa-briefcase",
                "services" = {
                    "crm_sales" = "CRM & Sales Management",
                    "project_management" = "Project Management",
                    "time_tracking" = "Time Tracking & Invoicing",
                    "document_scanner" = "Document Scanner & Manager",
                    "business_analytics" = "Business Analytics Dashboard"
                }
            },
            "social_communication" = {
                "name" = "Social & Communication",
                "icon" = "fa-comments",
                "services" = {
                    "social_network" = "Social Networking App",
                    "messaging_chat" = "Messaging & Chat App",
                    "video_calling" = "Video Calling App",
                    "dating_app" = "Dating & Matchmaking",
                    "community_forum" = "Community Forum App"
                }
            },
            "commerce_delivery" = {
                "name" = "Commerce & Delivery",
                "icon" = "fa-shopping-bag",
                "services" = {
                    "ecommerce_app" = "E-commerce Shopping App",
                    "food_delivery" = "Food Delivery App",
                    "grocery_delivery" = "Grocery Delivery App",
                    "marketplace_app" = "Marketplace App",
                    "payment_wallet" = "Payment & Digital Wallet"
                }
            },
            "health_fitness" = {
                "name" = "Health & Fitness",
                "icon" = "fa-heartbeat",
                "services" = {
                    "fitness_tracker" = "Fitness & Workout Tracker",
                    "health_monitoring" = "Health Monitoring App",
                    "meditation_wellness" = "Meditation & Wellness",
                    "diet_nutrition" = "Diet & Nutrition Planner",
                    "telemedicine" = "Telemedicine App"
                }
            },
            "entertainment_media" = {
                "name" = "Entertainment & Media",
                "icon" = "fa-play-circle",
                "services" = {
                    "streaming_video" = "Video Streaming App",
                    "music_streaming" = "Music Streaming App",
                    "gaming_app" = "Gaming Application",
                    "news_reader" = "News & Magazine Reader",
                    "photo_video_editor" = "Photo/Video Editor"
                }
            },
            "education_learning" = {
                "name" = "Education & Learning",
                "icon" = "fa-graduation-cap",
                "services" = {
                    "elearning_app" = "E-Learning Platform",
                    "language_learning" = "Language Learning App",
                    "skill_training" = "Skill Training App",
                    "exam_prep" = "Exam Preparation App",
                    "kids_education" = "Kids Educational App"
                }
            },
            "travel_transportation" = {
                "name" = "Travel & Transportation",
                "icon" = "fa-plane",
                "services" = {
                    "ride_sharing" = "Ride Sharing App",
                    "travel_booking" = "Travel Booking App",
                    "navigation_maps" = "Navigation & Maps",
                    "parking_finder" = "Parking Finder App",
                    "public_transport" = "Public Transport App"
                }
            },
            "utility_tools" = {
                "name" = "Utility & Tools",
                "icon" = "fa-tools",
                "services" = {
                    "weather_app" = "Weather App",
                    "calculator_converter" = "Calculator & Converter",
                    "qr_barcode" = "QR & Barcode Scanner",
                    "file_manager" = "File Manager",
                    "vpn_security" = "VPN & Security App"
                }
            }
        }>
        
        <!--- SaaS categories --->
        <cfset application.saasCategories = {
            "business_management" = {
                "name" = "Business Management",
                "icon" = "fa-chart-line",
                "services" = {
                    "crm_platform" = "CRM Platform",
                    "erp_system" = "ERP System",
                    "hr_management" = "HR Management System",
                    "accounting_software" = "Accounting & Finance",
                    "inventory_management" = "Inventory Management"
                }
            },
            "marketing_sales" = {
                "name" = "Marketing & Sales",
                "icon" = "fa-bullhorn",
                "services" = {
                    "email_marketing" = "Email Marketing Platform",
                    "social_media_management" = "Social Media Management",
                    "seo_tools" = "SEO & Analytics Tools",
                    "landing_page_builder" = "Landing Page Builder",
                    "affiliate_tracking" = "Affiliate Tracking System"
                }
            },
            "collaboration_productivity" = {
                "name" = "Collaboration & Productivity",
                "icon" = "fa-users-cog",
                "services" = {
                    "project_management_saas" = "Project Management Tool",
                    "team_collaboration" = "Team Collaboration Platform",
                    "document_management" = "Document Management System",
                    "video_conferencing" = "Video Conferencing Platform",
                    "workflow_automation" = "Workflow Automation"
                }
            },
            "customer_support" = {
                "name" = "Customer Support",
                "icon" = "fa-headset",
                "services" = {
                    "helpdesk_ticketing" = "Helpdesk & Ticketing System",
                    "live_chat_platform" = "Live Chat Platform",
                    "knowledge_base" = "Knowledge Base Software",
                    "customer_feedback" = "Customer Feedback Tool",
                    "chatbot_platform" = "Chatbot Platform"
                }
            },
            "data_analytics" = {
                "name" = "Data & Analytics",
                "icon" = "fa-database",
                "services" = {
                    "business_intelligence" = "Business Intelligence Platform",
                    "data_visualization" = "Data Visualization Tool",
                    "reporting_dashboard" = "Reporting Dashboard",
                    "predictive_analytics" = "Predictive Analytics",
                    "data_integration" = "Data Integration Platform"
                }
            },
            "development_tools" = {
                "name" = "Development Tools",
                "icon" = "fa-code",
                "services" = {
                    "api_management" = "API Management Platform",
                    "ci_cd_platform" = "CI/CD Platform",
                    "code_repository" = "Code Repository Hosting",
                    "testing_platform" = "Testing & QA Platform",
                    "monitoring_logging" = "Monitoring & Logging"
                }
            }
        }>
        
        <cfreturn true>
    </cffunction>
    
    <cffunction name="onSessionStart" returnType="void" output="false">
        <cfset session.isLoggedIn = false>
        <cfset session.user = {}>
    </cffunction>
    
    <cffunction name="onRequestStart" returnType="boolean" output="false">
        <cfargument name="targetPage" type="string" required="true">
        
        <!--- Public pages that don't require login --->
        <cfset var publicPages = "index.cfm,login.cfm,register.cfm,simple-login.cfm,test-login.cfm,auth/,api/,restart-and-check.cfm,force-reload.cfm,test-google-auth.cfm,check-config.cfm">
        <cfset var isPublicPage = false>
        
        <cfloop list="#publicPages#" index="page">
            <cfif findNoCase(page, arguments.targetPage)>
                <cfset isPublicPage = true>
                <cfbreak>
            </cfif>
        </cfloop>
        
        <!--- Check if user is logged in for protected pages --->
        <cfif NOT session.isLoggedIn AND NOT isPublicPage>
            <cflocation url="#application.basePath#/login.cfm" addtoken="false">
        </cfif>
        
        <!--- Check admin access --->
        <cfif findNoCase("/admin/", arguments.targetPage) AND 
              (NOT session.isLoggedIn OR NOT listFindNoCase(arrayToList(application.adminEmails), session.user.email))>
            <cflocation url="#application.basePath#/dashboard.cfm" addtoken="false">
        </cfif>
        
        <cfreturn true>
    </cffunction>
</cfcomponent>