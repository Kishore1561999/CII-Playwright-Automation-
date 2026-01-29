const BasePage = require('../BasePage');

class DashboardPage extends BasePage {
    constructor(page) {
        super(page);
        this.takeAssessmentCard = page.locator('p.icon-name', { hasText: 'Take Assessment' });
        this.viewAssessmentCard = page.locator('p.icon-name', { hasText: 'View Assessment' });
        this.viewScorecardCard = page.locator('p.icon-name', { hasText: 'View Scorecard' });
        this.viewReportCard = page.locator('p.icon-name', { hasText: 'View Report' });
        this.takeAssessmentLink = page.locator('.card:has(p.icon-name:text("Take Assessment"))').locator('a, .card-body').first();
        this.viewAssessmentLink = page.locator('.card:has(p.icon-name:text("View Assessment"))').locator('a, .card-body').first();
    }

    async clickTakeAssessment() {
        await this.takeAssessmentCard.scrollIntoViewIfNeeded();
        try {
            await this.takeAssessmentCard.click({ force: true, timeout: 5000 });
        } catch (error) {
            console.warn(`⚠ Standard click failed on Take Assessment card: ${error.message}. Attempting JS click.`);
            await this.takeAssessmentCard.dispatchEvent('click');
        }
    }

    async clickViewAssessment() {
        await this.viewAssessmentCard.scrollIntoViewIfNeeded();
        try {
            await this.viewAssessmentCard.click({ force: true, timeout: 5000 });
        } catch (error) {
            console.warn(`⚠ Standard click failed on View Assessment card: ${error.message}. Attempting JS click.`);
            await this.viewAssessmentCard.dispatchEvent('click');
        }
    }

    async isTakeAssessmentDisabled() {
        const classAttribute = await this.takeAssessmentLink.getAttribute('class');
        return classAttribute ? classAttribute.includes('tile-disabled') : false;
    }

    async isViewAssessmentEnabled() {
        const classAttribute = await this.viewAssessmentLink.getAttribute('class');
        return classAttribute ? !classAttribute.includes('tile-disabled') : true;
    }

    async downloadScorecard() {
        console.log('Attempting to download scorecard...');
        await this.viewScorecardCard.scrollIntoViewIfNeeded();
        const [download] = await Promise.all([
            this.page.waitForEvent('download'),
            this.viewScorecardCard.click({ force: true }).catch(async (e) => {
                console.warn(`⚠ Standard click failed on View Scorecard card: ${e.message}. Attempting JS click.`);
                await this.viewScorecardCard.dispatchEvent('click');
            })
        ]);
        const path = await download.path();
        console.log(`✓ Scorecard downloaded to: ${path}`);
        return path;
    }

    async downloadReport() {
        console.log('Attempting to download report...');
        await this.viewReportCard.scrollIntoViewIfNeeded();
        const [download] = await Promise.all([
            this.page.waitForEvent('download'),
            this.viewReportCard.click({ force: true }).catch(async (e) => {
                console.warn(`⚠ Standard click failed on View Report card: ${e.message}. Attempting JS click.`);
                await this.viewReportCard.dispatchEvent('click');
            })
        ]);
        const path = await download.path();
        console.log(`✓ Report downloaded to: ${path}`);
        return path;
    }
}

module.exports = DashboardPage;
