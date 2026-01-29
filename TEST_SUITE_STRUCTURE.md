# Test Suite Structure & Flow

**Date**: January 9, 2026

---

## 📂 Complete File Organization

```
CII_Playwright_Automation/
│
├── 📄 Documentation Files
│   ├── RUN_TESTS.md ⭐ (QUICK START)
│   ├── COMPLETE_TEST_EXECUTION_GUIDE.md (DETAILED)
│   ├── IMPLEMENTATION_COMPLETE.md
│   ├── POST_ASSESSMENT_AUTOMATION_PLAN.md
│   ├── POST_ASSESSMENT_VISUAL_FLOW.md
│   ├── POST_ASSESSMENT_QUICK_REF.md
│   ├── SELECTOR_IDENTIFICATION_GUIDE.md
│   └── TEST_EXECUTION_FLOW.md
│
└── playwright-automation/
    │
    ├── pages/ (Page Objects)
    │   ├── admin/
    │   │   ├── AdminDashboardPage.js (existing)
    │   │   ├── AdminCompanyUsersPage.js (existing)
    │   │   └── AdminESGDiagnosticPage.js ✅ NEW
    │   │
    │   ├── analyst/
    │   │   ├── AnalystDashboardPage.js ✅ NEW
    │   │   └── AnalystAssessmentReviewPage.js ✅ NEW
    │   │
    │   ├── common/
    │   │   └── LoginPage.js (existing)
    │   │
    │   └── company_user/
    │       ├── RegistrationPage.js (existing)
    │       ├── DashboardPage.js (existing)
    │       └── AssessmentPage.js (existing)
    │
    └── tests/e2e/
        │
        ├── company_user/
        │   └── assessment.spec.js ⭐ MODIFIED
        │       (Removed delete from afterAll)
        │       (Exports TEST_COMPANY_NAME env var)
        │
        ├── analyst/
        │   └── post_assessment_review.spec.js ✅ NEW
        │       (Uses TEST_COMPANY_NAME from env)
        │       (5 complete test cases)
        │
        └── cleanup/
            └── delete_user.spec.js ✅ NEW
                (Uses TEST_COMPANY_NAME from env)
                (Deletes test company - final cleanup)
```

---

## 🔄 Test Execution Sequence

### PHASE 1: Company Workflow (assessment.spec.js)

```
┌─────────────────────────────────────────┐
│ STEP 1: Company Registration            │
├─────────────────────────────────────────┤
│ Action: User creates company account    │
│ User: Company Employee                  │
│ Result: Account pending approval        │
└──────────────┬──────────────────────────┘
               │
               ↓
┌─────────────────────────────────────────┐
│ STEP 2: Admin Approval                  │
├─────────────────────────────────────────┤
│ Action: Admin approves company          │
│ User: Admin                             │
│ Result: Company account activated       │
└──────────────┬──────────────────────────┘
               │
               ↓
┌─────────────────────────────────────────┐
│ STEP 3: Assessment Submission           │
├─────────────────────────────────────────┤
│ Action: User completes & submits assess │
│ User: Company Employee                  │
│ Result: Assessment submitted, awaiting  │
│         analyst review                  │
│ Output: TEST_COMPANY_NAME env var       │
└──────────────┬──────────────────────────┘
               │
               ↓
┌─────────────────────────────────────────┐
│ STEP 4: Dashboard Verification          │
├─────────────────────────────────────────┤
│ Action: Verify button states changed    │
│ Check: Take Assessment = Disabled       │
│        View Assessment = Enabled        │
│ Result: Ready for analyst review        │
└─────────────────────────────────────────┘

⏱️ Duration: ~45 minutes
✅ Success: All 4 tests pass
```

---

### PHASE 2: Analyst Review (post_assessment_review.spec.js)

```
┌──────────────────────────────────────────┐
│ TEST 1: Admin Assignment                 │
├──────────────────────────────────────────┤
│ ├─ Step 1: Admin logs in                │
│ ├─ Step 2: Navigate to ESG Diagnostic   │
│ ├─ Step 3: Search for company           │
│ ├─ Step 4: Assign analyst               │
│ ├─ Step 5: Verify assignment success    │
│ └─ Step 6: Admin logs out                │
│ Input: TEST_COMPANY_NAME from env       │
└──────────────┬───────────────────────────┘
               │
               ↓
┌──────────────────────────────────────────┐
│ TEST 2: Analyst Dashboard                │
├──────────────────────────────────────────┤
│ ├─ Step 1: Analyst logs in              │
│ ├─ Step 2: View analyst dashboard       │
│ ├─ Step 3: Verify assignment in list    │
│ └─ Step 4: Verify company displayed     │
│ Input: TEST_COMPANY_NAME from env       │
└──────────────┬───────────────────────────┘
               │
               ↓
┌──────────────────────────────────────────┐
│ TEST 3: Open Assessment                  │
├──────────────────────────────────────────┤
│ ├─ Step 1: Ensure on dashboard          │
│ ├─ Step 2: Click View assessment        │
│ ├─ Step 3: Verify page loaded           │
│ └─ Step 4: Expand sections              │
└──────────────┬───────────────────────────┘
               │
               ↓
┌──────────────────────────────────────────┐
│ TEST 4: Add Comments                     │
├──────────────────────────────────────────┤
│ ├─ Step 1: Get assessment ready         │
│ ├─ Step 2: Get aspect sections          │
│ ├─ Step 3: Add comments to questions    │
│ ├─ Step 4: Save changes                 │
│ └─ Step 5: Verify save success          │
└──────────────┬───────────────────────────┘
               │
               ↓
┌──────────────────────────────────────────┐
│ TEST 5: Submit Review                    │
├──────────────────────────────────────────┤
│ ├─ Step 1: On assessment page           │
│ ├─ Step 2: Click submit button          │
│ ├─ Step 3: Handle confirmation modal    │
│ ├─ Step 4: Verify submission success    │
│ ├─ Step 5: Verify redirect to dashboard │
│ └─ Step 6: Analyst logs out             │
└──────────────────────────────────────────┘

⏱️ Duration: ~30 minutes
✅ Success: All 5 tests pass
```

---

### PHASE 3: Cleanup (delete_user.spec.js)

```
┌──────────────────────────────────────────┐
│ STEP 1: Logout Current User              │
├──────────────────────────────────────────┤
│ Action: Logout analyst if still logged in
└──────────────┬───────────────────────────┘
               │
               ↓
┌──────────────────────────────────────────┐
│ STEP 2: Admin Login                      │
├──────────────────────────────────────────┤
│ Action: Admin logs in                    │
└──────────────┬───────────────────────────┘
               │
               ↓
┌──────────────────────────────────────────┐
│ STEP 3: Navigate to Company Users        │
├──────────────────────────────────────────┤
│ Action: Go to /esgadmin/company_users    │
└──────────────┬───────────────────────────┘
               │
               ↓
┌──────────────────────────────────────────┐
│ STEP 4: Search and Delete Company        │
├──────────────────────────────────────────┤
│ ├─ Search for TEST_COMPANY_NAME         │
│ ├─ Find company row                     │
│ ├─ Click delete button                  │
│ └─ Verify deletion success               │
│ Input: TEST_COMPANY_NAME from env       │
└──────────────┬───────────────────────────┘
               │
               ↓
┌──────────────────────────────────────────┐
│ STEP 5: Verify & Logout                  │
├──────────────────────────────────────────┤
│ ├─ Refresh page                         │
│ ├─ Verify company deleted               │
│ └─ Admin logs out                        │
└──────────────────────────────────────────┘

⏱️ Duration: ~15 minutes
✅ Success: All 5 steps pass
```

---

## 💾 Data Flow & Environment Variables

```
assessment.spec.js
    │
    ├─ Creates: companyName = "E2E_Company_1234567890"
    ├─ Creates: companyEmail = "e2e_user_1234567890@example.com"
    │
    └─ Exports (afterAll):
       ├─ process.env.TEST_COMPANY_NAME
       └─ process.env.TEST_COMPANY_EMAIL
           │
           ↓ (Passed to)
           │
       post_assessment_review.spec.js
           │
           ├─ Reads: TEST_COMPANY_NAME
           ├─ Reads: TEST_COMPANY_EMAIL
           │
           └─ Uses for:
              ├─ Finding company in admin ESG Diagnostic
              ├─ Assigning analyst
              └─ (Also passes to next test)
                  │
                  ↓ (Passed to)
                  │
              delete_user.spec.js
                  │
                  ├─ Reads: TEST_COMPANY_NAME
                  │
                  └─ Uses for:
                     ├─ Searching company in admin panel
                     ├─ Deleting company
                     └─ Verifying deletion
```

---

## 📊 Test Summary Table

| Phase | File | Tests | Duration | Status | Output |
|-------|------|-------|----------|--------|--------|
| 1️⃣ | assessment.spec.js | 4 | ~45min | ✅ New | TEST_COMPANY_NAME |
| 2️⃣ | post_assessment_review.spec.js | 5 | ~30min | ✅ New | Review submitted |
| 3️⃣ | delete_user.spec.js | 5 | ~15min | ✅ New | Company deleted |
| **TOTAL** | **3 files** | **14 tests** | **~90min** | **✅** | **Complete** |

---

## 🎯 What Happens at Each Stage

### Assessment.spec.js
```
Database State Changes:
├─ Step 1: User created (status: pending_approval)
├─ Step 2: User approved (status: approved)
├─ Step 3: Assessment answers saved
└─ Step 4: User status → assessment_submitted
```

### post_assessment_review.spec.js
```
Database State Changes:
├─ Test 1: AssignAnalyst record created
│          User status → analyst_assigned
├─ Test 4: Answer records updated with comments
│          User status → assessment_validation_in_progress
└─ Test 5: User status → assessment_validation_completed
```

### delete_user.spec.js
```
Database State Changes:
├─ Step 4: Company deleted
├─ All related records deleted (cascade):
│  ├─ User account deleted
│  ├─ Assessment answers deleted
│  ├─ AssignAnalyst record deleted
│  ├─ Company score deleted
│  └─ All uploads/attachments deleted
└─ Step 5: Verified deletion (not in list)
```

---

## ✅ Expected Final Status

After all three phases complete:

```
Company: DELETED ❌
User: DELETED ❌
Assessment: DELETED ❌
AssignAnalyst: DELETED ❌
Comments: DELETED ❌

Database: CLEAN ✅
Test Results: 14 PASSED ✅
```

---

## 🚀 One-Command Execution

```bash
npm test tests/e2e/company_user/assessment.spec.js tests/e2e/analyst/post_assessment_review.spec.js tests/e2e/cleanup/delete_user.spec.js
```

---

## 📝 Key Points

✅ **All three test files work together**
✅ **Data flows between tests via environment variables**
✅ **Cleanup ensures no test data is left behind**
✅ **Can be run individually but must follow order**
✅ **Complete end-to-end workflow automation**
✅ **Ready for CI/CD pipeline integration**

---

**Created**: January 9, 2026  
**Version**: 1.0  
**Status**: ✅ Complete & Ready to Execute
