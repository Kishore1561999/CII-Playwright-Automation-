# Complete Test Execution Guide

**Date**: January 9, 2026  
**Purpose**: Automated test workflow for CII ESG Assessment

---

## 🎯 Test Execution Flow

```
┌─────────────────────────────────────────────────────────┐
│ 1. assessment.spec.js                                   │
│    ├─ Step 1: Company Registration                      │
│    ├─ Step 2: Admin Approval                            │
│    ├─ Step 3: Assessment Submission                     │
│    └─ Step 4: Verify Dashboard                          │
│    └─ Exports: TEST_COMPANY_NAME, TEST_COMPANY_EMAIL   │
└────────────────┬────────────────────────────────────────┘
                 │
                 ↓
┌─────────────────────────────────────────────────────────┐
│ 2. post_assessment_review.spec.js                        │
│    ├─ Test 1: Admin Assignment                          │
│    ├─ Test 2: Analyst Dashboard                         │
│    ├─ Test 3: Open Assessment                           │
│    ├─ Test 4: Add Comments                              │
│    └─ Test 5: Submit Review                             │
│    └─ Uses: TEST_COMPANY_NAME from env                  │
└────────────────┬────────────────────────────────────────┘
                 │
                 ↓
┌─────────────────────────────────────────────────────────┐
│ 3. delete_user.spec.js (CLEANUP)                        │
│    ├─ Step 1: Logout Current User                       │
│    ├─ Step 2: Admin Login                               │
│    ├─ Step 3: Navigate to Company Users                 │
│    ├─ Step 4: Search and Delete Company                 │
│    └─ Step 5: Verify Deletion & Logout                  │
│    └─ Uses: TEST_COMPANY_NAME from env                  │
└─────────────────────────────────────────────────────────┘
```

---

## 🚀 How to Run

### Option 1: Run All Tests in Sequence (RECOMMENDED)

```bash
npm test tests/e2e/company_user/assessment.spec.js tests/e2e/analyst/post_assessment_review.spec.js tests/e2e/cleanup/delete_user.spec.js
```

**What happens**:
1. Company creates account → Admin approves → Assessment submitted
2. Admin assigns analyst → Analyst reviews → Submits review
3. Company and all data are deleted (cleanup)

**Total Time**: ~10-15 minutes

---

### Option 2: Run Each Test Separately

```bash
# First: Company workflow
npm test tests/e2e/company_user/assessment.spec.js

# Second: Analyst review
npm test tests/e2e/analyst/post_assessment_review.spec.js

# Third: Cleanup
npm test tests/e2e/cleanup/delete_user.spec.js
```

⚠️ **Important**: Must run in this exact order!

---

### Option 3: Run with Debug Mode

```bash
# Run all with step-by-step debugging
npx playwright test tests/e2e/company_user/assessment.spec.js tests/e2e/analyst/post_assessment_review.spec.js tests/e2e/cleanup/delete_user.spec.js --debug

# Or with UI mode for visual inspection
npx playwright test tests/e2e/company_user/assessment.spec.js tests/e2e/analyst/post_assessment_review.spec.js tests/e2e/cleanup/delete_user.spec.js --ui
```

---

### Option 4: Run Only Specific Tests

```bash
# Only assessment (without cleanup)
npm test tests/e2e/company_user/assessment.spec.js

# Only analyst review (must run assessment first!)
npm test tests/e2e/analyst/post_assessment_review.spec.js

# Only cleanup (must run previous tests first!)
npm test tests/e2e/cleanup/delete_user.spec.js
```

---

## 📊 Test Files & Locations

```
playwright-automation/
├── tests/
│   └── e2e/
│       ├── company_user/
│       │   └── assessment.spec.js ✅ (1/3)
│       │       • Registration
│       │       • Admin Approval
│       │       • Assessment Submission
│       │       • Dashboard Verification
│       │
│       ├── analyst/
│       │   └── post_assessment_review.spec.js ✅ (2/3)
│       │       • Admin Assignment
│       │       • Analyst Dashboard Access
│       │       • Open Assessment for Review
│       │       • Add Comments
│       │       • Submit Review
│       │
│       └── cleanup/
│           └── delete_user.spec.js ✅ (3/3) - NEW
│               • Logout Current User
│               • Admin Login
│               • Navigate to Company Users
│               • Search and Delete Company
│               • Verify Deletion & Logout
```

---

## 🔄 Data Flow Between Tests

### assessment.spec.js → post_assessment_review.spec.js

**Variables Exported**:
```javascript
process.env.TEST_COMPANY_NAME = 'E2E_Company_1234567890';
process.env.TEST_COMPANY_EMAIL = 'e2e_user_1234567890@example.com';
```

**Used In post_assessment_review.spec.js**:
```javascript
const testData = {
  companyName: process.env.TEST_COMPANY_NAME, // Receives exported value
  companyEmail: process.env.TEST_COMPANY_EMAIL,
  // ...
};
```

### post_assessment_review.spec.js → delete_user.spec.js

**Same Environment Variables Used**:
```javascript
const testCompanyName = process.env.TEST_COMPANY_NAME;
// Used to search and delete the company
```

---

## ✅ Success Indicators

### assessment.spec.js ✓
- [x] Company registered successfully
- [x] Admin approved company
- [x] Assessment submitted successfully
- [x] Dashboard shows "Take Assessment" disabled
- [x] Dashboard shows "View Assessment" enabled

### post_assessment_review.spec.js ✓
- [x] Admin logged in and navigated to ESG Diagnostic
- [x] Company found and analyst assigned
- [x] Analyst logged in and viewed dashboard
- [x] Assessment page loaded with questions
- [x] Comments added to questions
- [x] Review submitted successfully
- [x] Analyst redirected to dashboard

### delete_user.spec.js ✓
- [x] Previous user logged out
- [x] Admin logged in
- [x] Company found in search
- [x] Company deleted successfully
- [x] Success message displayed
- [x] Admin logged out

---

## ⚠️ Common Issues & Solutions

### Issue 1: "Company not found in post_assessment_review.spec.js"
**Cause**: Environment variable not passed between tests  
**Solution**:
```bash
# Make sure you run all tests together:
npm test tests/e2e/company_user/assessment.spec.js tests/e2e/analyst/post_assessment_review.spec.js
# NOT separately
```

### Issue 2: "Analyst assignment failed"
**Cause**: Page selectors not updated from placeholder values  
**Solution**:
1. Open running app at https://devcii2.spritle.com
2. Follow SELECTOR_IDENTIFICATION_GUIDE.md
3. Update selectors in AdminESGDiagnosticPage.js

### Issue 3: "Delete failed - company not found"
**Cause**: Company name not matching or database not updated  
**Solution**:
1. Check that assessment.spec.js completed fully
2. Verify company exists in admin panel manually
3. Ensure delete_user.spec.js runs after post_assessment_review.spec.js

### Issue 4: "Tests timeout"
**Cause**: Network slow or app unresponsive  
**Solution**:
```bash
# Run with longer timeout:
npm test -- --timeout 60000  # 60 seconds
```

---

## 🔧 Configuration

### Modify Test Timing

**In each spec file**:
```javascript
test.setTimeout(120000); // 2 minutes per test
```

### Modify Credentials

**Analyst credentials** (in post_assessment_review.spec.js):
```javascript
const testData = {
  analystEmail: 'kishore.r+analyst@spritle.com',  // ← Change if needed
  analystPassword: 'Spritle123@',                  // ← Change if needed
};
```

**Admin credentials** (in Env.js):
```javascript
// From environment variables:
process.env.ADMIN_EMAIL
process.env.ADMIN_PASSWORD
```

---

## 📈 Test Reports

After running tests, check:

```
playwright-automation/
├── test-results/          # Playwright HTML reports
├── playwright-report/     # Detailed test output
├── allure-results/        # Allure test data
└── allure-report/         # Allure visual report
```

### View HTML Report
```bash
npx playwright show-report
```

### View Allure Report
```bash
npx allure serve allure-results
```

---

## 🎯 Recommended Workflow

### First Time Setup
```bash
# 1. Verify all selectors are updated in page objects
# 2. Run all tests with UI mode to watch execution
npx playwright test tests/e2e/company_user/assessment.spec.js tests/e2e/analyst/post_assessment_review.spec.js tests/e2e/cleanup/delete_user.spec.js --ui

# 3. Review results and fix any issues
# 4. Run with debug if failures occur
npx playwright test tests/e2e/company_user/assessment.spec.js tests/e2e/analyst/post_assessment_review.spec.js tests/e2e/cleanup/delete_user.spec.js --debug
```

### Regular Execution
```bash
# Full workflow with all tests
npm test tests/e2e/company_user/assessment.spec.js tests/e2e/analyst/post_assessment_review.spec.js tests/e2e/cleanup/delete_user.spec.js

# Then check report
npx playwright show-report
```

### CI/CD Pipeline (GitHub Actions)
```bash
# Tests run automatically in correct order
npm test

# Or explicitly
npm test -- e2e/company_user/assessment.spec.js e2e/analyst/post_assessment_review.spec.js e2e/cleanup/delete_user.spec.js
```

---

## 📝 Test Dependencies

| Test | Requires | Before | Cleanup |
|------|----------|--------|---------|
| assessment.spec.js | None | All | No (exports data) |
| post_assessment_review.spec.js | assessment.spec.js | delete_user.spec.js | No (exports data) |
| delete_user.spec.js | Both above | None | ✓ Yes (deletes company) |

---

## 🔐 Credentials Required

```
Admin:
  Email: ${ADMIN_EMAIL}           (from environment)
  Password: ${ADMIN_PASSWORD}     (from environment)

Analyst:
  Email: kishore.r+analyst@spritle.com
  Password: Spritle123@

Test Company:
  Auto-generated with timestamp
  Name: E2E_Company_${timestamp}
  Email: e2e_user_${timestamp}@example.com
```

---

## 📊 Expected Test Results

```
PASS  tests/e2e/company_user/assessment.spec.js (45s)
  Company User Assessment Workflow
    ✓ Step 1: Company Registration
    ✓ Step 2: Admin Approval  
    ✓ Step 3: Assessment Submission
    ✓ Step 4: Verify Dashboard After Submission

PASS  tests/e2e/analyst/post_assessment_review.spec.js (30s)
  Post-Assessment Review Workflow
    ✓ Test 1: Admin Login and Assign Analyst to Submitted Assessment
    ✓ Test 2: Analyst Login and View Assigned Assessment
    ✓ Test 3: Analyst Click View Assessment
    ✓ Test 4: Analyst Add Comments and Save Assessment
    ✓ Test 5: Analyst Submit Assessment Review and Verify Completion

PASS  tests/e2e/cleanup/delete_user.spec.js (15s)
  Cleanup: Delete Test Company User
    ✓ Step 1: Logout Current User If Logged In
    ✓ Step 2: Admin Login
    ✓ Step 3: Navigate to Company Users
    ✓ Step 4: Search and Delete Company
    ✓ Step 5: Verify Deletion and Logout

=====================================================
✓ 14 passed (1m 30s)
```

---

## 🚀 Quick Start Commands

```bash
# View all available tests
npm test -- --list

# Run full workflow
npm test tests/e2e/company_user/assessment.spec.js tests/e2e/analyst/post_assessment_review.spec.js tests/e2e/cleanup/delete_user.spec.js

# Run with UI (watch mode)
npx playwright test tests/e2e/company_user/assessment.spec.js tests/e2e/analyst/post_assessment_review.spec.js tests/e2e/cleanup/delete_user.spec.js --ui

# Generate report
npx playwright show-report

# Run single test file
npm test tests/e2e/company_user/assessment.spec.js
```

---

## ✨ Test Execution Complete

**Status**: ✅ All three test suites ready to execute  
**Created**: January 9, 2026  
**Last Updated**: January 9, 2026  

---

## 📞 Support

For issues or questions:
1. Check the issue in "Common Issues & Solutions" above
2. Run with `--debug` flag for step-by-step execution
3. Review browser console output in playwright-report
4. Check page object selectors in SELECTOR_IDENTIFICATION_GUIDE.md
