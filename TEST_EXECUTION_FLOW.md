/**
 * EXECUTION FLOW CONFIGURATION
 * 
 * This file documents the test execution order:
 * 1. assessment.spec.js - Company registration → Admin approval → Assessment submission
 * 2. post_assessment_review.spec.js - Admin assignment → Analyst review → Submit review
 * 3. cleanup/delete_user.spec.js - Delete the test company (teardown)
 * 
 * Run all three tests in sequence:
 *   npm test tests/e2e/company_user/assessment.spec.js tests/e2e/analyst/post_assessment_review.spec.js tests/e2e/cleanup/delete_user.spec.js
 * 
 * Or run them individually:
 *   npm test tests/e2e/company_user/assessment.spec.js
 *   npm test tests/e2e/analyst/post_assessment_review.spec.js
 *   npm test tests/e2e/cleanup/delete_user.spec.js
 */

// Test execution order is maintained through:
// 1. Shared test context/global setup
// 2. Environment variables passing test data between files
// 3. playwright.config.js configuration
