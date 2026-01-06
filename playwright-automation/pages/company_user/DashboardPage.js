const BasePage = require('../../pages/BasePage');

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
        await this.takeAssessmentCard.click();
    }

    async clickViewAssessment() {
        await this.viewAssessmentCard.click();
    }

    async isTakeAssessmentDisabled() {
        const classAttribute = await this.takeAssessmentLink.getAttribute('class');
        return classAttribute ? classAttribute.includes('tile-disabled') : false;
    }

    async isViewAssessmentEnabled() {
        const classAttribute = await this.viewAssessmentLink.getAttribute('class');
        return classAttribute ? !classAttribute.includes('tile-disabled') : true;
    }
}

module.exports = DashboardPage;
