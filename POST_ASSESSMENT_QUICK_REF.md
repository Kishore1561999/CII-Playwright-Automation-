# Post-Assessment Automation - Quick Reference

**Purpose**: Quick lookup guide for post-assessment workflow automation  
**Date**: January 9, 2026  

---

## 📋 WORKFLOW SUMMARY

```
User Submission (Already Automated) ✅
         ↓
Admin Assignment (NEW - To Automate)
├─ Login
├─ Navigate ESG Diagnostic: /esgadmin/company_users
├─ Find company user
├─ Click Assign
├─ Select "Kishore Analyst"
├─ Confirm
└─ Logout

         ↓
Analyst Review (NEW - To Automate)
├─ Login: kishore.r+analyst@spritle.com / Spritle123@
├─ Navigate: /analyst/dashboard
├─ View assigned assessment
├─ Add comments to questions
├─ Save comments
├─ Submit review
└─ Logout
```

---

## 🔑 KEY CREDENTIALS

```
Admin (from Env.js):
  Email: ${Env.ADMIN_EMAIL}
  Password: ${Env.ADMIN_PASSWORD}

Analyst (Hardcoded):
  Email: kishore.r+analyst@spritle.com
  Password: Spritle123@
  Name: Kishore Analyst
```

---

## 📍 ROUTE MAPPING

| Screen | URL | Method |
|--------|-----|--------|
| ESG Diagnostic Dashboard | `/esgadmin/company_users` | GET |
| Assign Analyst | `/esgadmin/company_users/:id/assign_analyst` | PATCH |
| Analyst Dashboard | `/analyst/dashboard` | GET |
| Assessment Review | `/analyst/assessment/:id/edit_assessment/cii` | GET |
| Update Assessment | `/analyst/assessment/:id/update_assessment` | PATCH |
| Submit Assessment | `/analyst/assessment/:id/submit_assessment` | PATCH |

---

## 🎬 TEST CASES

### Test 1: Admin Assignment
```javascript
✓ Admin logs in
✓ Navigate to /esgadmin/company_users
✓ Search for company
✓ Click Assign button
✓ Select analyst
✓ Verify success toast
✓ Admin logs out
```

### Test 2: Analyst Dashboard
```javascript
✓ Analyst logs in (kishore.r+analyst@spritle.com)
✓ Navigate to /analyst/dashboard
✓ Find assigned company
✓ Click View/Review
✓ Verify assessment page loads
```

### Test 3: Add Comments
```javascript
✓ Get aspect sections
✓ Expand aspects
✓ Fill comment fields
✓ Click Save
✓ Verify save success
```

### Test 4: Submit Review
```javascript
✓ Click Submit button
✓ Handle confirmation modal
✓ Verify success toast
✓ Verify redirect to dashboard
```

### Test 5: Verify Completion
```javascript
✓ Verify on analyst dashboard
✓ Check user status
✓ Verify button states
✓ Analyst logs out
```

---

## 📁 FILES TO CREATE

```
playwright-automation/
├── pages/
│   ├── admin/
│   │   └── AdminESGDiagnosticPage.js ← Create
│   └── analyst/
│       ├── AnalystDashboardPage.js ← Create
│       └── AnalystAssessmentReviewPage.js ← Create
│
└── tests/
    └── e2e/
        └── analyst/
            └── post_assessment_review.spec.js ← Create
```

---

## 🎯 PAGE OBJECTS REQUIRED

### AdminESGDiagnosticPage Methods

```javascript
navigateToESGDiagnostic()
searchCompany(name)
getCompanyUserRow(name)
assignAnalyst(companyName, analystName)
getSuccessMessage()
verifyAssignmentSuccess()
```

### AnalystDashboardPage Methods

```javascript
navigateToAnalystDashboard()
verifyDashboardLoaded()
getAssignedUserRow(name)
getAssignedUsersCount()
clickViewAssessment(name)
```

### AnalystAssessmentReviewPage Methods

```javascript
verifyAssessmentPageLoaded(name)
clickEditMode()
getAspectByName(name)
expandAspect(element)
getQuestionsInAspect(element)
addCommentToQuestion(element, text)
saveAssessment()
submitReview()
addCommentsToMultipleQuestions(texts)
```

---

## 🔄 DATABASE UPDATES

### User Status Changes
```
ANALYST_ASSIGNED
  ↓ (After first update)
ASSESSMENT_VALIDATION_IN_PROGRESS
  ↓ (After submission)
ASSESSMENT_VALIDATION_COMPLETED
```

### Tables Modified
```
Users: user_status field
AssignAnalyst: company_user_id, analyst_user_id, analyst_name_id
Answers: Comments/updates, submitted_at timestamp
```

---

## 🔍 KEY SELECTORS TO IDENTIFY

### In Application (from code analysis)

```ruby
# Admin side
Route: /esgadmin/company_users (index)
Action: assign_analyst (PATCH)
Params: id (analyst), company_user_id (users to assign)

# Analyst side
Route: /analyst/dashboard (index)
Action: view assessment (/analyst/assessment/:id/edit_assessment/cii)
Update: /analyst/assessment/:id/update_assessment
Submit: /analyst/assessment/:id/submit_assessment
```

---

## ⚙️ TECHNICAL DETAILS

### Request Format: Analyst Update

```http
PATCH /analyst/assessment/456/update_assessment
Content-Type: application/json

{
  "company_user_id": "456",
  "aspect_name": "corporate_governance",
  "user_answers": { 
    "01": "comment...",
    "02": "comment..."
  }
}
```

### User Status Constants
```ruby
ANALYST_ASSIGNED = 'analyst_assigned'
ASSESSMENT_VALIDATION_IN_PROGRESS = 'assessment_validation_in_progress'
ASSESSMENT_VALIDATION_COMPLETED = 'assessment_validation_completed'

Answer Types:
CII_USER = 'cii_user' (analyst view/edit)
COMPANY_USER = 'company_user' (company view)
```

---

## 📊 UI ELEMENTS CHECKLIST

### Admin ESG Diagnostic Page
- [ ] Company users table
- [ ] Search input field
- [ ] Assign button (per row)
- [ ] Analyst selector dropdown/modal
- [ ] Confirm button
- [ ] Success toast message
- [ ] Pagination (if applicable)

### Analyst Dashboard
- [ ] Page title
- [ ] Assigned users table/list
- [ ] View/Review links
- [ ] Status indicators

### Assessment Review Page
- [ ] Company name header
- [ ] Category/Aspect sections
- [ ] Questions display
- [ ] Filled answers (read-only)
- [ ] Comment fields (empty)
- [ ] Save button
- [ ] Submit button
- [ ] Success messages

---

## 🚀 IMPLEMENTATION STEPS

### Step 1: Identify Selectors
- [ ] Access running app at https://devcii2.spritle.com
- [ ] Login as admin
- [ ] Inspect HTML on ESG Diagnostic page
- [ ] Document all selectors for buttons, fields, tables
- [ ] Logout and repeat for analyst side

### Step 2: Create Page Objects
- [ ] Create AdminESGDiagnosticPage.js
- [ ] Create AnalystDashboardPage.js
- [ ] Create AnalystAssessmentReviewPage.js
- [ ] Add methods as listed above

### Step 3: Write Tests
- [ ] Create post_assessment_review.spec.js
- [ ] Implement Test 1: Admin Assignment
- [ ] Implement Test 2: Analyst Dashboard
- [ ] Implement Test 3: Add Comments
- [ ] Implement Test 4: Submit Review
- [ ] Implement Test 5: Verify Completion

### Step 4: Debug & Refine
- [ ] Run tests and identify issues
- [ ] Adjust selectors as needed
- [ ] Add console logging for debugging
- [ ] Verify all tests pass consistently

### Step 5: Integration
- [ ] Chain with assessment test (if needed)
- [ ] Run both test suites together
- [ ] Verify data flows correctly
- [ ] Document any findings

---

## 💡 COMMON ISSUES & FIXES

| Issue | Solution |
|-------|----------|
| Assign button not found | Check for button text, class name, or data attribute |
| Analyst dropdown empty | Verify analyst user exists in DB |
| Assessment page not loading | Check URL format and ID parameters |
| Comments not saving | Verify aspect_name and payload format |
| Success message not appearing | Check toast selector and CSS class |
| Redirect not working | Use waitForURL with proper pattern |

---

## 📚 REFERENCE DOCUMENTS

- **POST_ASSESSMENT_AUTOMATION_PLAN.md** - Detailed implementation guide
- **POST_ASSESSMENT_VISUAL_FLOW.md** - Visual flowcharts and UI mapping
- This file - Quick reference

---

## ✅ ACCEPTANCE CRITERIA

- [ ] All 5 tests pass consistently
- [ ] No hardcoded user IDs or emails (use Env or variables)
- [ ] Proper waits and error handling
- [ ] Success/error messages verified
- [ ] Database state verified (user status changes)
- [ ] Integration with assessment workflow
- [ ] Can be run independently or chained
- [ ] Documentation complete
- [ ] Team review passed

---

## 🎯 NEXT ACTIONS

1. **Inspect Application**
   - Identify exact CSS selectors/IDs for buttons and fields
   - Document HTML structure

2. **Create Page Objects**
   - Write AdminESGDiagnosticPage.js
   - Write AnalystDashboardPage.js
   - Write AnalystAssessmentReviewPage.js

3. **Implement Tests**
   - Write post_assessment_review.spec.js
   - Debug each test case

4. **Validate**
   - Run tests multiple times
   - Verify reliability
   - Check data consistency

5. **Document**
   - Add comments to code
   - Update test documentation
   - Share with team

---

**Quick Reference Version**: 1.0  
**Created**: January 9, 2026  
**Status**: Ready for Development  
**Related Documents**:
- POST_ASSESSMENT_AUTOMATION_PLAN.md
- POST_ASSESSMENT_VISUAL_FLOW.md
