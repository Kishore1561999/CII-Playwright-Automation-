# Post-Assessment Submission Automation Plan
## ESG Diagnostic - Admin Assignment & Analyst Review Workflow

**Created**: January 9, 2026  
**Purpose**: Automation plan for post-assessment workflows (Admin Assignment → Analyst Review)  
**Status**: Ready for Implementation  

---

## 📋 WORKFLOW OVERVIEW

```
┌─────────────────────────────────────────────────────────────────┐
│                    POST-ASSESSMENT WORKFLOW                     │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│ Step 1: User Submits Assessment (Already Automated) ✅          │
│         └─> redirect to company_user/dashboard                 │
│                                                                  │
│ Step 2: Admin Login & Assignment (TO AUTOMATE) 🔄               │
│         └─> Navigate ESG Diagnostic Dashboard                  │
│         └─> Find submitted user record                         │
│         └─> Assign to Analyst                                  │
│         └─> Logout                                             │
│                                                                  │
│ Step 3: Analyst Login & Review (TO AUTOMATE) 🔄                │
│         └─> Navigate ESG Diagnostic Dashboard                  │
│         └─> View assigned user assessment                      │
│         └─> Add comments/review                                │
│         └─> Submit review                                      │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## 📌 TECHNICAL DETAILS FROM CODE ANALYSIS

### Admin Side: Assign Analyst Endpoint

**Route**: `PATCH /esgadmin/company_users/:id/assign_analyst`  
**Controller**: `Admin::CompanyUsersController#assign_analyst`  
**Named Route**: `admin_assign_analyst_path`

**Request Parameters**:
```ruby
params[:id]              # Analyst user ID (Kishore Analyst)
params[:company_user_id] # Comma-separated user IDs to assign (from form)
params[:reason]          # Optional: reason for rejection (not applicable here)
```

**What it does**:
1. Finds the analyst user: `User.find(params[:id])`
2. For each company_user_id in the list:
   - Finds or creates `AssignAnalyst` record
   - Updates analyst_user_id and analyst_name_id
   - Updates company user status to `ANALYST_ASSIGNED`
3. Sends email notification to analyst
4. Redirects back to admin company users list

**Database Model**: `AssignAnalyst`
- company_user_id (company user being reviewed)
- analyst_user_id (analyst assigned)
- analyst_name_id (analyst name reference)

---

### Analyst Side: Review & Assessment Update

**Routes**:
```ruby
GET    /analyst/assessment/:company_user_id/edit_assessment/:user_type
PATCH  /analyst/assessment/:company_user_id/update_assessment
PATCH  /analyst/assessment/:company_user_id/submit_assessment
```

**Controllers**: `Analyst::AssessmentController`

**Key Methods**:
1. `edit_assessment` - Show assessment for review
   - Loads company user
   - Loads questions and existing answers
   - Loads company score

2. `update_assessment` - Save analyst comments/changes
   - Receives aspect_name (e.g., "corporate_governance")
   - Receives user_answers (comments/updated answers)
   - Updates user_status to `ASSESSMENT_VALIDATION_IN_PROGRESS`
   - Updates Answer record with submitted_at timestamp

3. `submit_assessment` - Final submission of analyst review
   - Updates user_status to `ASSESSMENT_VALIDATION_COMPLETED`
   - Redirects to analyst_dashboard_path

**User Status Flow**:
```
ANALYST_ASSIGNED 
  → (After first update) ASSESSMENT_VALIDATION_IN_PROGRESS
  → (After submit) ASSESSMENT_VALIDATION_COMPLETED
```

---

### Analyst Dashboard

**Route**: `GET /analyst/dashboard`  
**Controller**: `Analyst::DashboardController#index`  
**View**: Displays list of assigned company users for review

**Data Logic**:
```ruby
company_user_ids = AssignAnalyst.where(analyst_user_id: current_user.id)
                                .pluck(:company_user_id)
@company_users = User.where(id: company_user_ids)
                     .order(created_at: :desc)
                     .paginate(page: params[:page], per_page: 10)
```

---

## 🎬 AUTOMATION PLAN - TEST CASES

### TEST SUITE: Post-Assessment Admin Assignment & Analyst Review

```
File Location: playwright-automation/tests/e2e/analyst/post_assessment_review.spec.js
Page Objects to Create:
  - AdminESGDiagnosticPage.js    (Admin ESG Diagnostic Dashboard)
  - AnalystDashboardPage.js      (Analyst Dashboard)
  - AnalystAssessmentReviewPage.js (Analyst Assessment Review)
```

---

## ✅ TEST CASE BREAKDOWN

### TEST 1: Admin Assignment Workflow

**Name**: `Step 1: Admin Navigates ESG Diagnostic and Assigns Assessment to Analyst`

**Flow**:
```javascript
test('Step 1: Admin Assigns Assessment to Analyst', async ({ page }) => {
    // 1. Login as Admin (already done from previous test)
    // 2. Navigate to ESG Diagnostic Dashboard
    
    await page.goto('/esgadmin/company_users');
    // Alternative: await page.click('a[href*="/esgadmin/company_users"]');
    
    // 3. Verify page loaded with company users table
    await expect(page.locator('table')).toBeVisible();
    // Or: await expect(page.locator('[data-testid="company-users-table"]')).toBeVisible();
    
    // 4. Find the company user record (search if needed)
    // The company email from previous test: companyEmail (e.g., e2e_user_1704802800@example.com)
    
    // Option A: Search for the user
    await page.fill('input[placeholder*="Search"]', companyEmail);
    await page.click('button[type="submit"]');
    await page.waitForLoadState('networkidle');
    
    // Option B: Scroll through paginated results
    // Look for row containing the company name or email
    
    // 5. Locate the specific user row in the table
    const userRow = page.locator(`tr:has-text("${companyName}")`);
    await expect(userRow).toBeVisible();
    
    // 6. Find the "Assign Analyst" button in that row
    const assignButton = userRow.locator('button:has-text("Assign")');
    // Or: const assignButton = userRow.locator('[data-action="assign"]');
    
    await assignButton.click();
    
    // 7. Modal/Dropdown opens for analyst selection
    await expect(page.locator('select[id*="analyst"]')).toBeVisible();
    // Or: await expect(page.locator('.analyst-selector')).toBeVisible();
    
    // 8. Select Analyst: Kishore Analyst
    // Method A: By name
    await page.selectOption('select[id*="analyst"]', { label: 'Kishore Analyst' });
    
    // Method B: By email or ID (depending on implementation)
    await page.selectOption('select#analyst_id', 'kishore.r+analyst@spritle.com');
    
    // 9. Click Confirm/Submit button in modal
    await page.click('button:has-text("Assign")')
    // Or: await page.click('button:has-text("Confirm")');
    
    // 10. Verify success message
    await expect(page.locator('div.toast, [data-testid="success-toast"]'))
        .toContainText('successfully assigned');
    
    // 11. Verify user row updated (status changed)
    // Status might show "Assigned to Analyst" or similar
    
    // 12. Logout Admin
    await page.click('a.nav-link.dropdown-toggle');
    await page.click('a:has-text("Log Out")');
    await page.locator('#modalLogout').waitFor({ state: 'visible' });
    await page.locator('#modalLogout').click('a:has-text("Yes")');
    
    // 13. Verify logout complete (redirect to sign-in)
    await page.waitForURL(/.*sign_in/, { timeout: 10000 });
});
```

---

### TEST 2: Analyst Login & Dashboard View

**Name**: `Step 2: Analyst Logs in and Views Assigned Assessment`

**Flow**:
```javascript
test('Step 2: Analyst Logs in and Views Assigned Assessment', async ({ page }) => {
    // 1. Login as Analyst
    const loginPage = new LoginPage(page);
    await loginPage.navigate('/users/sign_in');
    await loginPage.login(
        'kishore.r+analyst@spritle.com',  // Kishore Analyst email
        'Spritle123@'                      // Password
    );
    
    // 2. Verify login successful - should redirect to analyst dashboard
    await expect(page).toHaveURL(/.*analyst\/dashboard/);
    
    // 3. Verify Analyst Dashboard displays
    await page.waitForLoadState('networkidle');
    await expect(page.locator('h1, h2')).toContainText(/ESG Diagnostic|Assessment|Dashboard/i);
    
    // 4. Verify assigned user appears in list
    // Look for the company that was assigned
    const assignedUserRow = page.locator(`tr:has-text("${companyName}")`);
    await expect(assignedUserRow).toBeVisible();
    
    // 5. Verify company name is displayed
    await expect(assignedUserRow.locator('td')).toContainText(companyName);
    
    // 6. Click on the user record to view assessment
    // Method A: Click on company name link
    const viewLink = assignedUserRow.locator('a:has-text("View"), button:has-text("Review")');
    await viewLink.click();
    
    // Method B: Click "Edit" or "Review" button
    // await assignedUserRow.locator('button[data-action="review"]').click();
    
    // 7. Verify assessment page loads
    // Should show: company name, questions, answers already filled, comment fields
    await page.waitForLoadState('networkidle');
    
    // Assessment page elements
    await expect(page.locator('h1, h2')).toContainText(/Assessment|Review/i);
    await expect(page.locator('text=' + companyName)).toBeVisible();
    
    // 8. Verify questions/categories are displayed
    const questionsSection = page.locator('[data-testid="questions-container"], .questions-list');
    await expect(questionsSection).toBeVisible();
    
    // 9. Verify analyst can see filled-in answers
    // Answers are already filled from company user's submission
    const firstAnswer = page.locator('input[name*="answer"], textarea[name*="answer"]').first();
    await expect(firstAnswer).toHaveValue(/.+/);  // Has some value
    
    // 10. Verify comment/review fields are available (empty initially)
    const commentFields = page.locator('textarea[name*="comment"], textarea[placeholder*="comment"]');
    await expect(commentFields).toHaveCount(/.+/);
});
```

---

### TEST 3: Analyst Review - Add Comments & Update Assessment

**Name**: `Step 3: Analyst Reviews Assessment and Adds Comments`

**Flow**:
```javascript
test('Step 3: Analyst Adds Comments and Updates Assessment', async ({ page }) => {
    // 1. Analyst is on assessment review page (from previous test)
    // 2. Navigate to edit mode if needed
    const editButton = page.locator('button:has-text("Edit"), a:has-text("Edit Assessment")');
    if (await editButton.isVisible()) {
        await editButton.click();
        await page.waitForLoadState('networkidle');
    }
    
    // 3. Get first aspect/category (e.g., Corporate Governance)
    const firstAspect = page.locator('[data-aspect], .aspect-section').first();
    const aspectName = await firstAspect.locator('h3, .aspect-title').textContent();
    console.log(`Reviewing aspect: ${aspectName}`);
    
    // 4. Expand the aspect if collapsed
    const expandButton = firstAspect.locator('button[aria-expanded="false"]');
    if (await expandButton.isVisible()) {
        await expandButton.click();
        await page.waitForTimeout(500);
    }
    
    // 5. Locate all questions in this aspect
    const questions = firstAspect.locator('[data-question], .question-item');
    const questionCount = await questions.count();
    console.log(`Found ${questionCount} questions in ${aspectName}`);
    
    // 6. Add comments to a few questions
    // Iterate through first 2-3 questions
    for (let i = 0; i < Math.min(3, questionCount); i++) {
        const question = questions.nth(i);
        
        // Get question text
        const questionText = await question.locator('label, .question-text').first().textContent();
        console.log(`Processing question: ${questionText}`);
        
        // Find comment field for this question
        const commentField = question.locator('textarea[name*="comment"], input[name*="analyst_comment"]');
        
        if (await commentField.isVisible()) {
            // Add analyst comment
            const comment = `Analyst review: Question is clear and properly answered. ${i + 1}/3`;
            await commentField.fill(comment);
            console.log(`Added comment: ${comment}`);
        }
    }
    
    // 7. Save/Update button (Save assessment, not submit yet)
    const saveButton = page.locator('button:has-text("Save"), button:has-text("Update")');
    
    if (await saveButton.isVisible()) {
        await saveButton.click();
        
        // 8. Verify save success
        await expect(page.locator('[data-testid="success-toast"], .toast-success'))
            .toContainText(/saved|updated/i);
        
        await page.waitForTimeout(1000);
    }
    
    // 9. Verify comments were saved
    // Refresh or re-check the comment field
    const savedComment = await firstAspect.locator('textarea').first().inputValue();
    expect(savedComment).toContain('Analyst review');
});
```

---

### TEST 4: Analyst Submits Review

**Name**: `Step 4: Analyst Submits Assessment Review`

**Flow**:
```javascript
test('Step 4: Analyst Submits Assessment Review', async ({ page }) => {
    // 1. Analyst is on assessment review page with comments added
    // 2. Locate Submit button (different from Save)
    const submitButton = page.locator('button:has-text("Submit"), button:has-text("Complete Review")');
    
    await expect(submitButton).toBeVisible();
    
    // 3. Click Submit button
    await submitButton.click();
    
    // 4. Handle confirmation dialog if present
    const confirmModal = page.locator('[role="dialog"], .confirmation-modal');
    if (await confirmModal.isVisible()) {
        const confirmBtn = confirmModal.locator('button:has-text("Confirm"), button:has-text("Yes")');
        await confirmBtn.click();
    }
    
    // 5. Verify submission success
    // Should show success message
    await expect(page.locator('[data-testid="success-toast"], .toast'))
        .toContainText(/submitted|completed/i);
    
    // 6. Verify redirect back to analyst dashboard
    // or verification that status changed
    await page.waitForTimeout(2000);
    
    // Option A: Check URL changed to dashboard
    await expect(page).toHaveURL(/.*analyst\/dashboard/);
    
    // Option B: If on same page, check status changed
    // const statusBadge = page.locator('[data-testid="status"]');
    // await expect(statusBadge).toContainText('Completed|Submitted');
});
```

---

### TEST 5: Verify Full Workflow Completion

**Name**: `Step 5: Verify Complete Workflow State`

**Flow**:
```javascript
test('Step 5: Verify Workflow Completion and Status Updates', async ({ page }) => {
    // 1. Analyst on dashboard after submission
    await expect(page).toHaveURL(/.*analyst\/dashboard/);
    
    // 2. Verify the company user is still in list but with updated status
    const completedRow = page.locator(`tr:has-text("${companyName}")`);
    
    if (await completedRow.isVisible()) {
        // Status should show "Completed" or "Review Submitted" or similar
        const statusCell = completedRow.locator('td').last();
        // await expect(statusCell).toContainText(/Completed|Validation Completed/i);
        
        // Action might be disabled or changed
        const actionBtn = completedRow.locator('button[data-action="edit"]');
        // const isDisabled = await actionBtn.isDisabled();
        // expect(isDisabled).toBe(true);  // Should be disabled after submission
    }
    
    // 3. Verify database state (Optional - for assertions)
    // User status should be: ASSESSMENT_VALIDATION_COMPLETED
    // AssignAnalyst record should exist with correct analyst_user_id
    
    // 4. Logout analyst
    await page.click('a.nav-link.dropdown-toggle');
    await page.click('a:has-text("Log Out")');
    await page.locator('#modalLogout').waitFor({ state: 'visible' });
    await page.locator('#modalLogout').click('a:has-text("Yes")');
    
    // 5. Verify logout complete
    await page.waitForURL(/.*sign_in/, { timeout: 10000 });
    
    console.log('✅ Post-Assessment Workflow Completed Successfully');
});
```

---

## 📄 PAGE OBJECTS TO CREATE

### 1. AdminESGDiagnosticPage.js

```javascript
// Location: playwright-automation/pages/admin/AdminESGDiagnosticPage.js

class AdminESGDiagnosticPage extends BasePage {
    
    // Locators
    get companyUsersTable() {
        return this.page.locator('table tbody');
    }
    
    get searchInput() {
        return this.page.locator('input[placeholder*="Search"], input[name*="search"]');
    }
    
    get searchButton() {
        return this.page.locator('button:has-text("Search")');
    }
    
    get paginationNext() {
        return this.page.locator('a:has-text("Next"), button[aria-label*="next"]');
    }
    
    // Methods
    async navigateToESGDiagnostic() {
        await this.page.goto('/esgadmin/company_users');
        await this.page.waitForLoadState('networkidle');
    }
    
    async searchCompany(companyName) {
        await this.searchInput.fill(companyName);
        await this.searchButton.click();
        await this.page.waitForLoadState('networkidle');
    }
    
    async getCompanyUserRow(companyName) {
        return this.page.locator(`tr:has-text("${companyName}")`);
    }
    
    async assignAnalyst(companyName, analystName) {
        const row = await this.getCompanyUserRow(companyName);
        const assignBtn = row.locator('button:has-text("Assign")');
        
        await assignBtn.click();
        await this.page.waitForTimeout(500);
        
        // Select analyst from dropdown
        const analystSelect = this.page.locator('select[name*="analyst"]');
        await analystSelect.selectOption({ label: analystName });
        
        // Click confirm
        const confirmBtn = this.page.locator('button:has-text("Assign"), button:has-text("Confirm")').last();
        await confirmBtn.click();
    }
    
    async getSuccessMessage() {
        return this.page.locator('[data-testid="success-toast"], .toast-success, .alert-success');
    }
    
    async verifyAssignmentSuccess() {
        const toast = await this.getSuccessMessage();
        await expect(toast).toContainText('successfully assigned');
    }
}

module.exports = AdminESGDiagnosticPage;
```

---

### 2. AnalystDashboardPage.js

```javascript
// Location: playwright-automation/pages/analyst/AnalystDashboardPage.js

class AnalystDashboardPage extends BasePage {
    
    // Locators
    get assignedUsersList() {
        return this.page.locator('table tbody tr');
    }
    
    get pageTitle() {
        return this.page.locator('h1, h2');
    }
    
    // Methods
    async navigateToAnalystDashboard() {
        await this.page.goto('/analyst/dashboard');
        await this.page.waitForLoadState('networkidle');
    }
    
    async verifyDashboardLoaded() {
        await expect(this.pageTitle).toContainText(/Dashboard|Assessment|Diagnostic/i);
    }
    
    async getAssignedUserRow(companyName) {
        return this.page.locator(`tr:has-text("${companyName}")`);
    }
    
    async getAssignedUsersCount() {
        const rows = await this.assignedUsersList.count();
        return rows;
    }
    
    async clickViewAssessment(companyName) {
        const row = await this.getAssignedUserRow(companyName);
        const viewLink = row.locator('a:has-text("View"), a:has-text("Review"), button:has-text("View")');
        
        await viewLink.click();
        await this.page.waitForLoadState('networkidle');
    }
}

module.exports = AnalystDashboardPage;
```

---

### 3. AnalystAssessmentReviewPage.js

```javascript
// Location: playwright-automation/pages/analyst/AnalystAssessmentReviewPage.js

class AnalystAssessmentReviewPage extends BasePage {
    
    // Locators
    get editButton() {
        return this.page.locator('button:has-text("Edit")');
    }
    
    get aspectSections() {
        return this.page.locator('[data-aspect], .aspect-section');
    }
    
    get commentFields() {
        return this.page.locator('textarea[name*="comment"], textarea[placeholder*="comment"]');
    }
    
    get saveButton() {
        return this.page.locator('button:has-text("Save"), button:has-text("Update")');
    }
    
    get submitButton() {
        return this.page.locator('button:has-text("Submit"), button:has-text("Complete")');
    }
    
    get successToast() {
        return this.page.locator('[data-testid="success-toast"], .toast-success, .alert-success');
    }
    
    // Methods
    async verifyAssessmentPageLoaded(companyName) {
        await expect(this.page.locator('text=' + companyName)).toBeVisible();
        await expect(this.aspectSections.first()).toBeVisible();
    }
    
    async clickEditMode() {
        await this.editButton.click();
        await this.page.waitForTimeout(500);
    }
    
    async getAspectByName(aspectName) {
        return this.page.locator(`[data-aspect="${aspectName}"], :has-text("${aspectName}")`);
    }
    
    async expandAspect(aspectElement) {
        const expandBtn = aspectElement.locator('button[aria-expanded="false"]');
        if (await expandBtn.isVisible()) {
            await expandBtn.click();
            await this.page.waitForTimeout(500);
        }
    }
    
    async getQuestionsInAspect(aspectElement) {
        return aspectElement.locator('[data-question], .question-item');
    }
    
    async addCommentToQuestion(questionElement, comment) {
        const commentField = questionElement.locator('textarea[name*="comment"]');
        
        if (await commentField.isVisible()) {
            await commentField.fill(comment);
        }
    }
    
    async saveAssessment() {
        await this.saveButton.click();
        await expect(this.successToast).toContainText(/saved|updated/i);
        await this.page.waitForTimeout(1000);
    }
    
    async submitReview() {
        await this.submitButton.click();
        
        // Handle confirmation modal if present
        const confirmModal = this.page.locator('[role="dialog"]');
        if (await confirmModal.isVisible()) {
            const confirmBtn = confirmModal.locator('button:has-text("Confirm"), button:has-text("Yes")');
            await confirmBtn.click();
        }
        
        await expect(this.successToast).toContainText(/submitted|completed/i);
    }
    
    async addCommentsToMultipleQuestions(commentTexts) {
        const aspects = await this.aspectSections.count();
        
        for (let i = 0; i < Math.min(aspects, commentTexts.length); i++) {
            const aspect = this.aspectSections.nth(i);
            await this.expandAspect(aspect);
            
            const questions = await this.getQuestionsInAspect(aspect);
            const questionCount = await questions.count();
            
            for (let j = 0; j < Math.min(1, questionCount); j++) {
                const question = questions.nth(j);
                await this.addCommentToQuestion(question, commentTexts[i]);
            }
        }
    }
}

module.exports = AnalystAssessmentReviewPage;
```

---

## 📝 FULL TEST SUITE FILE STRUCTURE

```javascript
// File: playwright-automation/tests/e2e/analyst/post_assessment_review.spec.js

const { test, expect } = require('@playwright/test');
const LoginPage = require('../../../pages/common/LoginPage');
const AdminESGDiagnosticPage = require('../../../pages/admin/AdminESGDiagnosticPage');
const AnalystDashboardPage = require('../../../pages/analyst/AnalystDashboardPage');
const AnalystAssessmentReviewPage = require('../../../pages/analyst/AnalystAssessmentReviewPage');
const Env = require('../../../utils/Env');

// Run tests in serial mode
test.describe.configure({ mode: 'serial' });

test.describe('Post-Assessment: Admin Assignment & Analyst Review', () => {
    let page;
    
    // Data from previous assessment test
    const analystEmail = 'kishore.r+analyst@spritle.com';
    const analystPassword = 'Spritle123@';
    const analystName = 'Kishore Analyst';
    
    // These would come from the assessment test
    // For now, we'll use test data
    const companyEmail = `test_company_${Date.now()}@example.com`;
    const companyName = `TestCompany_${Date.now()}`;
    
    test.beforeAll(async ({ browser }) => {
        page = await browser.newPage();
    });
    
    test.afterAll(async () => {
        await page.close();
    });
    
    test('Step 1: Admin Assigns Assessment to Analyst', async () => {
        // ... Implementation from TEST 1 above
    });
    
    test('Step 2: Analyst Logs in and Views Assigned Assessment', async () => {
        // ... Implementation from TEST 2 above
    });
    
    test('Step 3: Analyst Adds Comments and Updates Assessment', async () => {
        // ... Implementation from TEST 3 above
    });
    
    test('Step 4: Analyst Submits Assessment Review', async () => {
        // ... Implementation from TEST 4 above
    });
    
    test('Step 5: Verify Workflow Completion', async () => {
        // ... Implementation from TEST 5 above
    });
});
```

---

## 🔧 KEY UI ELEMENTS TO IDENTIFY

### Admin ESG Diagnostic Page
- [ ] Company users table/list
- [ ] Search input field
- [ ] "Assign" button per row
- [ ] Analyst selector dropdown (modal or inline)
- [ ] Confirm button in modal
- [ ] Success toast/alert
- [ ] Pagination (if applicable)

### Analyst Dashboard
- [ ] Page title verification
- [ ] Assigned users table
- [ ] "View" or "Review" links per row
- [ ] Status column showing assignment

### Assessment Review Page
- [ ] Company name display
- [ ] Category/Aspect sections (expandable)
- [ ] Questions list
- [ ] Filled-in answers (from company user)
- [ ] Comment fields (one per question or per category)
- [ ] Save button (intermediate save)
- [ ] Submit button (final submission)
- [ ] Success messages/toasts

---

## ⚙️ ENVIRONMENT & CREDENTIALS

### Test Data Setup
```javascript
const testData = {
    admin: {
        email: Env.ADMIN_EMAIL,
        password: Env.ADMIN_PASSWORD
    },
    analyst: {
        email: 'kishore.r+analyst@spritle.com',
        password: 'Spritle123@'
    },
    company: {
        name: `TestCompany_${Date.now()}`,
        email: `test_${Date.now()}@example.com`
        // Other fields from assessment test
    }
};
```

### Prerequisites
- Assessment submission test must pass first (creates company user)
- Analyst user "Kishore Analyst" must exist in database
- ESG Diagnostic subscription must be active for company user

---

## 📊 STATUS & USER STATES

### User Status Transitions (Analyst Review Flow)

```
ANALYST_ASSIGNED
        ↓
(After first update - analyst clicks Save)
        ↓
ASSESSMENT_VALIDATION_IN_PROGRESS
        ↓
(After analyst clicks Submit)
        ↓
ASSESSMENT_VALIDATION_COMPLETED
```

### Database Records Created/Updated

1. **AssignAnalyst** table
   - company_user_id: [submitted user ID]
   - analyst_user_id: [Kishore Analyst ID]
   - analyst_name_id: [Kishore Analyst ID]

2. **User** table update
   - user.user_status: 'ANALYST_ASSIGNED' → 'ASSESSMENT_VALIDATION_IN_PROGRESS' → 'ASSESSMENT_VALIDATION_COMPLETED'

3. **Answer** table (analyst answers)
   - May create new Answer record with analyst comments
   - Or update existing with submitted_at timestamp

---

## 🚨 COMMON ISSUES & TROUBLESHOOTING

### Issue 1: Analyst Assignment Modal Not Appearing
**Solution**: Check if button click is working, add delay before modal check
```javascript
await assignBtn.click();
await page.waitForTimeout(1000);  // Allow modal to render
await expect(page.locator('.modal')).toBeVisible();
```

### Issue 2: Analyst Not Found in Dropdown
**Solution**: Verify analyst user exists and is active in database
```ruby
# In Rails console:
User.where(email: 'kishore.r+analyst@spritle.com').first
```

### Issue 3: Assessment Page Not Loading
**Solution**: Check URL format and verify company_user_id is correct
```javascript
// Verify URL pattern
await page.goto(`/analyst/assessment/${company_user_id}/edit_assessment/cii`);
```

### Issue 4: Comments Not Saving
**Solution**: Ensure aspect_name and user_answers are correctly formatted
```javascript
// Check network request payload
// Should include: aspect_name, user_answers, company_user_id
```

---

## 📋 INTEGRATION WITH EXISTING TESTS

### Dependency Chain
```
assessment.spec.js (Step 1-4: Registration → Submission)
           ↓
           ↓ (Uses companyEmail, companyName, companyId)
           ↓
post_assessment_review.spec.js (Step 1-5: Admin Assignment → Analyst Review)
```

### Sharing Test Data
```javascript
// Option 1: Use context/fixtures
test.describe('Workflows', () => {
    let sharedData = {};
    
    test('assessment workflow', async () => {
        sharedData.companyId = company_user_id;
        sharedData.companyEmail = companyEmail;
    });
    
    test('analyst review workflow', async () => {
        // Use sharedData
    });
});

// Option 2: Use beforeAll at project level
// Option 3: Database queries to find latest company user
```

---

## ✅ ACCEPTANCE CRITERIA

- [ ] Admin can navigate to ESG Diagnostic dashboard
- [ ] Admin can find submitted company user record
- [ ] Admin can assign analyst to company user
- [ ] Assignment success message appears
- [ ] Analyst receives notification (email)
- [ ] Analyst can login
- [ ] Analyst dashboard shows assigned user
- [ ] Analyst can view submitted assessment
- [ ] Analyst can add comments to assessment questions
- [ ] Analyst can save comments (intermediate save)
- [ ] Analyst can submit review (final submission)
- [ ] User status updates correctly in database
- [ ] Success messages appear at each step
- [ ] Redirects happen correctly after each action

---

## 📌 TECHNICAL REFERENCE

### Important Constants (from Rails code)
```ruby
# User Status Values
ANALYST_ASSIGNED = 'analyst_assigned'
ASSESSMENT_VALIDATION_IN_PROGRESS = 'assessment_validation_in_progress'
ASSESSMENT_VALIDATION_COMPLETED = 'assessment_validation_completed'

# Answer Types
CII_USER = 'cii_user'
COMPANY_USER = 'company_user'

# Access Restrictions
ANALYST_ANSWER_RESTRICTION_STATUS = [
    'assessment_validation_completed',
    'analyst_assigned'  # Might prevent edit until status changes
]
```

---

## 🎯 NEXT STEPS

1. **Identify exact UI selectors** in Admin ESG Diagnostic page
   - Find company users table structure
   - Find "Assign" button/action location
   - Find analyst dropdown implementation

2. **Identify exact UI selectors** in Analyst Dashboard
   - Find assigned users table
   - Find "View/Review" link/button

3. **Identify exact UI selectors** in Assessment Review page
   - Find comment fields (per question or per category)
   - Find save vs submit button distinction
   - Find success message elements

4. **Create page objects** with correct selectors

5. **Implement test suite** with detailed comments

6. **Debug and refine** based on actual UI behavior

---

## 📚 FILES TO CREATE

| File | Type | Purpose |
|------|------|---------|
| `pages/admin/AdminESGDiagnosticPage.js` | Page Object | Admin ESG dashboard interactions |
| `pages/analyst/AnalystDashboardPage.js` | Page Object | Analyst dashboard interactions |
| `pages/analyst/AnalystAssessmentReviewPage.js` | Page Object | Assessment review interactions |
| `tests/e2e/analyst/post_assessment_review.spec.js` | Test Suite | Full workflow tests |

---

**Document Version**: 1.0  
**Created**: January 9, 2026  
**Status**: Ready for Implementation  
**Next Step**: Identify exact UI selectors in running application, then implement page objects and tests
