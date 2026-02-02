# Post-Assessment Workflow - Visual Flow & Implementation Guide

**Document**: Visual Flow & Technical Mapping  
**Purpose**: Step-by-step visual guide for post-assessment automation  
**Reference**: Rails code analysis completed  

---

## 🔄 COMPLETE WORKFLOW FLOW DIAGRAM

```
┌──────────────────────────────────────────────────────────────────────────┐
│                        ASSESSMENT SUBMISSION FLOW                         │
│                         (Already Automated ✅)                            │
├──────────────────────────────────────────────────────────────────────────┤
│                                                                           │
│  Company User  │                                                         │
│  └─ Fills assessment                                                     │
│  └─ Clicks "Submit Assessment"                                          │
│  └─ GET company_user/dashboard (auto-redirect)                         │
│                                                                           │
└──────────────────────────────────────────────────────────────────────────┘
                                     ↓
┌──────────────────────────────────────────────────────────────────────────┐
│                   ADMIN ASSIGNMENT WORKFLOW                               │
│                     (TO AUTOMATE - STEP 1)                               │
├──────────────────────────────────────────────────────────────────────────┤
│                                                                           │
│  Admin User                                                              │
│  ├─ Login: POST /users/sign_in                                          │
│  │  Email: admin@example.com                                            │
│  │  Password: ****                                                       │
│  │                                                                       │
│  ├─ Navigate: GET /esgadmin/company_users                              │
│  │  └─ AdminESGDiagnosticPage loads                                    │
│  │  └─ Table displays all company users with status                    │
│  │                                                                       │
│  ├─ Find Company User Record                                            │
│  │  └─ Search by company name or email                                 │
│  │  └─ Filter/scroll to find submitted user                            │
│  │                                                                       │
│  ├─ Select User & Assign Analyst                                        │
│  │  └─ Click "Assign" button in row                                    │
│  │  └─ Modal appears with analyst selector dropdown                    │
│  │  └─ Select: "Kishore Analyst"                                       │
│  │     Email: kishore.r+analyst@spritle.com                            │
│  │  └─ Click "Confirm/Assign" button                                   │
│  │                                                                       │
│  ├─ Request Sent:                                                        │
│  │  Method: PATCH                                                        │
│  │  URL: /esgadmin/company_users/:analyst_id/assign_analyst            │
│  │  Params:                                                              │
│  │    id = Kishore Analyst's user ID                                   │
│  │    company_user_id = submitted company user's ID                    │
│  │                                                                       │
│  ├─ Backend Processing (Admin::CompanyUsersController#assign_analyst)   │
│  │  └─ Find analyst user: User.find(params[:id])                       │
│  │  └─ For each company_user_id:                                       │
│  │     ├─ Find/create AssignAnalyst record                             │
│  │     ├─ Update analyst_user_id & analyst_name_id                     │
│  │     ├─ Update user status: ANALYST_ASSIGNED                         │
│  │     └─ Send email to analyst                                        │
│  │  └─ Redirect: admin_company_users_path                              │
│  │                                                                       │
│  ├─ Verify Success:                                                      │
│  │  └─ Toast message: "successfully assigned"                          │
│  │  └─ User record shows "Assigned to Analyst"                         │
│  │                                                                       │
│  └─ Logout: POST /users/sign_out                                        │
│     └─ Confirm in modal                                                │
│     └─ Redirect to sign_in page                                        │
│                                                                           │
└──────────────────────────────────────────────────────────────────────────┘
                                     ↓
┌──────────────────────────────────────────────────────────────────────────┐
│                    ANALYST REVIEW WORKFLOW                                │
│                     (TO AUTOMATE - STEP 2)                               │
├──────────────────────────────────────────────────────────────────────────┤
│                                                                           │
│  Analyst User (Kishore Analyst)                                          │
│  ├─ Login: POST /users/sign_in                                          │
│  │  Email: kishore.r+analyst@spritle.com                               │
│  │  Password: Spritle123@                                               │
│  │                                                                       │
│  ├─ Navigate: GET /analyst/dashboard                                   │
│  │  └─ AnalystDashboardPage loads                                      │
│  │  └─ Shows list of companies assigned to this analyst                │
│  │  └─ Data from: AssignAnalyst.where(analyst_user_id: current)       │
│  │                                                                       │
│  ├─ View Assigned Assessment:                                            │
│  │  └─ Find company in list (matches from admin assignment)            │
│  │  └─ Click "View" or "Review" link                                   │
│  │  └─ GET /analyst/assessment/:company_user_id/edit_assessment/cii    │
│  │                                                                       │
│  ├─ Assessment Review Page Loads:                                        │
│  │  (Analyst::AssessmentController#edit_assessment)                     │
│  │  └─ Loads company user details                                      │
│  │  └─ Loads questionnaire questions                                   │
│  │  └─ Loads answers (already filled by company user)                  │
│  │  └─ AnalystAssessmentReviewPage displays:                          │
│  │     ├─ Company name                                                 │
│  │     ├─ Categories/Aspects (Corporate Governance, etc.)              │
│  │     ├─ Questions (with company user's answers filled in)            │
│  │     ├─ Comment fields (empty, for analyst review)                   │
│  │     ├─ Save button (intermediate save)                              │
│  │     └─ Submit button (final submission)                             │
│  │                                                                       │
│  ├─ Add Comments/Review:                                                 │
│  │  └─ For each question/category:                                     │
│  │     ├─ Read company user's answer                                   │
│  │     ├─ Add analyst comment in comment field                         │
│  │     │  (e.g., "Answer is complete and accurate")                    │
│  │     └─ Repeat for multiple questions                                │
│  │                                                                       │
│  ├─ Save Comments (Intermediate):                                        │
│  │  └─ Click "Save" button                                             │
│  │  └─ PATCH /analyst/assessment/:company_user_id/update_assessment    │
│  │  │  Params:                                                           │
│  │  │    company_user_id = submitted user's ID                         │
│  │  │    aspect_name = "corporate_governance" (etc)                    │
│  │  │    user_answers = { ...comment data... }                         │
│  │  │                                                                    │
│  │  └─ Backend: Analyst::AssessmentController#update_assessment        │
│  │     ├─ Find Answer record (answer_type: CII_USER)                   │
│  │     ├─ Update with new comments                                     │
│  │     ├─ Update submitted_at timestamp                                │
│  │     └─ Update user status: ASSESSMENT_VALIDATION_IN_PROGRESS        │
│  │                                                                       │
│  │  └─ Toast: "Assessment updated successfully"                        │
│  │                                                                       │
│  ├─ Submit Review (Final):                                               │
│  │  └─ Click "Submit" button                                           │
│  │  └─ Confirmation dialog appears (optional)                          │
│  │  └─ PATCH /analyst/assessment/:company_user_id/submit_assessment    │
│  │                                                                       │
│  │  └─ Backend: Analyst::AssessmentController#submit_assessment        │
│  │     ├─ Find user and update status:                                 │
│  │     │  ASSESSMENT_VALIDATION_COMPLETED                              │
│  │     └─ Redirect: analyst_dashboard_path                             │
│  │                                                                       │
│  │  └─ Toast: "Response submitted successfully"                        │
│  │                                                                       │
│  ├─ Verify Submission:                                                   │
│  │  └─ Back on analyst dashboard                                       │
│  │  └─ Company user now shows "Completed" or "Submitted" status        │
│  │  └─ May be removed from list or disabled                            │
│  │                                                                       │
│  └─ Logout: Done                                                         │
│                                                                           │
└──────────────────────────────────────────────────────────────────────────┘
```

---

## 🗺️ URL ROUTING MAP

### Admin Routes
```
NAVIGATION:
  GET  /esgadmin/company_users
       └─ List all company users for ESG Diagnostic

ASSIGNMENT:
  PATCH /esgadmin/company_users/:id/assign_analyst
        └─ params[:id] = analyst user ID
        └─ params[:company_user_id] = comma-separated user IDs
```

### Analyst Routes
```
DASHBOARD:
  GET  /analyst/dashboard
       └─ List all assigned company users

ASSESSMENT REVIEW:
  GET  /analyst/assessment/:company_user_id/edit_assessment/:user_type
       └─ Show assessment for editing/review
       └─ :user_type = "cii" (analyst view)

UPDATE ASSESSMENT:
  PATCH /analyst/assessment/:company_user_id/update_assessment
        └─ Save comments/updates

SUBMIT ASSESSMENT:
  PATCH /analyst/assessment/:company_user_id/submit_assessment
        └─ Final submission of review
```

---

## 📊 DATABASE SCHEMA RELEVANCE

### Tables Modified/Read

#### Users Table
```
Field               | Changes
─────────────────────────────────────────────
id                  | Read (identify user)
email               | Read (find user)
user_status         | UPDATED: 
                    │   ANALYST_ASSIGNED
                    │ → ASSESSMENT_VALIDATION_IN_PROGRESS
                    │ → ASSESSMENT_VALIDATION_COMPLETED
role_id             | Read (verify analyst role)
```

#### AssignAnalyst Table
```
Field               | Operation
─────────────────────────────────────────────
company_user_id     | Created/Updated
analyst_user_id     | Set to analyst's ID
analyst_name_id     | Set to analyst's ID
```

#### Answers Table
```
Field               | Changes
─────────────────────────────────────────────
user_id             | Read (company_user_id)
answer_type         | 'cii_user' (analyst answers)
corporate_governance| Updated with analyst comments
business_ethics     | Updated with analyst comments
risk_management     | Updated with analyst comments
submitted_at        | Set timestamp
```

---

## 🎯 TEST EXECUTION FLOWCHART

```
TEST SUITE: post_assessment_review.spec.js
├─ test.beforeAll
│  └─ Create browser page instance
│
├─ Test 1: Step 1 - Admin Assignment
│  ├─ Admin login (from previous test or do here)
│  ├─ Navigate /esgadmin/company_users
│  ├─ Search for company user
│  ├─ Click Assign button
│  ├─ Select analyst "Kishore Analyst"
│  ├─ Verify success toast
│  └─ Admin logout
│
├─ Test 2: Step 2 - Analyst Login & Dashboard
│  ├─ Analyst login (kishore.r+analyst@spritle.com)
│  ├─ Navigate /analyst/dashboard
│  ├─ Verify assigned company appears
│  ├─ Click View/Review link
│  └─ Verify assessment page loads
│
├─ Test 3: Step 3 - Add Comments
│  ├─ Get first aspect (e.g., Corporate Governance)
│  ├─ Expand aspect if needed
│  ├─ For each question (first 3):
│  │  ├─ Find comment field
│  │  └─ Fill with analyst comment
│  ├─ Click Save button
│  └─ Verify save success toast
│
├─ Test 4: Step 4 - Submit Review
│  ├─ Click Submit button
│  ├─ Handle confirmation modal if present
│  ├─ Verify submit success toast
│  └─ Verify redirect to /analyst/dashboard
│
├─ Test 5: Step 5 - Verify Completion
│  ├─ Verify on analyst dashboard
│  ├─ Check user status if visible
│  ├─ Verify button states updated (if applicable)
│  └─ Analyst logout
│
└─ test.afterAll
   └─ Close browser page
```

---

## 🔍 KEY SELECTORS TO FIND IN UI

### Admin ESG Diagnostic Page (`/esgadmin/company_users`)

| Element | What to Look For | Purpose |
|---------|------------------|---------|
| User Table | `<table>`, `data-testid="users-table"` | List of users |
| Company Name | `<td>` in table row | Identify correct user |
| Status Column | `<td>` for status | Show current status |
| Assign Button | Button with text "Assign" | Trigger assignment |
| Search Input | `<input>` field at top | Find specific user |
| Modal/Dialog | When Assign clicked | Select analyst |
| Analyst Dropdown | `<select>`, dropdown, combobox | Choose analyst |
| Confirm Button | Button in modal | Confirm assignment |
| Toast Message | `<div class="toast">` | Success confirmation |

### Analyst Dashboard (`/analyst/dashboard`)

| Element | What to Look For | Purpose |
|---------|------------------|---------|
| Page Title | `<h1>, <h2>` | Confirm on correct page |
| Users Table | Table with assigned users | List of assessments |
| Company Name | Table cell with name | Identify user |
| View Button | "View" or "Review" link | Access assessment |
| Status Badge | Status indicator | Show assignment status |

### Assessment Review Page (`/analyst/assessment/.../edit_assessment/...`)

| Element | What to Look For | Purpose |
|---------|------------------|---------|
| Company Name | Header display | Confirm correct user |
| Aspect Headers | "Corporate Governance", etc | Category sections |
| Questions | Questions under each aspect | Content to review |
| Answers | Already filled fields | Company user's answers |
| Comment Fields | `<textarea>`, empty | Analyst's review input |
| Save Button | "Save" button | Intermediate save |
| Submit Button | "Submit" button | Final submission |
| Success Toast | `<div class="toast">` | Confirmation messages |

---

## 💾 DATA FLOW & PAYLOADS

### Request 1: Admin Assign Analyst

```http
PATCH /esgadmin/company_users/123/assign_analyst HTTP/1.1
Content-Type: application/x-www-form-urlencoded

id=123&company_user_id=456,789&_method=patch&authenticity_token=xxx
```

**Response**: Redirect to `/esgadmin/company_users` with notice

### Request 2: Analyst Update Assessment

```http
PATCH /analyst/assessment/456/update_assessment HTTP/1.1
Content-Type: application/json

{
  "company_user_id": "456",
  "aspect_name": "corporate_governance",
  "user_answers": {
    "01": "Comment: Answer is comprehensive and well-documented",
    "02": "Comment: Need clarification on Q2",
    "03": "Comment: Good response"
  }
}
```

**Response**: JSON `{ success: true }` or status 200

### Request 3: Analyst Submit Review

```http
PATCH /analyst/assessment/456/submit_assessment HTTP/1.1
Content-Type: application/x-www-form-urlencoded

_method=patch&authenticity_token=xxx
```

**Response**: Redirect to `/analyst/dashboard` with notice

---

## ⏱️ TIMING & WAIT STRATEGIES

```
After Click                     | Wait For                    | Recommended Strategy
────────────────────────────────┼──────────────────────────────┼──────────────────────
Admin clicks Assign button      | Modal appears               | page.waitForSelector + timeout
Admin clicks Assign in modal     | Success toast appears       | expect(toast).toContainText + timeout
Analyst clicks Save button      | Toast appears + page updates | expect(toast) + waitForNavigation
Analyst clicks Submit button    | Dashboard loads             | page.waitForURL(/analyst\/dashboard/)
Analyst logs in                 | Dashboard loads             | page.waitForURL pattern
```

---

## 🔐 AUTHENTICATION & SESSION MANAGEMENT

### Session Persistence

```
Test Flow:
├─ Admin Login (Test 1)
│  └─ Session maintained throughout Test 1
│
├─ Admin Logout (end of Test 1)
│  └─ Session cleared
│
├─ Analyst Login (Test 2)
│  └─ New session created
│  └─ Session maintained through Tests 2-4
│
└─ Analyst Logout (end of Test 5)
   └─ Session cleared
```

### Credentials (from Env.js)

```javascript
// Admin
Env.ADMIN_EMAIL = process.env.ADMIN_EMAIL
Env.ADMIN_PASSWORD = process.env.ADMIN_PASSWORD

// Analyst
ANALYST_EMAIL = 'kishore.r+analyst@spritle.com'
ANALYST_PASSWORD = 'Spritle123@'
```

---

## 🎬 VISUAL STORYBOARD

### Admin Assignment
```
Screen 1: Admin Dashboard
  [User List Table]
  Company A | Status: Submitted | [Assign]
  Company B | Status: Submitted | [Assign]

         ↓ Click [Assign] on Company A ↓

Screen 2: Assignment Modal
  [Select Analyst]
  [ ] Admin User
  [ ] Regular User
  [✓] Kishore Analyst
  
  [Cancel] [Confirm]

         ↓ Click [Confirm] ↓

Screen 3: Success & Return
  ✅ "Successfully assigned"
  
  [User List Table Updated]
  Company A | Status: Assigned | [View]
```

### Analyst Review
```
Screen 1: Analyst Login
  [Email: kishore.r+analyst@spritle.com]
  [Password: ••••••••]
  [Login]

         ↓ Click Login ↓

Screen 2: Analyst Dashboard
  [Assigned Assessments]
  Company A | Status: Pending Review | [View]

         ↓ Click [View] ↓

Screen 3: Assessment Review
  [Company A Assessment]
  
  Category: Corporate Governance
    Q1: [Filled Answer] [Comment Field] 
    Q2: [Filled Answer] [Comment Field]
    
  Category: Business Ethics
    Q1: [Filled Answer] [Comment Field]
    
  [Save] [Submit]

         ↓ Add comments + Click [Save] ↓

Screen 4: Saved Confirmation
  ✅ "Assessment updated"
  
  Assessment still displayed with comments saved

         ↓ Click [Submit] ↓

Screen 5: Submission Confirmed
  ✅ "Response submitted successfully"
  
  Redirect to Dashboard

Screen 6: Updated Dashboard
  [Assigned Assessments]
  Company A | Status: Completed | [View/Disabled]
```

---

## 🔧 DEBUGGING TIPS

### If Assign Button Not Found
```javascript
// Try different selectors
page.locator('button:has-text("Assign")')
page.locator('[data-action="assign"]')
page.locator('button.assign-btn')
page.locator('a:has-text("Assign")')
// Check if it's in dropdown menu
page.locator('[role="menu"]').locator('text=Assign')
```

### If Analyst Dropdown Not Populated
```javascript
// Check if analyst exists
// SELECT * FROM users WHERE email = 'kishore.r+analyst@spritle.com' AND role IN (3, 'analyst');

// Try different selector
page.locator('select[name*="analyst"]')
page.locator('[data-testid="analyst-selector"]')
page.locator('input[role="combobox"]')
```

### If Comments Not Saving
```javascript
// Check network tab for error
// Verify aspect_name is correct
// Example aspect names: 'corporate_governance', 'business_ethics', 'risk_management'
// Try explicit wait for response
await page.waitForResponse(response => response.url().includes('update_assessment') && response.status() === 200)
```

---

## 📋 CHECKLIST FOR IMPLEMENTATION

### Pre-Implementation
- [ ] Read Rails controller code thoroughly
- [ ] Access running application at https://devcii2.spritle.com
- [ ] Login as admin and explore ESG Diagnostic page
- [ ] Login as analyst and explore dashboard
- [ ] Identify exact CSS selectors/IDs for all buttons and fields
- [ ] Test admin assignment flow manually
- [ ] Test analyst review flow manually

### During Implementation
- [ ] Create AdminESGDiagnosticPage.js with correct selectors
- [ ] Create AnalystDashboardPage.js with correct selectors
- [ ] Create AnalystAssessmentReviewPage.js with correct selectors
- [ ] Implement Test 1 (Admin Assignment)
- [ ] Test and debug Test 1
- [ ] Implement Test 2 (Analyst Login & Dashboard)
- [ ] Test and debug Test 2
- [ ] Implement Tests 3-5 (Comments & Submission)
- [ ] Run full suite and verify all tests pass
- [ ] Add console logging for debugging

### Post-Implementation
- [ ] Verify all assertions pass
- [ ] Check no hardcoded values
- [ ] Verify test data cleanup if needed
- [ ] Add comments to complex selectors
- [ ] Update documentation
- [ ] Share with team for review

---

**Document Version**: 1.0  
**Created**: January 9, 2026  
**Status**: Complete - Ready for Implementation  
**Next Step**: Inspect running application for exact UI selectors
