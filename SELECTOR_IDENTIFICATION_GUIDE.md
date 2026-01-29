# Selector Identification Guide

**Purpose**: Help identify exact CSS selectors from running application  
**Environment**: https://devcii2.spritle.com  
**Date**: January 9, 2026  

---

## 🔍 HOW TO IDENTIFY SELECTORS

### Method 1: Browser DevTools (Recommended)
1. Open application in browser
2. Right-click on element → **Inspect** (or F12)
3. Look at HTML for:
   - `id="something"` → Use `#something`
   - `class="btn btn-primary"` → Use `.btn-primary` or `[class*="btn"]`
   - `data-testid="assign"` → Use `[data-testid="assign"]`
   - `name="analyst"` → Use `[name="analyst"]`
4. Copy the selector and test in console: `document.querySelector('your-selector')`

### Method 2: Playwright Inspector
```bash
npx playwright codegen https://devcii2.spritle.com/esgadmin/company_users
```
This generates code as you interact with elements.

---

## 📍 ADMIN ESG DIAGNOSTIC PAGE

**URL**: `https://devcii2.spritle.com/esgadmin/company_users`

### Elements to Identify

| Element | Current Selector | Instructions |
|---------|-----------------|--------------|
| **Page Title** | `h1, [class*="page-title"]` | Look for "ESG Diagnostic" or "Company Users" heading |
| **Search Input** | `input[type="search"], input[placeholder*="search" i]` | Find the search/filter input field |
| **Company Users Table** | `table, [class*="table"]` | Locate the data table with company list |
| **Table Rows** | `table tbody tr` | Each row should be a company user |
| **Assign Button** | `button:has-text("Assign")` | Button in each row to assign analyst |
| **Analyst Dropdown** | `select, [class*="dropdown"]` | Select field or custom dropdown for analyst selection |
| **Confirm Button** | `button:has-text("Confirm")` | Button to confirm assignment |
| **Success Toast** | `[class*="alert"], [class*="toast"]` | Success message notification |

### Test Steps in Browser

1. Login as admin
2. Navigate to `/esgadmin/company_users`
3. In DevTools Console, run:
   ```javascript
   // Find page title
   document.querySelector('h1')?.textContent
   
   // Find search input
   document.querySelector('input[type="search"]')
   
   // Find table rows
   document.querySelectorAll('table tbody tr').length
   
   // Click first assign button
   document.querySelector('button:has-text("Assign")')?.click()
   ```

### Expected HTML Structure

```html
<!-- Page Title -->
<h1 class="page-heading">ESG Diagnostic</h1>

<!-- Search Input -->
<input type="search" placeholder="Search companies...">

<!-- Table -->
<table class="users-table">
  <thead>
    <tr><th>Company</th><th>Status</th><th>Actions</th></tr>
  </thead>
  <tbody>
    <!-- Each row -->
    <tr class="user-row">
      <td>Test Company</td>
      <td>Pending</td>
      <td>
        <button class="btn-assign">Assign</button>
      </td>
    </tr>
  </tbody>
</table>

<!-- Modal/Form (appears after clicking Assign) -->
<div class="modal" id="assignModal">
  <select class="analyst-select">
    <option>Kishore Analyst</option>
  </select>
  <button class="btn-confirm">Confirm</button>
</div>

<!-- Success Toast -->
<div class="toast alert-success">
  Assignment successful!
</div>
```

---

## 📍 ANALYST DASHBOARD PAGE

**URL**: `https://devcii2.spritle.com/analyst/dashboard`

### Elements to Identify

| Element | Current Selector | Instructions |
|---------|-----------------|--------------|
| **Page Title** | `h1, [class*="dashboard"]` | Look for "Analyst Dashboard" or similar |
| **Assigned Users List** | `table, [class*="list"]` | Table showing assigned assessments |
| **User Rows** | `table tbody tr` | Each row is an assigned assessment |
| **Company Name Cell** | `td:nth-child(1)` | First column with company name |
| **View/Review Link** | `a:has-text("View"), a:has-text("Review")` | Link to open assessment |
| **Status Badge** | `[class*="badge"], [class*="status"]` | Assessment status indicator |

### Test Steps in Browser

1. Login as analyst (kishore.r+analyst@spritle.com)
2. Navigate to `/analyst/dashboard`
3. In DevTools Console, run:
   ```javascript
   // Count assigned users
   document.querySelectorAll('table tbody tr').length
   
   // Get first company name
   document.querySelector('table tbody tr td')?.textContent
   
   // Click view button
   document.querySelector('a:has-text("View")')?.click()
   ```

### Expected HTML Structure

```html
<!-- Page Title -->
<h1>Analyst Dashboard</h1>

<!-- Table of Assigned Users -->
<table class="assigned-users-table">
  <thead>
    <tr>
      <th>Company Name</th>
      <th>Status</th>
      <th>Assigned Date</th>
      <th>Action</th>
    </tr>
  </thead>
  <tbody>
    <tr class="user-row">
      <td>Test Company</td>
      <td><span class="badge-info">Pending Review</span></td>
      <td>2024-01-09</td>
      <td>
        <a href="/analyst/assessment/123/edit_assessment/cii">View</a>
      </td>
    </tr>
  </tbody>
</table>
```

---

## 📍 ANALYST ASSESSMENT REVIEW PAGE

**URL**: `https://devcii2.spritle.com/analyst/assessment/:id/edit_assessment/cii`

### Elements to Identify

| Element | Current Selector | Instructions |
|---------|-----------------|--------------|
| **Company Header** | `h1, [class*="company"]` | Company name being reviewed |
| **Aspect Sections** | `[class*="aspect"], [class*="section"]` | Container for each aspect/category |
| **Aspect Title** | `h3, [class*="aspect-title"]` | Name of the aspect (e.g., "Corporate Governance") |
| **Expand Button** | `button:has-text("Expand")` | Button to expand aspect details |
| **Questions** | `[class*="question"]` | Individual question elements |
| **Question Text** | `span, p` | The question text |
| **Answer Text** | `[class*="answer"]` | Company's answer (read-only) |
| **Comment Field** | `textarea, input[type="text"]` | Where analyst adds comments |
| **Save Button** | `button:has-text("Save")` | Save button for comments |
| **Submit Button** | `button:has-text("Submit")` | Final submit button |
| **Success Message** | `[class*="alert"], [class*="toast"]` | Success notification |
| **Confirm Modal** | `[class*="modal"], [role="dialog"]` | Confirmation dialog |
| **Confirm Modal Button** | `button:has-text("Confirm")` | Button in confirmation modal |

### Test Steps in Browser

1. Login as analyst
2. Navigate to `/analyst/dashboard`
3. Click View on an assessment
4. In DevTools Console, run:
   ```javascript
   // Get company name
   document.querySelector('h1')?.textContent
   
   // Count aspect sections
   document.querySelectorAll('[class*="aspect"]').length
   
   // Get first question
   document.querySelector('[class*="question"]')?.textContent
   
   // Find comment field
   document.querySelector('textarea')
   
   // Add sample comment
   const ta = document.querySelector('textarea');
   ta.value = 'Sample analyst feedback';
   ta.dispatchEvent(new Event('input', { bubbles: true }));
   ```

### Expected HTML Structure

```html
<!-- Company Header -->
<h1 class="company-name">Test Company Ltd.</h1>

<!-- Aspect Section -->
<div class="aspect-section">
  <div class="aspect-header">
    <h3>Corporate Governance</h3>
    <button class="btn-expand">Expand</button>
  </div>
  
  <!-- Aspect Content (hidden by default) -->
  <div class="aspect-content" style="display: none;">
    
    <!-- Question Block -->
    <div class="question-block">
      <div class="question-text">
        <strong>Q1:</strong> What is your governance structure?
      </div>
      
      <div class="company-answer">
        <strong>Company Response:</strong>
        <p>Our company has...</p>
      </div>
      
      <!-- Analyst Comment -->
      <div class="analyst-comment">
        <label>Analyst Feedback:</label>
        <textarea class="comment-field" placeholder="Add your feedback..."></textarea>
      </div>
    </div>
    
    <!-- More questions... -->
  </div>
</div>

<!-- Buttons -->
<div class="action-buttons">
  <button class="btn-save">Save</button>
  <button class="btn-submit">Submit Review</button>
</div>

<!-- Confirmation Modal -->
<div class="modal modal-confirm" style="display: none;">
  <div class="modal-content">
    <h2>Confirm Submission</h2>
    <p>Are you sure you want to submit this review?</p>
    <button class="btn-confirm">Confirm</button>
    <button class="btn-cancel">Cancel</button>
  </div>
</div>

<!-- Success Toast -->
<div class="toast alert-success">
  Comments saved successfully!
</div>
```

---

## 🛠️ PLAYWRIGHT SELECTOR SYNTAX

### Common Patterns Used in Code

```javascript
// By element type
'button'
'input[type="text"]'
'textarea'
'select'
'a'

// By attribute
'[id="myId"]'
'[class="myClass"]'
'[name="myName"]'
'[data-testid="myTest"]'
'[placeholder="Search..."]'

// By text content (Playwright specific)
'button:has-text("Click me")'
'a:has-text("View")'

// By class patterns
'[class*="btn"]'        // contains 'btn'
'[class^="modal"]'      // starts with 'modal'
'[class$="active"]'     // ends with 'active'

// Combining (AND logic)
'button.primary'
'input[type="text"][name="email"]'

// Child selection
'table tbody tr'
'div > button'

// Nth child
'tr:nth-child(1)'
'td:nth-child(2)'
```

---

## 📝 UPDATING THE PAGE OBJECTS

### Step 1: Identify Selectors
1. Use browser DevTools or Playwright codegen
2. Document each selector you find
3. Test in browser console: `document.querySelector('your-selector')`

### Step 2: Update Files
Replace the selectors object in each page file:

**AdminESGDiagnosticPage.js** (line ~10)
```javascript
this.selectors = {
  pageTitle: 'YOUR_SELECTOR_HERE',
  searchInput: 'YOUR_SELECTOR_HERE',
  // ... etc
};
```

**AnalystDashboardPage.js** (line ~10)
```javascript
this.selectors = {
  pageTitle: 'YOUR_SELECTOR_HERE',
  assignedUsersList: 'YOUR_SELECTOR_HERE',
  // ... etc
};
```

**AnalystAssessmentReviewPage.js** (line ~10)
```javascript
this.selectors = {
  companyNameHeader: 'YOUR_SELECTOR_HERE',
  aspectSections: 'YOUR_SELECTOR_HERE',
  // ... etc
};
```

### Step 3: Test Selectors
Run individual tests and verify:
```bash
npx playwright test tests/e2e/analyst/post_assessment_review.spec.js --debug
```

---

## 🐛 DEBUGGING SELECTOR ISSUES

### Problem: Element Not Found
```
Error: locator.click: Timeout 5000ms waiting for locator
```

**Solution**:
1. Check if selector is correct: `document.querySelector('your-selector')`
2. Check if element is visible: `element.offsetParent !== null`
3. Check if there's loading delay: Add longer wait with `await page.waitForTimeout(1000)`

### Problem: Multiple Elements Match
```
Error: locator.click: Multiple elements matched
```

**Solution**:
1. Make selector more specific with `:nth-child()` or `:first-of-type`
2. Use `data-testid` or unique class combinations
3. Use parent-child selectors: `table tbody tr:first-child button`

### Problem: Element Exists But Not Interactable
```
Error: locator.click: Execution context was destroyed
```

**Solution**:
1. Element may be behind modal or loading spinner
2. Check `isVisible()` before interaction
3. Add wait for element to be enabled: `await page.locator(selector).isEnabled()`

---

## ✅ VERIFICATION CHECKLIST

After updating selectors, verify each:

- [ ] Admin ESG Diagnostic page loads with company table
- [ ] Search functionality works
- [ ] Can find company by name
- [ ] Assign button is clickable
- [ ] Analyst dropdown populates correctly
- [ ] Confirmation succeeds
- [ ] Success message appears

- [ ] Analyst dashboard loads with assigned users
- [ ] Analyst can find their assigned company
- [ ] View link navigates to assessment page
- [ ] Status indicators show correctly

- [ ] Assessment page loads with company name
- [ ] Aspect sections expand/collapse
- [ ] Questions are visible
- [ ] Comment fields are editable
- [ ] Save button submits comments
- [ ] Submit button shows confirmation modal
- [ ] Confirmation navigates back to dashboard

---

## 📞 QUICK REFERENCE

### Common Selectors in Rails Apps

```javascript
// Forms
'form'
'form.login-form'
'input[type="email"]'
'input[type="password"]'
'button[type="submit"]'

// Tables (Bootstrap)
'.table tbody tr'
'.table-striped tr'
'td:nth-child(n)'

// Modals (Bootstrap)
'.modal'
'.modal-content'
'.modal-header'
'.modal-body'
'.modal-footer'

// Alerts/Toasts
'.alert'
'.alert-success'
'.alert-danger'
'.toast'
'.toast-success'

// Buttons
'.btn'
'.btn-primary'
'.btn-secondary'
'[data-action="..."]:
```

---

## 🚀 NEXT STEPS

1. **Inspect Application**
   - Open https://devcii2.spritle.com
   - Login as admin
   - Navigate through each page (ESG Diagnostic, Analyst Dashboard, Assessment Review)
   - Document selectors using this guide

2. **Update Page Objects**
   - Replace placeholder selectors in all 3 page object files
   - Test each selector in browser console

3. **Run Tests**
   - Execute the test suite
   - Debug any selector-related failures
   - Refine selectors as needed

4. **Verify Reliability**
   - Run tests multiple times
   - Check consistency of selector matches
   - Add alternative selectors if needed

---

**Created**: January 9, 2026  
**Version**: 1.0  
**Status**: Ready for Implementation
