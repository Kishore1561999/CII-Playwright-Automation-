# Test Execution Quick Commands

**Updated**: January 9, 2026

---

## 🚀 RUN ALL TESTS (RECOMMENDED)

```bash
npm test tests/e2e/company_user/assessment.spec.js tests/e2e/analyst/post_assessment_review.spec.js tests/e2e/cleanup/delete_user.spec.js
```

**What it does**:
1. ✓ Company registers → Admin approves → Assessment submitted
2. ✓ Admin assigns analyst → Analyst reviews → Submits review  
3. ✓ Deletes test company (cleanup)

**Duration**: ~15 minutes

---

## 📊 RUN WITH VISUAL UI

```bash
npx playwright test tests/e2e/company_user/assessment.spec.js tests/e2e/analyst/post_assessment_review.spec.js tests/e2e/cleanup/delete_user.spec.js --ui
```

**Watch test execution in real-time with UI controls**

---

## 🔍 RUN WITH DEBUG MODE

```bash
npx playwright test tests/e2e/company_user/assessment.spec.js tests/e2e/analyst/post_assessment_review.spec.js tests/e2e/cleanup/delete_user.spec.js --debug
```

**Step through each action with debugger**

---

## 📋 RUN INDIVIDUAL TESTS

```bash
# Just assessment (no cleanup)
npm test tests/e2e/company_user/assessment.spec.js

# Just post-assessment review (requires assessment to run first!)
npm test tests/e2e/analyst/post_assessment_review.spec.js

# Just cleanup (requires both previous tests!)
npm test tests/e2e/cleanup/delete_user.spec.js
```

⚠️ **Must run in order if separate!**

---

## 📈 VIEW TEST REPORTS

```bash
# HTML report
npx playwright show-report

# Allure report
npx allure serve allure-results
```

---

## 🔧 ADVANCED OPTIONS

```bash
# Run with longer timeout (120 seconds)
npm test -- --timeout 120000

# Run with specific number of workers
npm test -- --workers=1

# Run with headed browser (see actual browser)
npm test -- --headed

# Run with specific browser
npm test -- --project=chromium

# Run in parallel
npm test -- --workers=4
```

---

## 📝 COMMON COMMANDS

| Command | Purpose |
|---------|---------|
| `npm test [file]` | Run test file |
| `--ui` | Visual UI mode |
| `--debug` | Step debugger |
| `--headed` | Show browser |
| `--headed --debug` | Browser + debugger |
| `npm test -- --list` | List all tests |
| `npm test -- --grep "pattern"` | Run matching tests |

---

## ✅ SUCCESS = ALL PASS

```
✓ 14 passed
├─ assessment.spec.js (4 tests)
├─ post_assessment_review.spec.js (5 tests)
└─ delete_user.spec.js (5 tests)
```

---

## 🎯 IF TESTS FAIL

**Quick fixes**:

```bash
# 1. Check if selectors need updating
# See: SELECTOR_IDENTIFICATION_GUIDE.md

# 2. Run with debug to see what's happening
npx playwright test [file] --debug

# 3. Check if company exists (run assessment first)
npm test tests/e2e/company_user/assessment.spec.js

# 4. View detailed report
npx playwright show-report
```

---

**For full details, see**: [COMPLETE_TEST_EXECUTION_GUIDE.md](./COMPLETE_TEST_EXECUTION_GUIDE.md)
