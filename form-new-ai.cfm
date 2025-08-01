<cfinclude template="includes/header.cfm">

<div class="container mt-4">
    <div class="row justify-content-center">
        <div class="col-md-10">
            <h2 class="mb-4 text-center">Let's Understand Your Project</h2>
            
            <div class="card shadow">
                <div class="card-body p-5">
                    <div class="text-center mb-4">
                        <div class="ai-icon-container mb-3">
                            <div class="ai-icon-wrapper">
                                <div class="ai-icon-glow"></div>
                                <div class="ai-icon">
                                    <svg width="60" height="60" viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
                                        <defs>
                                            <linearGradient id="torusGradient" x1="0%" y1="0%" x2="100%" y2="100%">
                                                <stop offset="0%" style="stop-color:#667eea;stop-opacity:1" />
                                                <stop offset="100%" style="stop-color:#764ba2;stop-opacity:1" />
                                            </linearGradient>
                                        </defs>
                                        <g class="torus-group">
                                            <circle cx="50" cy="50" r="35" fill="none" stroke="url(#torusGradient)" stroke-width="12" opacity="0.3" />
                                            <circle cx="50" cy="50" r="35" fill="none" stroke="url(#torusGradient)" stroke-width="12" stroke-dasharray="55 165" class="torus-ring" />
                                            <circle cx="50" cy="50" r="20" fill="none" stroke="url(#torusGradient)" stroke-width="8" opacity="0.5" />
                                            <circle cx="50" cy="50" r="20" fill="none" stroke="url(#torusGradient)" stroke-width="8" stroke-dasharray="30 95" class="torus-ring-inner" />
                                        </g>
                                    </svg>
                                </div>
                            </div>
                        </div>
                        <h4>Tell us about your project</h4>
                        <p class="text-muted">Our AI assistant will help understand your needs and guide you through the process</p>
                    </div>
                    
                    <!--- Chat Interface --->
                    <div class="chat-container" style="height: 400px; overflow-y: auto; border: 1px solid #dee2e6; border-radius: 10px; padding: 20px; background-color: #f8f9fa;">
                        <div id="chatMessages">
                            <!--- Initial AI Message --->
                            <div class="message ai-message mb-3">
                                <div class="d-flex align-items-start">
                                    <div class="avatar text-white rounded-circle p-2 me-2" style="background: white; border: 2px solid #667eea;">
                                        <svg width="20" height="20" viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
                                            <defs>
                                                <linearGradient id="torusGradientSmall" x1="0%" y1="0%" x2="100%" y2="100%">
                                                    <stop offset="0%" style="stop-color:#667eea;stop-opacity:1" />
                                                    <stop offset="100%" style="stop-color:#764ba2;stop-opacity:1" />
                                                </linearGradient>
                                            </defs>
                                            <g>
                                                <circle cx="50" cy="50" r="35" fill="none" stroke="url(#torusGradientSmall)" stroke-width="15" opacity="0.3" />
                                                <circle cx="50" cy="50" r="35" fill="none" stroke="url(#torusGradientSmall)" stroke-width="15" stroke-dasharray="55 165" class="mini-torus" />
                                            </g>
                                        </svg>
                                    </div>
                                    <div class="message-content bg-white p-3 rounded shadow-sm" style="max-width: 80%;">
                                        <p class="mb-0"><strong>What would you like to build?</strong></p>
                                        <p class="mb-0 mt-2">Just tell me in a few words - website, mobile app, or software platform?</p>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    
                    <!--- Input Area --->
                    <div class="mt-3">
                        <form id="chatForm">
                            <div class="input-group">
                                <textarea class="form-control" id="userMessage" rows="2" placeholder="Type your project description here..." style="resize: none;"></textarea>
                                <button class="btn btn-primary" type="submit" id="sendBtn">
                                    <i class="fas fa-paper-plane"></i> Send
                                </button>
                            </div>
                        </form>
                        <div class="d-flex justify-content-between align-items-center mt-2">
                            <button class="btn btn-sm btn-outline-secondary" onclick="saveDraft()" id="saveDraftBtn">
                                <i class="fas fa-save"></i> Save Draft
                            </button>
                            <small class="text-muted" id="saveStatus"></small>
                        </div>
                    </div>
                    
                    <!--- Hidden form to store discovered information --->
                    <form id="discoveredInfoForm" style="display: none;">
                        <input type="hidden" name="project_type" id="discovered_project_type">
                        <input type="hidden" name="service_category" id="discovered_service_category">
                        <input type="hidden" name="service_type" id="discovered_service_type">
                        <input type="hidden" name="project_description" id="discovered_description">
                        <input type="hidden" name="additional_info" id="discovered_additional_info">
                    </form>
                    
                    <!--- Continue Button (hidden initially) --->
                    <div class="text-center mt-4" id="continueSection" style="display: none;">
                        <hr>
                        <p class="text-success"><i class="fas fa-check-circle"></i> Great! I understand your project needs.</p>
                        <button class="btn btn-success btn-lg" onclick="proceedToForm()">
                            Continue to Detailed Form <i class="fas fa-arrow-right"></i>
                        </button>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<style>
.ai-icon-container {
    display: inline-block;
    position: relative;
}

.ai-icon-wrapper {
    position: relative;
    width: 120px;
    height: 120px;
    display: flex;
    align-items: center;
    justify-content: center;
}

.ai-icon {
    background: rgba(255, 255, 255, 0.9);
    width: 100px;
    height: 100px;
    border-radius: 30px;
    display: flex;
    align-items: center;
    justify-content: center;
    box-shadow: 0 10px 30px rgba(102, 126, 234, 0.3);
    position: relative;
    z-index: 2;
    animation: float 3s ease-in-out infinite;
}

.torus-group {
    animation: rotate3d 8s linear infinite;
    transform-origin: center;
}

.torus-ring {
    animation: rotateTorus 4s linear infinite;
    transform-origin: center;
}

.torus-ring-inner {
    animation: rotateTorusInner 3s linear infinite reverse;
    transform-origin: center;
}

@keyframes rotate3d {
    0% { transform: rotateY(0deg) rotateX(15deg); }
    100% { transform: rotateY(360deg) rotateX(15deg); }
}

@keyframes rotateTorus {
    0% { stroke-dashoffset: 0; }
    100% { stroke-dashoffset: 220; }
}

@keyframes rotateTorusInner {
    0% { stroke-dashoffset: 0; }
    100% { stroke-dashoffset: 125; }
}

.ai-icon-glow {
    position: absolute;
    width: 120px;
    height: 120px;
    background: radial-gradient(circle, rgba(102, 126, 234, 0.3) 0%, transparent 70%);
    border-radius: 50%;
    animation: pulse 2s ease-in-out infinite;
    z-index: 1;
}

@keyframes float {
    0%, 100% { transform: translateY(0px); }
    50% { transform: translateY(-10px); }
}

@keyframes pulse {
    0%, 100% { transform: scale(1); opacity: 0.5; }
    50% { transform: scale(1.2); opacity: 0.3; }
}

.chat-container {
    scroll-behavior: smooth;
    overflow-y: auto;
    overflow-x: hidden;
}

#chatMessages {
    padding-bottom: 10px;
}

.message {
    animation: fadeIn 0.3s ease-in;
}

@keyframes fadeIn {
    from { opacity: 0; transform: translateY(10px); }
    to { opacity: 1; transform: translateY(0); }
}

.user-message .message-content {
    background-color: #0d6efd !important;
    color: white;
}

.avatar {
    width: 35px;
    height: 35px;
    display: flex;
    align-items: center;
    justify-content: center;
    flex-shrink: 0;
}

.ai-message .avatar {
    background: white !important;
    border: 2px solid #667eea;
}

.mini-torus {
    animation: rotateMiniTorus 3s linear infinite;
    transform-origin: center;
}

@keyframes rotateMiniTorus {
    0% { stroke-dashoffset: 0; }
    100% { stroke-dashoffset: 220; }
}

.typing-indicator {
    display: inline-flex;
    align-items: center;
}

.typing-indicator span {
    height: 8px;
    width: 8px;
    background-color: #6c757d;
    border-radius: 50%;
    display: inline-block;
    margin: 0 2px;
    animation: typing 1.4s infinite;
}

.typing-indicator span:nth-child(2) {
    animation-delay: 0.2s;
}

.typing-indicator span:nth-child(3) {
    animation-delay: 0.4s;
}

@keyframes typing {
    0%, 60%, 100% {
        transform: translateY(0);
    }
    30% {
        transform: translateY(-10px);
    }
}

/* Custom styling for option list items */
.list-group-item {
    transition: all 0.2s ease;
    cursor: pointer;
    border: 1px solid #e0e0e0 !important;
}

.list-group-item:hover {
    transform: translateX(5px);
    border-color: #667eea !important;
    box-shadow: 0 2px 8px rgba(102, 126, 234, 0.15);
}

.list-group-item .badge {
    min-width: 30px;
    font-size: 0.9rem;
    padding: 0.5rem;
}

.list-group-item h6 {
    color: #2d3748;
    font-weight: 600;
    margin-bottom: 0.25rem;
}

.list-group-item small {
    font-size: 0.85rem;
    line-height: 1.4;
}

/* Ensure AI message content looks good */
.ai-message .message-content {
    line-height: 1.6;
}

.ai-message .message-content p {
    margin-bottom: 0.5rem;
}

.ai-message .message-content p:last-child {
    margin-bottom: 0;
}
</style>

<script>
const chatMessages = document.getElementById('chatMessages');
const userMessageInput = document.getElementById('userMessage');
const chatForm = document.getElementById('chatForm');
let conversationHistory = [];
let projectInfo = {
    stage: 'project_type',
    type: null,
    category: null,
    service: null,
    description: '',
    additionalInfo: {}
};
let currentFormId = null;
let currentReferenceId = null;

// Check if we're loading an existing draft
<cfif structKeyExists(url, "id")>
    // Store reference ID from URL
    currentReferenceId = '<cfoutput>#url.id#</cfoutput>';
    // Load existing conversation
    loadDraft('<cfoutput>#url.id#</cfoutput>');
</cfif>

// Handle form submission
chatForm.addEventListener('submit', async function(e) {
    e.preventDefault();
    
    const message = userMessageInput.value.trim();
    if (!message) return;
    
    // Add user message to chat
    addMessage(message, 'user');
    
    // Clear input
    userMessageInput.value = '';
    
    // Show typing indicator
    showTypingIndicator();
    
    // Send to Claude API
    try {
        const requestData = {
            message: message,
            conversationHistory: conversationHistory,
            projectInfo: projectInfo
        };
        
        // console.log('Sending request:', requestData);
        
        const response = await fetch('<cfoutput>#application.basePath#</cfoutput>/api/smart-chat.cfm', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(requestData)
        });
        
        // console.log('Response status:', response.status, response.statusText);
        
        const data = await response.json();
        
        // Remove typing indicator
        removeTypingIndicator();
        
        // Debug: Log the response (only in development)
        // console.log('API Response:', data);
        
        // Check if there was an error
        if (!data.success) {
            console.error('API Error:', data.error, data.detail);
        }
        
        // Add AI response
        addMessage(data.response, 'ai');
        
        // Update project info if provided - deep merge to preserve nested data
        if (data.projectInfo) {
            // Deep merge to preserve nested objects
            projectInfo = {
                ...projectInfo,
                ...data.projectInfo,
                basicInfo: { ...(projectInfo.basicInfo || {}), ...(data.projectInfo.basicInfo || {}) },
                projectDetails: { ...(projectInfo.projectDetails || {}), ...(data.projectInfo.projectDetails || {}) },
                designFeatures: { ...(projectInfo.designFeatures || {}), ...(data.projectInfo.designFeatures || {}) }
            };
            // console.log('Updated projectInfo:', projectInfo);
        }
        
        // Check if form is complete
        if (data.isComplete && projectInfo.stage === 'complete') {
            // console.log('Form completion detected. ProjectInfo:', projectInfo);
            
            // Show submit button
            document.getElementById('continueSection').style.display = 'block';
            
            // Update button to say "Submit Form"
            const submitBtn = document.querySelector('#continueSection button');
            submitBtn.textContent = 'Submit Complete Form ';
            submitBtn.innerHTML = 'Submit Complete Form <i class="fas fa-check-circle"></i>';
            submitBtn.onclick = submitCompleteForm;
        }
        
        // Update conversation history
        conversationHistory = data.conversationHistory || conversationHistory;
        
        // Auto-save after each response
        if (projectInfo.stage && projectInfo.stage !== 'project_type') {
            // Small delay to ensure projectInfo is updated
            setTimeout(() => {
                autoSaveDraft();
            }, 500);
        }
        
    } catch (error) {
        console.error('Chat Error:', error);
        removeTypingIndicator();
        addMessage('Sorry, I encountered an error. Please try again.', 'ai');
    }
});

function addMessage(message, sender) {
    const messageDiv = document.createElement('div');
    messageDiv.className = `message ${sender}-message mb-3`;
    
    const avatar = sender === 'user' 
        ? '<div class="avatar bg-secondary text-white rounded-circle p-2 ms-2"><i class="fas fa-user"></i></div>'
        : `<div class="avatar text-white rounded-circle p-2 me-2" style="background: white; border: 2px solid #667eea;">
            <svg width="20" height="20" viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
                <defs>
                    <linearGradient id="torusGradientSmall${Date.now()}" x1="0%" y1="0%" x2="100%" y2="100%">
                        <stop offset="0%" style="stop-color:#667eea;stop-opacity:1" />
                        <stop offset="100%" style="stop-color:#764ba2;stop-opacity:1" />
                    </linearGradient>
                </defs>
                <g>
                    <circle cx="50" cy="50" r="35" fill="none" stroke="url(#torusGradientSmall${Date.now()})" stroke-width="15" opacity="0.3" />
                    <circle cx="50" cy="50" r="35" fill="none" stroke="url(#torusGradientSmall${Date.now()})" stroke-width="15" stroke-dasharray="55 165" class="mini-torus" />
                </g>
            </svg>
          </div>`;
    
    const messageClass = sender === 'user' ? 'bg-primary text-white' : 'bg-white';
    const alignment = sender === 'user' ? 'justify-content-end' : 'justify-content-start';
    
    // Format message to handle numbered lists nicely
    let formattedMessage = message;
    if (sender === 'ai') {
        // Check if message contains numbered list
        const hasNumberedList = /^\d+\.\s+/m.test(message);
        if (hasNumberedList) {
            // Split message into parts
            const lines = message.split('\n');
            let introText = '';
            let listItems = [];
            let collectingList = false;
            
            for (let line of lines) {
                const trimmedLine = line.trim();
                if (/^\d+\.\s+/.test(trimmedLine)) {
                    collectingList = true;
                    // Extract number and text
                    const match = trimmedLine.match(/^(\d+)\.\s+(.+)$/);
                    if (match) {
                        const [, num, text] = match;
                        // Check if text contains " - " to split title and description
                        if (text.includes(' - ')) {
                            const [title, desc] = text.split(' - ', 2);
                            listItems.push({ num, title: title.trim(), desc: desc.trim() });
                        } else {
                            listItems.push({ num, title: text.trim(), desc: '' });
                        }
                    }
                } else if (!collectingList && trimmedLine) {
                    introText += line + '<br>';
                }
            }
            
            // Build formatted message
            if (introText) {
                formattedMessage = `<p class="mb-3">${introText}</p>`;
            } else {
                formattedMessage = '';
            }
            
            if (listItems.length > 0) {
                formattedMessage += '<div class="list-group">';
                for (let item of listItems) {
                    formattedMessage += `
                        <button type="button" class="list-group-item list-group-item-action text-start mb-2 border rounded" 
                                onclick="selectOption('${item.num}', '${item.title.replace(/'/g, "\\'")}')">
                            <div class="d-flex align-items-start">
                                <span class="badge bg-primary rounded-pill me-3">${item.num}</span>
                                <div class="flex-grow-1">
                                    <h6 class="mb-1">${item.title}</h6>
                                    ${item.desc ? `<small class="text-muted">${item.desc}</small>` : ''}
                                </div>
                            </div>
                        </button>
                    `;
                }
                formattedMessage += '</div>';
                formattedMessage += '<p class="mt-3 text-muted small">Click an option above or type your choice</p>';
            }
        } else {
            // Replace line breaks with <br> for regular messages
            formattedMessage = message.replace(/\n/g, '<br>');
        }
    }
    
    messageDiv.innerHTML = `
        <div class="d-flex align-items-start ${alignment}">
            ${sender === 'ai' ? avatar : ''}
            <div class="message-content ${messageClass} p-3 rounded shadow-sm" style="max-width: 80%;">
                ${formattedMessage}
            </div>
            ${sender === 'user' ? avatar : ''}
        </div>
    `;
    
    chatMessages.appendChild(messageDiv);
    // Ensure smooth scrolling to bottom
    setTimeout(() => {
        chatMessages.scrollTop = chatMessages.scrollHeight;
        // Also scroll the container if needed
        const chatContainer = document.querySelector('.chat-container');
        if (chatContainer) {
            chatContainer.scrollTop = chatContainer.scrollHeight;
        }
    }, 100);
}

function showTypingIndicator() {
    const typingDiv = document.createElement('div');
    typingDiv.id = 'typingIndicator';
    typingDiv.className = 'message ai-message mb-3';
    typingDiv.innerHTML = `
        <div class="d-flex align-items-start">
            <div class="avatar text-white rounded-circle p-2 me-2" style="background: white; border: 2px solid #667eea;">
                <svg width="20" height="20" viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
                    <defs>
                        <linearGradient id="torusGradientTyping" x1="0%" y1="0%" x2="100%" y2="100%">
                            <stop offset="0%" style="stop-color:#667eea;stop-opacity:1" />
                            <stop offset="100%" style="stop-color:#764ba2;stop-opacity:1" />
                        </linearGradient>
                    </defs>
                    <g>
                        <circle cx="50" cy="50" r="35" fill="none" stroke="url(#torusGradientTyping)" stroke-width="15" opacity="0.3" />
                        <circle cx="50" cy="50" r="35" fill="none" stroke="url(#torusGradientTyping)" stroke-width="15" stroke-dasharray="55 165" class="mini-torus" />
                    </g>
                </svg>
            </div>
            <div class="message-content bg-white p-3 rounded shadow-sm">
                <div class="typing-indicator">
                    <span></span>
                    <span></span>
                    <span></span>
                </div>
            </div>
        </div>
    `;
    chatMessages.appendChild(typingDiv);
    // Ensure smooth scrolling to bottom for typing indicator
    setTimeout(() => {
        chatMessages.scrollTop = chatMessages.scrollHeight;
        const chatContainer = document.querySelector('.chat-container');
        if (chatContainer) {
            chatContainer.scrollTop = chatContainer.scrollHeight;
        }
    }, 50);
}

function removeTypingIndicator() {
    const typingIndicator = document.getElementById('typingIndicator');
    if (typingIndicator) {
        typingIndicator.remove();
    }
}

function proceedToForm() {
    // Create a form to submit the discovered information
    const form = document.createElement('form');
    form.method = 'POST';
    form.action = '<cfoutput>#application.basePath#</cfoutput>/form-new.cfm';
    
    // Add project type
    const projectTypeInput = document.createElement('input');
    projectTypeInput.type = 'hidden';
    projectTypeInput.name = 'project_type';
    projectTypeInput.value = projectInfo.type || '';
    form.appendChild(projectTypeInput);
    
    // Add service category
    const categoryInput = document.createElement('input');
    categoryInput.type = 'hidden';
    categoryInput.name = 'service_category';
    categoryInput.value = projectInfo.category || '';
    form.appendChild(categoryInput);
    
    // Add service type
    const serviceInput = document.createElement('input');
    serviceInput.type = 'hidden';
    serviceInput.name = 'service_type';
    serviceInput.value = projectInfo.service || '';
    form.appendChild(serviceInput);
    
    // Add project description
    const descInput = document.createElement('input');
    descInput.type = 'hidden';
    descInput.name = 'project_description';
    descInput.value = projectInfo.description || '';
    form.appendChild(descInput);
    
    // Add from_ai flag
    const fromAIInput = document.createElement('input');
    fromAIInput.type = 'hidden';
    fromAIInput.name = 'from_ai';
    fromAIInput.value = 'true';
    form.appendChild(fromAIInput);
    
    document.body.appendChild(form);
    form.submit();
}

// Allow Enter key to send message (Shift+Enter for new line)
userMessageInput.addEventListener('keydown', function(e) {
    if (e.key === 'Enter' && !e.shiftKey) {
        e.preventDefault();
        chatForm.dispatchEvent(new Event('submit'));
    }
});

// Function to handle option selection
function selectOption(optionNumber, optionTitle) {
    // Set the input value and submit
    userMessageInput.value = optionNumber;
    chatForm.dispatchEvent(new Event('submit'));
}

// Auto-save function (with subtle UI updates)
async function autoSaveDraft() {
    try {
        // Show saving indicator
        const saveStatus = document.getElementById('saveStatus');
        saveStatus.innerHTML = '<i class="fas fa-circle-notch fa-spin"></i> Saving...';
        saveStatus.className = 'text-muted small';
        
        const response = await fetch('<cfoutput>#application.basePath#</cfoutput>/api/save-chat-draft.cfm', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                conversationHistory: conversationHistory,
                projectInfo: projectInfo,
                formId: currentFormId
            })
        });
        
        const data = await response.json();
        
        if (data.success) {
            currentFormId = data.formId;
            currentReferenceId = data.referenceId;
            // Update URL without reload
            const newUrl = `<cfoutput>#application.basePath#</cfoutput>/form-new-ai.cfm?id=${data.referenceId}`;
            window.history.replaceState({}, '', newUrl);
            
            // Show saved indicator
            saveStatus.innerHTML = '<i class="fas fa-check-circle"></i> Saved';
            saveStatus.className = 'text-success small';
            setTimeout(() => {
                saveStatus.textContent = '';
            }, 3000);
        } else {
            // Show error briefly
            saveStatus.innerHTML = '<i class="fas fa-exclamation-circle"></i> Save failed';
            saveStatus.className = 'text-danger small';
            setTimeout(() => {
                saveStatus.textContent = '';
            }, 3000);
        }
    } catch (error) {
        console.error('Auto-save error:', error);
        const saveStatus = document.getElementById('saveStatus');
        saveStatus.innerHTML = '<i class="fas fa-exclamation-circle"></i> Save failed';
        saveStatus.className = 'text-danger small';
        setTimeout(() => {
            saveStatus.textContent = '';
        }, 3000);
    }
}

// Function to save draft (manual)
async function saveDraft() {
    const saveBtn = document.getElementById('saveDraftBtn');
    const saveStatus = document.getElementById('saveStatus');
    
    // Show saving state
    saveBtn.disabled = true;
    saveBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Saving...';
    
    try {
        const response = await fetch('<cfoutput>#application.basePath#</cfoutput>/api/save-chat-draft.cfm', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                conversationHistory: conversationHistory,
                projectInfo: projectInfo,
                formId: currentFormId
            })
        });
        
        const data = await response.json();
        
        if (data.success) {
            currentFormId = data.formId;
            currentReferenceId = data.referenceId;
            saveStatus.textContent = 'Draft saved!';
            saveStatus.className = 'text-success small';
            
            // Update URL without reload
            const newUrl = `<cfoutput>#application.basePath#</cfoutput>/form-new-ai.cfm?id=${data.referenceId}`;
            window.history.replaceState({}, '', newUrl);
            
            setTimeout(() => {
                saveStatus.textContent = '';
            }, 3000);
        } else {
            saveStatus.textContent = 'Error saving draft';
            saveStatus.className = 'text-danger small';
        }
    } catch (error) {
        console.error('Error saving draft:', error);
        saveStatus.textContent = 'Error saving draft';
        saveStatus.className = 'text-danger small';
    }
    
    // Reset button
    saveBtn.disabled = false;
    saveBtn.innerHTML = '<i class="fas fa-save"></i> Save Draft';
}

// Function to load draft
async function loadDraft(referenceId) {
    try {
        // First get the form data
        const response = await fetch(`<cfoutput>#application.basePath#</cfoutput>/api/get-form.cfm?id=${referenceId}`);
        const data = await response.json();
        
        if (data.success && data.form.form_data) {
            const formData = JSON.parse(data.form.form_data);
            
            if (formData.ai_conversation) {
                const aiData = JSON.parse(formData.ai_conversation);
                
                // Restore conversation history
                conversationHistory = aiData.conversationHistory || [];
                projectInfo = aiData.projectInfo || projectInfo;
                currentFormId = data.form.form_id;
                currentReferenceId = referenceId; // Store the reference ID from URL
                
                // Clear chat and rebuild from history
                chatMessages.innerHTML = '';
                
                // Add initial AI message
                addMessage("What would you like to build?\\nJust tell me in a few words - website, mobile app, or software platform?", 'ai');
                
                // Replay conversation
                for (let i = 0; i < conversationHistory.length; i++) {
                    const msg = conversationHistory[i];
                    if (msg.role === 'user') {
                        addMessage(msg.content, 'user');
                    } else if (msg.role === 'assistant') {
                        addMessage(msg.content, 'ai');
                    }
                }
                
                // Show continue section if form was complete
                if (projectInfo.stage === 'complete') {
                    document.getElementById('continueSection').style.display = 'block';
                    const submitBtn = document.querySelector('#continueSection button');
                    submitBtn.textContent = 'Submit Complete Form ';
                    submitBtn.innerHTML = 'Submit Complete Form <i class="fas fa-check-circle"></i>';
                    submitBtn.onclick = submitCompleteForm;
                }
                
                // Update save status
                const saveStatus = document.getElementById('saveStatus');
                saveStatus.textContent = 'Draft loaded';
                saveStatus.className = 'text-info small';
                setTimeout(() => {
                    saveStatus.textContent = '';
                }, 3000);
            }
        }
    } catch (error) {
        console.error('Error loading draft:', error);
        addMessage('Error loading saved conversation. Starting fresh.', 'ai');
    }
}

// Function to submit the complete form
function submitCompleteForm() {
    // console.log('Submitting complete form with data:', projectInfo);
    console.log('Current form ID before submit:', currentFormId);
    console.log('Current reference ID:', currentReferenceId);
    console.log('Form fields being submitted:', {
        action: 'submit',
        form_id: currentFormId ? String(currentFormId) : '',
        reference_id: currentReferenceId || '',
        has_form_id: currentFormId ? 'yes' : 'no',
        has_reference_id: currentReferenceId ? 'yes' : 'no'
    });
    
    // Create a form to submit all collected information
    const form = document.createElement('form');
    form.method = 'POST';
    form.setAttribute('action', '<cfoutput>#application.basePath#</cfoutput>/form-save.cfm');
    
    // Map the collected data to form fields
    // IMPORTANT: action field must be first to ensure it's not overridden
    const fields = {
        'action': 'submit', // Explicitly set action to submit - MUST BE FIRST
        'form_id': currentFormId ? String(currentFormId) : '', // Include existing form ID
        'reference_id': currentReferenceId || '', // Include reference ID if no form ID
        'from_ai': 'true',
        'is_complete': 'true',
        'project_type': projectInfo.project_type || '',
        'service_category': projectInfo.service_category || '',
        'service_type': projectInfo.service_type || '',
        'first_name': projectInfo.basicInfo?.first_name || '',
        'last_name': projectInfo.basicInfo?.last_name || '',
        'email': projectInfo.basicInfo?.email || '<cfoutput>#session.user.email#</cfoutput>',
        'phone_number': projectInfo.basicInfo?.phone || '',
        'company_name': projectInfo.basicInfo?.company || '',
        'preferred_contact_method': projectInfo.basicInfo?.contact_method || 'email',
        'current_website': projectInfo.basicInfo?.website || 'no',
        'project_name': 'AI Chat Project - ' + new Date().toLocaleDateString(),
        'project_description': projectInfo.projectDetails?.description || '',
        'target_audience': projectInfo.projectDetails?.target_audience || '',
        'geographic_target': projectInfo.projectDetails?.geographic_target || '',
        'timeline': projectInfo.projectDetails?.timeline || '',
        'budget_range': projectInfo.projectDetails?.budget || '',
        'design_style': projectInfo.designFeatures?.style || '',
        'color_preferences': JSON.stringify(projectInfo.designFeatures?.colors || []),
        'features': JSON.stringify(projectInfo.designFeatures?.features || []),
        'ai_conversation': JSON.stringify({
            'conversationHistory': conversationHistory,
            'projectInfo': projectInfo
        })
    };
    
    // Create hidden inputs for each field
    for (const [name, value] of Object.entries(fields)) {
        const input = document.createElement('input');
        input.type = 'hidden';
        input.name = name;
        input.value = value;
        form.appendChild(input);
        
        // Debug log for action field
        if (name === 'action') {
            console.log('Setting action field to:', value);
        }
    }
    
    // Show loading state
    const submitBtn = document.querySelector('#continueSection button');
    submitBtn.disabled = true;
    submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Submitting...';
    
    document.body.appendChild(form);
    form.submit();
}
</script>

<cfinclude template="includes/footer.cfm">