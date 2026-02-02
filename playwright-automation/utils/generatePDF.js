const { chromium } = require('@playwright/test');
const path = require('path');

async function generatePDF() {
    const browser = await chromium.launch();
    const context = await browser.newContext();
    const page = await context.newPage();

    // Path to the generated Ortoni HTML report
    const reportPath = path.resolve(__dirname, '../ortoni-report/index.html');
    const pdfPath = path.resolve(__dirname, '../report.pdf');

    console.log(`Loading report from: ${reportPath}`);

    // Load the HTML report
    await page.goto(`file://${reportPath}`, { waitUntil: 'networkidle' });

    // Give it a small buffer to ensure visuals are rendered
    await page.waitForTimeout(2000);

    console.log(`Generating PDF at: ${pdfPath}`);

    // Generate PDF
    await page.pdf({
        path: pdfPath,
        format: 'A4',
        printBackground: true,
        margin: {
            top: '20px',
            bottom: '20px',
            left: '20px',
            right: '20px'
        }
    });

    await browser.close();
    console.log('PDF generation complete.');
}

generatePDF().catch(err => {
    console.error('Error generating PDF:', err);
    process.exit(1);
});
