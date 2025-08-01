# Customer Intake Form System

A sophisticated customer intake system built with ColdFusion (Lucee) that features AI-powered form collection through conversational interface and traditional manual form submission.

## Features

- **AI-Powered Chat Interface**: Uses Claude API to collect form data through natural conversation
- **Manual Form Submission**: Traditional form interface for users who prefer manual entry
- **User Authentication**: Google OAuth integration for secure user login
- **Admin Dashboard**: Comprehensive admin interface for form management
- **Reference ID System**: 8-character alphanumeric IDs for easy form tracking
- **Draft Save/Resume**: Users can save forms as drafts and continue later
- **Multiple Project Types**: Support for websites, mobile apps, and SaaS applications
- **Service Categories**: Extensive categorization for different service types

## Prerequisites

- Lucee Server 5.x or higher
- MySQL/MariaDB database
- Claude API key from Anthropic
- Google OAuth credentials (for authentication)

## Installation

1. Clone the repository:
```bash
git clone https://github.com/cyber-kani/intake.git
cd intake
```

2. Copy the configuration example:
```bash
cp config/config.cfm.example config/config.cfm
```

3. Update `config/config.cfm` with your API keys:
- Anthropic Claude API key
- Google OAuth client ID and secret
- Database connection details

4. Set up the database:
- Create a database named `clitools` (or your preferred name)
- Run the SQL script: `sql/create-tables.sql`

5. Configure your web server to point to the intake directory

## Configuration

### Environment Variables

The system supports environment variables for sensitive configuration:

- `ANTHROPIC_API_KEY`: Your Claude API key
- `GOOGLE_CLIENT_ID`: Google OAuth client ID  
- `GOOGLE_CLIENT_SECRET`: Google OAuth client secret
- `DATABASE_NAME`: Database name (default: clitools)

### Application Settings

Main configuration is in `Application.cfc`:
- Base path configuration
- Service categories and types
- Admin email addresses

## Usage

### For Users

1. Navigate to the application URL
2. Sign in with Google account
3. Choose between:
   - **AI Chat**: Let the AI assistant guide you through the form
   - **Manual Form**: Fill out the traditional form

### For Administrators

1. Sign in with an admin account (configured in Application.cfc)
2. Access the admin dashboard at `/admin/`
3. View, manage, and export submitted forms

## AI Chat Implementation

The AI chat uses a staged approach:
1. **Initial Classification**: Uses Claude API to determine project type
2. **Service Selection**: Uses Claude API to identify service category
3. **Data Collection**: Uses structured prompts (no AI) to collect remaining information

This approach minimizes API usage while maintaining a conversational experience.

## File Structure

```
intake/
├── api/              # API endpoints for AJAX calls
├── admin/            # Admin dashboard files
├── auth/             # Authentication related files
├── components/       # ColdFusion components
├── config/           # Configuration files
├── css/              # Stylesheets
├── includes/         # Common includes (header/footer)
├── sql/              # Database scripts
├── Application.cfc   # Main application configuration
├── index.cfm         # Landing page
├── dashboard.cfm     # User dashboard
├── form-new.cfm      # Manual form entry
├── form-new-ai.cfm   # AI chat interface
└── form-view.cfm     # Form viewing page
```

## Security

- All API keys should be stored in `config/config.cfm` (not committed to git)
- User authentication required for all form operations
- Admin access restricted by email whitelist
- SQL injection protection through cfqueryparam
- XSS protection enabled

## Development

### Adding New Service Types

1. Update `Application.cfc` with new categories/services
2. Update form templates if needed
3. Restart the application to load changes

### Modifying AI Behavior

Edit `api/smart-chat.cfm` to adjust:
- Question flow
- AI prompts
- Conversation stages

## Troubleshooting

### Common Issues

1. **API Key Errors**: Ensure your Claude API key is valid in config/config.cfm
2. **Database Connection**: Check database credentials and server connectivity
3. **Session Issues**: Clear browser cookies and restart session

### Debug Mode

Enable debug output by adding `?debug=true` to URLs (admin only)

## License

This project is proprietary software. All rights reserved.

## Support

For issues or questions, please contact the development team.